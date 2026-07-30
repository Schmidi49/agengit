# Repository Rule: Cross-Platform Testing Strategy

## Overview

`agengit` must compile, execute, and pass all security policy checks on both **Linux** and **Windows** operating systems.

---

## Testing Policy

When validating code changes or running tests:

### 1. Local Host OS Testing
- Always run local native builds and tests directly on your host operating system using standard CMake commands:
  ```bash
  cmake -B build -DCMAKE_BUILD_TYPE=Release
  cmake --build build
  ```

### 2. Opposing OS Testing (via Docker)
- Always validate the opposing operating system using the Docker testing environments located in `docker/`:
  
  - **Testing Linux Target (from Windows host)**:
    Build and run the Alpine Linux Docker container:
    ```bash
    docker build -t agengit-alpine -f docker/Dockerfile.alpine .
    docker run --rm agengit-alpine
    ```

  - **Testing Windows Target (from Linux host)**:
    Build and run the Wine Docker container:
    ```bash
    docker build -t agengit-wine -f docker/Dockerfile.wine .
    docker run --rm agengit-wine
    ```

### 3. Test Repository Generator & Cleanup Policy
- **Mandatory Test Repo Usage:** Whenever testing an `agengit` feature (independent of whether testing natively on the host OS or inside a Docker container), generate a fresh test Git repository using the script `tests/create_test_repo.sh <target_empty_directory>`. If testing on a real host machine, ensure any temporary test sandbox directory is cleaned up after testing completes.
- **Evolving the Test Repo:** If newly implemented `agengit` commands require additional Git states, branches, or file configurations in the test repository, `tests/create_test_repo.sh` should be developed further as part of the feature development process.

---

## Operating System Abstraction Enforcement
- Ensure any platform-specific code (e.g. process execution, pipes, string conversions) is strictly encapsulated within `src/OS.h` and `src/OS.cpp`.
- Verify that both Linux and Windows binaries produce identical output headers (`#### PERMISSION DENIED ####`, `#### COMMAND NOT IMPLEMENTED ####`, `#### ERROR ####`) and exit codes.
