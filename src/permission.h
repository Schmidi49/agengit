#ifndef PERMISSION_H
#define PERMISSION_H

#include <string_view>
#include <vector>
#include "rules.h"

// ============================================================================
// User-Configurable Safety Policy Settings
// ============================================================================

// Common reusable requirement constants
constexpr StateRequirement REQUIRE_CLEAN_REPO = {
    .require_clean = true
};

constexpr StateRequirement REQUIRE_DEV_BRANCH = {
    .branch_pattern = "^dev/.*$|^dev-.*$"
};

constexpr StateRequirement REQUIRE_DEV_BRANCH_AND_ORIGIN_MATCH = {
    .branch_pattern = "^dev/.*$|^dev-.*$",
    .require_origin_match = true
};

// List of subcommands that are explicitly allowed with no extra checks.
// If a command matches an allowed subcommand, it is passed through to Git.
inline const std::vector<std::string_view> ALLOWED_COMMANDS = {
    "status", "diff", "log"
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

// List of conditional command policies
inline const std::vector<CommandRule> CONDITIONAL_COMMANDS = {
    {
        "push",
        {
            // Default push rule (no trigger flag needed)
            {
                .trigger_flags = {},
                .requirement = REQUIRE_DEV_BRANCH_AND_ORIGIN_MATCH,
                .deny_text = "Pushing is only allowed from 'dev/' or 'dev-' branches and must be up-to-date with origin."
            }
        }
    },
    {
        "checkout",
        {
            // Creating a new branch
            {
                .trigger_flags = { "-b", "-B" },
                .requirement = {
                    .arg_pattern = "^dev/.*$|^dev-.*$", // new branch name must start with dev/ or dev-
                    .arg_locater = ArgLocater::NextToFlag
                },
                .deny_text = "New branches created via checkout must be prefixed with 'dev/' or 'dev-'."
            },
            // Fallback checkout (switching branches / checking out files)
            {
                .trigger_flags = {},
                .requirement = REQUIRE_CLEAN_REPO,
                .deny_text = "Checkout is only allowed when your repository is clean."
            }
        }
    },
    {
        "branch",
        {
            // Deleting branch (triggered by -d or -D) -> only allowed for dev branches merged with main
            {
                .trigger_flags = { "-d", "-D" },
                .requirement = {
                    .arg_pattern = "^dev/.*$|^dev-.*$",
                    .arg_locater = ArgLocater::NextToFlag,
                    .require_merged_into_main = true
                },
                .deny_text = "Only dev branches can be deleted, and they must be merged into main first."
            },
            // Listing branches: git branch -a, git branch -r, git branch --list, etc. -> allowed
            {
                .trigger_flags = { "-a", "-r", "--list", "-l" },
                .requirement = {},
                .deny_text = ""
            },
            // Fallback: creating a branch (e.g. git branch my-branch)
            {
                .trigger_flags = {},
                .requirement = {
                    .arg_pattern = "^dev/.*$|^dev-.*$", // if a positional arg exists, it must match dev/ or dev-
                    .arg_locater = ArgLocater::FirstPositional
                },
                .deny_text = "Created branches must start with 'dev/' or 'dev-' prefix."
            }
        }
    }
};

#endif // PERMISSION_H
