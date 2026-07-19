#ifndef PERMISSION_H
#define PERMISSION_H

#include <string_view>
#include <vector>

// ============================================================================
// User-Configurable Safety Policy Settings
// ============================================================================

// List of subcommands that are explicitly allowed.
// If a command matches an allowed subcommand, it is passed through to Git.
inline const std::vector<std::string_view> ALLOWED_COMMANDS = {
    "status"
};

// Represents a blocked subcommand and its explanation message.
struct DeniedCommand {
    std::string_view command;
    std::string_view deny_text;
};

// List of subcommands that are explicitly blocked.
// If a command matches a denied subcommand, execution is blocked with its deny_text.
inline const std::vector<DeniedCommand> DENIED_COMMANDS = {
    { "rebase", "Rebasing is a destructive history-rewriting operation and is not allowed." }
};

#endif // PERMISSION_H
