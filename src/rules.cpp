#include "rules.h"
#include "permission.h"
#include <algorithm>

PolicyDecision evaluate_policy(const std::vector<std::string>& args) {
    std::string subcommand = "";
    bool found_subcommand = false;

    for (size_t i = 0; i < args.size(); ++i) {
        const std::string& arg = args[i];
        if (arg.empty()) continue;

        if (arg[0] == '-') {
            // Check if it is a known safe option with a space-separated argument
            if (arg == "-C" || arg == "-c" || arg == "--git-dir" || arg == "--work-tree" || arg == "--namespace") {
                if (i + 1 < args.size()) {
                    i++; // Skip the option's value
                } else {
                    // Option value is missing; fail-closed
                    return { CommandPolicy::DENY, "Malformed command line (missing option value)." };
                }
            }
            // Check if it is a known option with an inline value (containing '=')
            else if (arg.starts_with("--git-dir=") ||
                     arg.starts_with("--work-tree=") ||
                     arg.starts_with("--namespace=") ||
                     arg.starts_with("--exec-path=") ||
                     arg.starts_with("-c")) {
                continue;
            }
            // Check if it is a known safe option without arguments
            else if (arg == "--bare" ||
                     arg == "--no-pager" ||
                     arg == "--paginate" ||
                     arg == "-p" ||
                     arg == "-P" ||
                     arg == "--no-replace-objects" ||
                     arg == "--no-optional-locks" ||
                     arg == "--version" ||
                     arg == "-v" ||
                     arg == "--help" ||
                     arg == "-h" ||
                     arg == "--exec-path") {
                continue;
            }
            else {
                // Unknown/unsupported option. Program extremely defensively:
                // fail-closed to prevent argument injection or subcommand masking.
                return { CommandPolicy::DENY, "Unsupported global option '" + arg + "' intercepted. Blocked for safety." };
            }
        } else {
            // First non-option argument is the subcommand
            subcommand = arg;
            found_subcommand = true;
            break;
        }
    }

    if (!found_subcommand) {
        // No subcommand was parsed (e.g. running `git` or `git --help`).
        // This is safe as it only displays help/usage/version information.
        return { CommandPolicy::ALLOW, "" };
    }

    // Check if subcommand is explicitly allowed
    auto allowed_it = std::find(ALLOWED_COMMANDS.begin(), ALLOWED_COMMANDS.end(), subcommand);
    if (allowed_it != ALLOWED_COMMANDS.end()) {
        return { CommandPolicy::ALLOW, "" };
    }

    // Check if subcommand is explicitly denied
    auto denied_it = std::find_if(DENIED_COMMANDS.begin(), DENIED_COMMANDS.end(),
        [&subcommand](const DeniedCommand& dc) {
            return dc.command == subcommand;
        });

    if (denied_it != DENIED_COMMANDS.end()) {
        return { CommandPolicy::DENY, std::string(denied_it->deny_text) };
    }

    // Fail-closed for any other command
    return { CommandPolicy::NOT_IMPLEMENTED, "" };
}
