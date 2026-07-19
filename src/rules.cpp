#include "rules.h"
#include "permission.h"
#include "OS.h"
#include <algorithm>
#include <regex>
#include <vector>
#include <string>

// Helper class for lazy-fetching and caching Git repository state
class GitState {
public:
    explicit GitState(const std::vector<std::string>& global_args) : global_args_(global_args) {}

    // Returns current branch name. Returns empty if detached HEAD or error.
    const std::string& get_current_branch() {
        if (!branch_cached_) {
            current_branch_ = fetch_current_branch();
            branch_cached_ = true;
        }
        return current_branch_;
    }

    // Returns true if working directory is clean
    bool is_repo_clean() {
        if (!clean_cached_) {
            is_clean_ = check_repo_clean();
            clean_cached_ = true;
        }
        return is_clean_;
    }

    // Returns true if local branch matches origin
    bool matches_origin() {
        if (!origin_cached_) {
            origin_matches_ = check_origin_match();
            origin_cached_ = true;
        }
        return origin_matches_;
    }

    // Returns true if target_branch is merged into main
    bool is_merged_into_main(const std::string& target_branch) {
        std::string out_stdout, out_stderr;
        int code = run_git({"merge-base", "--is-ancestor", target_branch, "main"}, out_stdout, out_stderr);
        return code == 0;
    }

private:
    std::vector<std::string> global_args_;
    std::string current_branch_;
    bool branch_cached_ = false;
    bool is_clean_ = false;
    bool clean_cached_ = false;
    bool origin_matches_ = false;
    bool origin_cached_ = false;

    // Helper to run a command with the same global arguments
    int run_git(const std::vector<std::string>& sub_args, std::string& out_stdout, std::string& out_stderr) {
        std::vector<std::string> full_args = global_args_;
        full_args.insert(full_args.end(), sub_args.begin(), sub_args.end());
        return capture_command(full_args, out_stdout, out_stderr);
    }

    std::string fetch_current_branch() {
        std::string out_stdout, out_stderr;
        // git symbolic-ref --short HEAD retrieves the branch name or returns non-zero if detached
        int code = run_git({"symbolic-ref", "--short", "HEAD"}, out_stdout, out_stderr);
        if (code != 0) {
            return ""; // Detached HEAD or error
        }
        // Trim trailing whitespace/newlines
        while (!out_stdout.empty() && (out_stdout.back() == '\n' || out_stdout.back() == '\r' || out_stdout.back() == ' ')) {
            out_stdout.pop_back();
        }
        return out_stdout;
    }

    bool check_repo_clean() {
        std::string out_stdout, out_stderr;
        int code = run_git({"status", "--porcelain"}, out_stdout, out_stderr);
        if (code != 0) {
            return false; // Error running status: fail closed
        }
        // If stdout contains non-whitespace characters, it's dirty
        for (char c : out_stdout) {
            if (c != ' ' && c != '\t' && c != '\r' && c != '\n') {
                return false;
            }
        }
        return true;
    }

    bool check_origin_match() {
        std::string out_stdout, out_stderr;
        // 1. Run git fetch to update remote branches
        run_git({"fetch"}, out_stdout, out_stderr);

        // 2. Get local HEAD commit
        std::string local_commit, err_local;
        int code_local = run_git({"rev-parse", "HEAD"}, local_commit, err_local);
        if (code_local != 0) return false;

        // Trim local_commit
        while (!local_commit.empty() && (local_commit.back() == '\n' || local_commit.back() == '\r' || local_commit.back() == ' ')) {
            local_commit.pop_back();
        }

        // 3. Get remote upstream commit using @{u}
        std::string remote_commit, err_remote;
        int code_remote = run_git({"rev-parse", "@{u}"}, remote_commit, err_remote);
        if (code_remote != 0) return false; // No upstream or parsing failed: fail-closed

        // Trim remote_commit
        while (!remote_commit.empty() && (remote_commit.back() == '\n' || remote_commit.back() == '\r' || remote_commit.back() == ' ')) {
            remote_commit.pop_back();
        }

        return local_commit == remote_commit;
    }
};

