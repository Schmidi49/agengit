# Project Guidelines & Rules

- **Defensive Programming**: Program extremely defensively, always assume the worst intention of the user/agent using this tool. When in doubt, deny something rather than accepting it.

- **OS Abstraction & Portability**: All operating-system-specific APIs, code paths (such as process spawning with `CreateProcessW` or `fork`/`exec`, string and wide-character conversions, and platform-specific headers like `<windows.h>` or `<unistd.h>`) must be encapsulated within the `OS` layer (`src/OS.h` and `src/OS.cpp`). Keep `src/main.cpp` platform-agnostic, delegating all system tasks to these abstracted interfaces. Follow the policy defined in [.agents/rules/os_abstraction.md]

- **Cross-Platform Testing Policy**: All features must be tested for both Linux and Windows operating systems before completing work. Follow the policy defined in [.agents/rules/testing.md]. Test local OS natively on the host machine and test opposing OS via Docker containers (`docker/Dockerfile.alpine` and `docker/Dockerfile.wine`).

---

# Lessons Learned

## **Wine & MinGW Cross-Compilation Setup**:
  - **Static Linking**: MinGW Windows binaries cross-compiled on Linux must link statically (`-static -static-libgcc -static-libstdc++`) in `CMakeLists.txt` to avoid missing runtime DLL errors (`libgcc_s_seh-1.dll`, `libstdc++-6.dll`) under Wine.
  - **Wine PATH Registry & MinGit**: When installing MinGit in Wine, add `C:\Program Files\Git\cmd` to Wine's `HKCU\Environment` registry key and remove circular `[include]` paths in `C:\Program Files\Git\etc\gitconfig`.
