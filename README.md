# agengit

`agengit` is a security-focused C++ Git wrapper designed specifically for use by AI agents. It acts as an execution gatekeeper, intercepting git command-line calls and validating them against a strict compile-time safety policy.

This prevents agents from executing destructive commands (e.g., `git rebase` or `git reset --hard`) or performing unsafe operations (e.g., committing directly to production branches).

---

## Behavior & Output Formats

Every command executed through `agengit` will result in one of the following four output formats:

### 1. Standard Git Output
If the command matches the compile-time safety policy, the input, output, and error streams are piped 1-to-1 to the underlying Git installation. Terminal interactive elements, coloring, and standard outputs/exit codes are preserved transparently.
* **Exit Code**: Matches Git's exit code.

### 2. Permission Denied
If the command is recognized but violates the safety policy, `agengit` blocks the execution immediately, prints the permission denied header, and provides a clear natural language explanation of the violation.
* **Output Format**:
  ```text
  #### PERMISSION DENIED ####
  <Natural language explanation of why the command was blocked>
  ```
* **Exit Code**: Non-zero (e.g., `1`).

### 3. Command Not Implemented
If the command or subcommand syntax is not covered by any rule in the safety configuration, `agengit` fails closed (denying the execution by default) to prevent unknown actions from running.
* **Output Format**:
  ```text
  #### COMMAND NOT IMPLEMENTED ####
  ```
* **Exit Code**: Non-zero (e.g., `1`).

### 4. Error
If the command is malformed, if the real Git process fails to launch or crashes, or if an internal wrapper error occurs, `agengit` outputs the error format.
* **Output Format**:
  ```text
  #### ERROR ####
  <Details of the error or crash description>
  ```
* **Exit Code**: Non-zero (e.g., `1`).

---

## Configuration

Security rules are compiled directly into the executable via a C++ header file (`rules.h` or `config.h`) before compiling the binary. This ensures that the binary is completely self-contained and prevents runtime configuration tampering.

---

## Build Instructions

To configure and compile `agengit`, use the following standard CMake commands from the root directory of the repository:

### 1. Configure the Build
Generate the build system configuration.

On Windows (multi-config generator by default):
```powershell
cmake -B build
```

On Linux/macOS (single-config generator by default, specify `CMAKE_BUILD_TYPE` as `Release` or `Debug`):
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
```

### 2. Compile the Executable
Build the binary (we recommend using the `Release` configuration for production):
```powershell
cmake --build build --config Release
```
This generates the executable:
- **Windows**: `build/Release/agengit.exe` (or `build/Debug/agengit.exe` for debug)
- **Linux/macOS**: `build/Release/agengit` (or `build/Debug/agengit` for debug)

### 3. Clean the Build
To clean compilation artifacts:
```powershell
cmake --build build --target clean
# Or delete the build directory:
Remove-Item -Recurse -Force build
```

---

## Prerequisites & Dependencies

### Git Prerequisite
* **Git must be installed** on the host system and available in the execution path (`PATH`) for `agengit` to function. `agengit` acts purely as a gatekeeper wrapper and relies on the system's Git installation to perform all repository modifications.

### License & Attributions
* `agengit` is released under the [MIT License](file:///c:/Users/ErikS/source/agengit/LICENSE).
* `agengit` executes Git under the hood. Git is a separate open-source project licensed under the GNU General Public License version 2.0.
