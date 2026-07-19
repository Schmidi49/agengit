#ifndef RULES_H
#define RULES_H

#include <string>
#include <vector>
#include <optional>
#include <string_view>

enum class CommandPolicy {
    ALLOW,
    DENY,
    NOT_IMPLEMENTED
};

struct PolicyDecision {
    CommandPolicy policy;
    std::string explanation;
};

enum class ArgLocater {
    None,
    NextToFlag,
    FirstPositional
};

struct StateRequirement {
    std::optional<std::string_view> branch_pattern;
    std::optional<bool> require_clean;
    std::optional<std::string_view> arg_pattern;
    ArgLocater arg_locater = ArgLocater::None;
    std::optional<bool> require_origin_match;
    std::optional<bool> require_merged_into_main;
};

struct ConditionalRule {
    std::vector<std::string_view> trigger_flags;
    StateRequirement requirement;
    std::string_view deny_text;
};

struct CommandRule {
    std::string_view subcommand;
    std::vector<ConditionalRule> rules;
};

// Evaluates the safety policy for the given command arguments (excluding argv[0]).
PolicyDecision evaluate_policy(const std::vector<std::string>& args);

#endif // RULES_H
