#ifndef OS_H
#define OS_H

#include <vector>
#include <string>

// Executes the git command with the given arguments, handling OS-specific process spawning.
// Returns the exit code of the spawned process.
int execute_command(const std::vector<std::string>& args);

// Runs the git command with the given arguments, capturing stdout and stderr output.
// Returns the exit code of the spawned process.
int capture_command(const std::vector<std::string>& args, std::string& out_stdout, std::string& out_stderr);

#endif // OS_H
