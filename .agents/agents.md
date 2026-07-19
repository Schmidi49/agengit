# Project Guidelines & Rules

- **Defensive Programming**: Program extremely defensively, always assume the worst intention of the user/agent using this tool. When in doubt, deny something rather than accepting it.

- **OS Abstraction & Portability**: All operating-system-specific APIs, code paths (such as process spawning with `CreateProcessW` or `fork`/`exec`, string and wide-character conversions, and platform-specific headers like `<windows.h>` or `<unistd.h>`) must be encapsulated within the `OS` layer (`src/OS.h` and `src/OS.cpp`). Keep `src/main.cpp` platform-agnostic, delegating all system tasks to these abstracted interfaces. If platform separation grows complex, platform-specific sub-modules (e.g., `OS-Windows.h` / `OS-Linux.h`) can be introduced, but default to the unified `OS.h`/`OS.cpp` files.
