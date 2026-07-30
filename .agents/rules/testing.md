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

---

## Operating System Abstraction Enforcement
- Ensure any platform-specific code (e.g. process execution, pipes, string conversions) is strictly encapsulated within `src/OS.h` and `src/OS.cpp`.
- Verify that both Linux and Windows binaries produce identical output headers (`#### PERMISSION DENIED ####`, `#### COMMAND NOT IMPLEMENTED ####`, `#### ERROR ####`) and exit codes.
