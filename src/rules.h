#ifndef RULES_H
#define RULES_H

#include <string>
#include <vector>

enum class CommandPolicy {
    ALLOW,
    DENY,
    NOT_IMPLEMENTED
};

struct PolicyDecision {
    CommandPolicy policy;
    std::string explanation;
};

// Evaluates the safety policy for the given command arguments (excluding argv[0]).
PolicyDecision evaluate_policy(const std::vector<std::string>& args);

#endif // RULES_H