PolicyDecision evaluate_policy(const std::vector<std::string>& args) {
    std::string subcommand = "";
    bool found_subcommand = false;
    std::vector<std::string> global_args;
    std::vector<std::string> command_args;

    for (size_t i = 0; i < args.size(); ++i) {
        const std::string& arg = args[i];
        if (arg.empty()) continue;

        if (!found_subcommand) {
            if (arg[0] == '-') {
                global_args.push_back(arg);
                // Check if it is a known safe option with a space-separated argument
                if (arg == "-C" || arg == "-c" || arg == "--git-dir" || arg == "--work-tree" || arg == "--namespace") {
                    if (i + 1 < args.size()) {
                        global_args.push_back(args[i + 1]);
                        i++; // Skip the option's value
                    } else {
                        // Option value is missing; fail-closed
                        return { CommandPolicy::DENY, "Malformed command line (missing option value)." };
                    }
                }
            } else {
                subcommand = arg;
                found_subcommand = true;
            }
        } else {
            command_args.push_back(arg);
        }
    }

    if (!found_subcommand) {
        // No subcommand was parsed (e.g. running `git` or `git --help`).
        // This is safe as it only displays help/usage/version information.
        return { CommandPolicy::ALLOW, "" };
    }

    // 1. Check DENIED_COMMANDS
    auto denied_it = std::find_if(DENIED_COMMANDS.begin(), DENIED_COMMANDS.end(),
        [&subcommand](const DeniedCommand& dc) {
            return dc.command == subcommand;
        });

    if (denied_it != DENIED_COMMANDS.end()) {
        return { CommandPolicy::DENY, std::string(denied_it->deny_text) };
    }

    // Initialize lazy GitState provider
    GitState state(global_args);

    // 2. Check CONDITIONAL_COMMANDS
    auto conditional_it = std::find_if(CONDITIONAL_COMMANDS.begin(), CONDITIONAL_COMMANDS.end(),
        [&subcommand](const CommandRule& cr) {
            return cr.subcommand == subcommand;
        });

    if (conditional_it != CONDITIONAL_COMMANDS.end()) {
        // Evaluate the conditional rules in order
        for (const auto& rule : conditional_it->rules) {
            bool matches_trigger = false;
            if (rule.trigger_flags.empty()) {
                matches_trigger = true; // Fallback rule matches unconditionally
            } else {
                for (const auto& tf : rule.trigger_flags) {
                    if (std::find(command_args.begin(), command_args.end(), tf) != command_args.end()) {
                        matches_trigger = true;
                        break;
                    }
                }
            }

            if (matches_trigger) {
                const auto& req = rule.requirement;

                // Evaluate Repository cleanliness
                if (req.require_clean.has_value()) {
                    if (state.is_repo_clean() != req.require_clean.value()) {
                        return { CommandPolicy::DENY, std::string(rule.deny_text) };
                    }
                }

                // Evaluate Branch Pattern
                if (req.branch_pattern.has_value()) {
                    const std::string& current_branch = state.get_current_branch();
                    if (current_branch.empty()) {
                        // Detached HEAD or error: deny for safety
                        return { CommandPolicy::DENY, std::string(rule.deny_text) + " (Detached HEAD or current branch unavailable)" };
                    }
                    std::regex pattern(std::string(req.branch_pattern.value()));
                    if (!std::regex_match(current_branch, pattern)) {
                        return { CommandPolicy::DENY, std::string(rule.deny_text) };
                    }
                }

                // Evaluate Origin Match
                if (req.require_origin_match.has_value() && req.require_origin_match.value()) {
                    if (!state.matches_origin()) {
                        return { CommandPolicy::DENY, std::string(rule.deny_text) + " (Local branch commit does not match upstream origin, or no upstream tracking is set)" };
                    }
                }

                // Evaluate Merged Into Main
                if (req.require_merged_into_main.has_value() && req.require_merged_into_main.value()) {
                    std::string target_branch = "";
                    bool branch_found = false;

                    if (req.arg_locater == ArgLocater::NextToFlag) {
                        for (size_t i = 0; i < command_args.size(); ++i) {
                            bool is_trigger = false;
                            for (const auto& tf : rule.trigger_flags) {
                                if (command_args[i] == tf) {
                                    is_trigger = true;
                                    break;
                                }
                            }
                            if (is_trigger && i + 1 < command_args.size()) {
                                target_branch = command_args[i + 1];
                                branch_found = true;
                                break;
                            }
                        }
                    } else if (req.arg_locater == ArgLocater::FirstPositional) {
                        for (const auto& arg : command_args) {
                            if (arg.empty()) continue;
                            if (arg[0] != '-') {
                                target_branch = arg;
                                branch_found = true;
                                break;
                            }
                        }
                    }

                    if (branch_found) {
                        if (!state.is_merged_into_main(target_branch)) {
                            return { CommandPolicy::DENY, std::string(rule.deny_text) + " (Branch '" + target_branch + "' is not merged into main)" };
                        }
                    } else {
                        return { CommandPolicy::DENY, std::string(rule.deny_text) + " (No branch specified for checking merged status)" };
                    }
                }

                // Evaluate Argument check
                if (req.arg_pattern.has_value() && req.arg_locater != ArgLocater::None) {
                    std::string target_arg = "";
                    bool arg_found = false;

                    if (req.arg_locater == ArgLocater::NextToFlag) {
                        for (size_t i = 0; i < command_args.size(); ++i) {
                            bool is_trigger = false;
                            for (const auto& tf : rule.trigger_flags) {
                                if (command_args[i] == tf) {
                                    is_trigger = true;
                                    break;
                                }
                            }
                            if (is_trigger && i + 1 < command_args.size()) {
                                target_arg = command_args[i + 1];
                                arg_found = true;
                                break;
                            }
                        }
                    } else if (req.arg_locater == ArgLocater::FirstPositional) {
                        for (const auto& arg : command_args) {
                            if (arg.empty()) continue;
                            if (arg[0] != '-') {
                                target_arg = arg;
                                arg_found = true;
                                break;
                            }
                        }
                    }

                    if (arg_found) {
                        std::regex pattern(std::string(req.arg_pattern.value()));
                        if (!std::regex_match(target_arg, pattern)) {
                            return { CommandPolicy::DENY, std::string(rule.deny_text) };
                        }
                    }
                }

                // All requirements passed
                return { CommandPolicy::ALLOW, "" };
            }
        }
        // If a command matches conditional list but none of its trigger rules are matched (should not happen if fallback is present)
        return { CommandPolicy::DENY, "Safety check trigger failed to match." };
    }

    // 3. Check ALLOWED_COMMANDS
    auto allowed_it = std::find(ALLOWED_COMMANDS.begin(), ALLOWED_COMMANDS.end(), subcommand);
    if (allowed_it != ALLOWED_COMMANDS.end()) {
        return { CommandPolicy::ALLOW, "" };
    }

    // Fail-closed for any other command
    return { CommandPolicy::NOT_IMPLEMENTED, "" };
}
