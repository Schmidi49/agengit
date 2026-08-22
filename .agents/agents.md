# Project Guidelines & Rules

- **Defensive Programming**: Program extremely defensively, always assume the worst intention of the user/agent using this tool. When in doubt, deny something rather than accepting it.

- **OS Abstraction & Portability**: All operating-system-specific APIs, code paths (such as process spawning with `CreateProcessW` or `fork`/`exec`, string and wide-character conversions, and platform-specific headers like `<windows.h>` or `<unistd.h>`) must be encapsulated within the `OS` layer (`src/OS.h` and `src/OS.cpp`). Keep `src/main.cpp` platform-agnostic, delegating all system tasks to these abstracted interfaces. Follow the policy defined in [.agents/rules/os_abstraction.md]

- **Cross-Platform Testing Strategy**:
  - `agengit` must compile, execute, and pass all security policy checks on both **Linux** and **Windows** operating systems.
  - **Host Testing Allowance**: Unit tests are permitted to run directly on the host machine using `./tests/harness/run.py` or natively:
    ```bash
    cmake -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build
    cmake --install build --prefix /tmp/agengit_test_install
    export PATH="/tmp/agengit_test_install/bin:$PATH"
    agengit status
    ```
  - **Opposing OS Testing (via Docker Compose)**: Always validate cross-platform compliance using Docker Compose environments (`alpine` for Linux, `wine` for Windows):
    ```bash
    # 1. Launch Target Container
    docker compose up -d alpine
    docker compose up -d wine

    # 2. Run Test Gateway inside Container
    docker exec agengit-alpine ./tests/harness/run.py
    docker exec agengit-wine ./tests/harness/run.py

    # 3. Cleanup Container Environment
    docker compose down
    ```
  - **Defensive & Adversarial Mindset**: Always program and test extremely defensively, assuming an adversarial developer or agent is actively trying to bypass `agengit` guardrails. Test against flag spoofing, argument injection, path traversal, dirty repository states, and unapproved subcommands. When in doubt, deny access.
  - **Test Repository Generator & Pre-Test Setup**: Whenever testing `agengit` features (natively or inside Docker), generate a fresh test Git repository using `./tests/create_test_repo.sh <target_directory>`. Clean up any temporary test sandbox directories after host execution.
  - **Test Scope & Harness Boundaries**:
    - Shell unit tests reside in `tests/shell/*.sh` and use `tests/harness/assert.sh`.
    - Python unit tests reside in `tests/python/test_*.py` and use `pytest`.
    - Windows Batch unit tests reside in `tests/cmd/*.cmd` and use `tests/harness/assert.cmd`.

---

# Lessons Learned

## **Wine & MinGW Cross-Compilation Setup**:
  - **Static Linking**: MinGW Windows binaries cross-compiled on Linux must link statically (`-static -static-libgcc -static-libstdc++`) in `CMakeLists.txt` to avoid missing runtime DLL errors (`libgcc_s_seh-1.dll`, `libstdc++-6.dll`) under Wine.
  - **Wine PATH Registry & MinGit**: When installing MinGit in Wine, add `C:\Program Files\Git\cmd` to Wine's `HKCU\Environment` registry key and remove circular `[include]` paths in `C:\Program Files\Git\etc\gitconfig`.
