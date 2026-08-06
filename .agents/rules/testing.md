# Repository Rule: Cross-Platform Testing Strategy

## Overview

`agengit` must compile, execute, and pass all security policy checks on both **Linux** and **Windows** operating systems.

---

## Defensive & Adversarial Testing Policy

When writing code or validating safety policies:
- **Defensive & Adversarial Mindset**: Always program and test extremely defensively, assuming an adversarial developer or agent is actively trying to bypass `agengit` guardrails. Test against flag spoofing, argument injection, path traversal, dirty repository states, and unapproved subcommands. When in doubt, deny access rather than allowing it.

---

## Testing Policy

When validating code changes or running tests:

### 1. Local Host OS Testing
- Always run local native builds, install to a temporary prefix or system path, and test the installed executable directly from `PATH`:
  ```bash
  cmake -B build -DCMAKE_BUILD_TYPE=Release
  cmake --build build
  cmake --install build --prefix /tmp/agengit_test_install
  export PATH="/tmp/agengit_test_install/bin:$PATH"
  agengit status
  ```

### 2. Opposing OS Testing (via Docker)
- Always validate the opposing operating system using the Docker testing environments located in `docker/` (`docker/Dockerfile.alpine` for Linux, `docker/Dockerfile.wine` for Windows):
- When working with docker, try to execute only commands listed below, as those are already whitelisted by permissions
- When running commands during testing, execute them inside the docker container (now request prompting for the user and the entire repo is mounted into the containers)

  
#### Dynamic 3-Step Container Testing Workflow
Replace `<target>` with `alpine` or `wine`:

1. **Build Container Image:**
   ```bash
   docker build -t agengit-<target> -f docker/Dockerfile.<target> .
   ```

2. **Launch Detached Named Container:**
   ```bash
   docker run -d --name agengit-test-<target> agengit-<target> tail -f /dev/null
   ```

3. **Execute Atomic Test Commands & Temporary Test Scripts (`docker exec`):**
   - Both `docker exec` and interactive/piped execution (`docker exec -i`) are allowed by permissions.
   - **Temporary Container Test Scripts**: Always create and run temporary test scripts inside the Docker container (e.g. piping via `docker exec -i agengit-test-<target> bash < script.sh` or writing scripts directly inside container `/tmp/`). Executing commands inside the container allows full execution freedom without requiring host user approvals or modifying host files.
   - **Initialize Test Environment:**
     ```bash
     docker exec agengit-test-<target> ./tests/create_test_repo.sh /tmp/test_repo
     ```
   - **Install Executable & Verify system-wide PATH Callability:**
     - On **Alpine (Linux)**:
       ```bash
       docker exec agengit-test-alpine cmake --install /workspace/build
       docker exec agengit-test-alpine agengit -C /tmp/test_repo status
       ```
     - On **Wine (Windows)**:
       ```bash
       docker exec agengit-test-wine cmake --install /workspace/build-wine
       docker exec agengit-test-wine agengit -C /tmp/test_repo status
       ```
   - **Execute Atomic `agengit` Function & Policy Checks:**
     ```bash
     docker exec agengit-test-<target> agengit -C /tmp/test_repo status
     docker exec agengit-test-<target> agengit -C /tmp/test_repo rebase main
     ```

4. **Cleanup Container:**
   ```bash
   docker rm -f agengit-test-<target>
   ```

### 3. Test Repository Generator & Cleanup Policy
- **Mandatory Test Repo Usage:** Whenever testing an `agengit` feature (independent of whether testing natively on the host OS or inside a Docker container), generate a fresh test Git repository using the script `tests/create_test_repo.sh <target_empty_directory>`. If testing on a real host machine, ensure any temporary test sandbox directory is cleaned up after testing completes.
- **Evolving the Test Repo:** If newly implemented `agengit` commands require additional Git states, branches, or file configurations in the test repository, `tests/create_test_repo.sh` should be developed further as part of the feature development process.
