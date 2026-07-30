# Repository Rule: Operating System Abstraction Enforcement

## Overview

All operating-system-specific APIs, system calls, process creation, pipe manipulations, string conversions, and platform headers must be strictly encapsulated within the OS abstraction layer.

---

## Guidelines & Enforcement

1. **OS Encapsulation Layer (`src/OS.h` and `src/OS.cpp`)**:
   - All platform-dependent APIs (such as process spawning via `CreateProcessW` on Windows or `fork`/`execvp` on Linux, handle/fd pipes, and platform-specific headers like `<windows.h>` or `<unistd.h>`) must reside within `src/OS.h` and `src/OS.cpp`.
   - `src/main.cpp` and `src/rules.cpp` must remain completely platform-agnostic, delegating all OS interaction to the functions defined in `src/OS.h`.

2. **Cross-Platform Output & Exit Code Consistency**:
   - Verify that both Linux and Windows binaries produce identical output headers (`#### PERMISSION DENIED ####`, `#### COMMAND NOT IMPLEMENTED ####`, `#### ERROR ####`) and exit codes.
