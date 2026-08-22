#!/usr/bin/env bash
# tests/shell/test_global_flags.sh - Unit tests for agengit global flags, option smuggling, and malformed flags

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/../harness/assert.sh"

# Locate agengit executable
if [ -n "${AGENGIT_BIN:-}" ]; then
    AGENGIT="$AGENGIT_BIN"
elif command -v agengit >/dev/null 2>&1; then
    AGENGIT="agengit"
elif [ -x "$REPO_ROOT/build-host/Release/agengit" ]; then
    AGENGIT="$REPO_ROOT/build-host/Release/agengit"
elif [ -x "$REPO_ROOT/build-host/agengit" ]; then
    AGENGIT="$REPO_ROOT/build-host/agengit"
elif [ -x "$REPO_ROOT/build/Release/agengit" ]; then
    AGENGIT="$REPO_ROOT/build/Release/agengit"
elif [ -x "$REPO_ROOT/build/agengit" ]; then
    AGENGIT="$REPO_ROOT/build/agengit"
elif [ -x "/workspace/build/Release/agengit" ]; then
    AGENGIT="/workspace/build/Release/agengit"
elif [ -x "/workspace/build/agengit" ]; then
    AGENGIT="/workspace/build/agengit"
else
    AGENGIT="agengit"
fi

TEST_REPO_DIR="${TEST_REPO_DIR:-/tmp/agengit_test_repo}"
if [ -z "${AGENGIT_BIN+x}" ] || [ ! -f "$AGENGIT_BIN" ]; then
    if [ -f "$SCRIPT_DIR/../../build/Release/agengit" ]; then
        AGENGIT_BIN="$SCRIPT_DIR/../../build/Release/agengit"
    elif [ -f "$SCRIPT_DIR/../../build/agengit" ]; then
        AGENGIT_BIN="$SCRIPT_DIR/../../build/agengit"
    elif [ -f "$SCRIPT_DIR/../agengit" ]; then
        AGENGIT_BIN="$SCRIPT_DIR/../agengit"
    else
        AGENGIT_BIN="agengit"
    fi
fi

if [ ! -d "$TEST_REPO_DIR" ]; then
    "$REPO_ROOT/tests/create_test_repo.sh" "$TEST_REPO_DIR" >/dev/null 2>&1 || true
fi

echo "--- Running Shell Unit Tests: agengit global flags & security ---"

# ==============================================================================
# 1. Test Valid Global Flags (-C, -c, --git-dir, --work-tree, --namespace)
# ==============================================================================

# Test -C <dir>
output=$("$AGENGIT_BIN" -C "$TEST_REPO_DIR" status 2>&1) || status=$?
status=${status:-0}
assert_status 0 "$status" "agengit -C <dir> status succeeds"
unset status

# Test -c <key=val>
output=$("$AGENGIT_BIN" -C "$TEST_REPO_DIR" -c user.name="TestUser" status 2>&1) || status=$?
status=${status:-0}
assert_status 0 "$status" "agengit -c <key=val> status succeeds"
unset status

# Test --git-dir=<path>
output=$("$AGENGIT_BIN" --git-dir="$TEST_REPO_DIR/.git" --work-tree="$TEST_REPO_DIR" status 2>&1) || status=$?
status=${status:-0}
assert_status 0 "$status" "agengit --git-dir=<path> status succeeds"
unset status

# Test --work-tree=<path>
output=$("$AGENGIT_BIN" --work-tree="$TEST_REPO_DIR" --git-dir="$TEST_REPO_DIR/.git" status 2>&1) || status=$?
status=${status:-0}
assert_status 0 "$status" "agengit --work-tree=<path> status succeeds"
unset status

# Test --namespace=<name>
output=$("$AGENGIT_BIN" -C "$TEST_REPO_DIR" --namespace=testns status 2>&1) || status=$?
status=${status:-0}
assert_status 0 "$status" "agengit --namespace=<name> status succeeds"
unset status


# ==============================================================================
# 2. Test Option Smuggling Attempts
# ==============================================================================

# agengit -C <dir> rebase must be DENIED
output=$("$AGENGIT_BIN" -C "$TEST_REPO_DIR" rebase 2>&1) || status=$?
status=${status:-0}
assert_status 1 "$status" "Option smuggling agengit -C <dir> rebase exits with 1"
assert_contains "$output" "#### PERMISSION DENIED ####" "Option smuggling agengit -C <dir> rebase produces DENIED header"
unset status

# agengit -C <dir> status must be ALLOWED
output=$("$AGENGIT_BIN" -C "$TEST_REPO_DIR" status 2>&1) || status=$?
status=${status:-0}
assert_status 0 "$status" "Option smuggling test: agengit -C <dir> status is ALLOWED"
unset status

# agengit -c <key=val> rebase must be DENIED
output=$("$AGENGIT_BIN" -C "$TEST_REPO_DIR" -c user.name="Test" rebase 2>&1) || status=$?
status=${status:-0}
assert_status 1 "$status" "Option smuggling agengit -c rebase exits with 1"
assert_contains "$output" "#### PERMISSION DENIED ####" "Option smuggling agengit -c rebase produces DENIED header"
unset status

# agengit --git-dir=<path> rebase must be DENIED
output=$("$AGENGIT_BIN" --git-dir="$TEST_REPO_DIR/.git" rebase 2>&1) || status=$?
status=${status:-0}
assert_status 1 "$status" "Option smuggling agengit --git-dir rebase exits with 1"
assert_contains "$output" "#### PERMISSION DENIED ####" "Option smuggling agengit --git-dir rebase produces DENIED header"
unset status

# agengit --work-tree=<path> rebase must be DENIED
output=$("$AGENGIT_BIN" --work-tree="$TEST_REPO_DIR" --git-dir="$TEST_REPO_DIR/.git" rebase 2>&1) || status=$?
status=${status:-0}
assert_status 1 "$status" "Option smuggling agengit --work-tree rebase exits with 1"
assert_contains "$output" "#### PERMISSION DENIED ####" "Option smuggling agengit --work-tree rebase produces DENIED header"
unset status

# agengit --namespace=<name> rebase must be DENIED
output=$("$AGENGIT_BIN" -C "$TEST_REPO_DIR" --namespace=testns rebase 2>&1) || status=$?
status=${status:-0}
assert_status 1 "$status" "Option smuggling agengit --namespace rebase exits with 1"
assert_contains "$output" "#### PERMISSION DENIED ####" "Option smuggling agengit --namespace rebase produces DENIED header"
unset status


# ==============================================================================
# 3. Test Malformed Global Flags (Missing option value)
# ==============================================================================

# agengit -C (missing argument)
output=$("$AGENGIT_BIN" -C 2>&1) || status=$?
status=${status:-0}
assert_status 1 "$status" "Malformed agengit -C exits with 1"
assert_contains "$output" "#### PERMISSION DENIED ####" "Malformed agengit -C produces DENIED header"
assert_contains "$output" "Malformed command line" "Malformed agengit -C error message contains 'Malformed command line'"
unset status

# agengit -c (missing argument)
output=$("$AGENGIT_BIN" -c 2>&1) || status=$?
status=${status:-0}
assert_status 1 "$status" "Malformed agengit -c exits with 1"
assert_contains "$output" "#### PERMISSION DENIED ####" "Malformed agengit -c produces DENIED header"
assert_contains "$output" "Malformed command line" "Malformed agengit -c error message contains 'Malformed command line'"
unset status

# agengit --git-dir (missing argument)
output=$("$AGENGIT_BIN" --git-dir 2>&1) || status=$?
status=${status:-0}
assert_status 1 "$status" "Malformed agengit --git-dir exits with 1"
assert_contains "$output" "#### PERMISSION DENIED ####" "Malformed agengit --git-dir produces DENIED header"
assert_contains "$output" "Malformed command line" "Malformed agengit --git-dir error message contains 'Malformed command line'"
unset status

# agengit --work-tree (missing argument)
output=$("$AGENGIT_BIN" --work-tree 2>&1) || status=$?
status=${status:-0}
assert_status 1 "$status" "Malformed agengit --work-tree exits with 1"
assert_contains "$output" "#### PERMISSION DENIED ####" "Malformed agengit --work-tree produces DENIED header"
assert_contains "$output" "Malformed command line" "Malformed agengit --work-tree error message contains 'Malformed command line'"
unset status

# agengit --namespace (missing argument)
output=$("$AGENGIT_BIN" --namespace 2>&1) || status=$?
status=${status:-0}
assert_status 1 "$status" "Malformed agengit --namespace exits with 1"
assert_contains "$output" "#### PERMISSION DENIED ####" "Malformed agengit --namespace produces DENIED header"
assert_contains "$output" "Malformed command line" "Malformed agengit --namespace error message contains 'Malformed command line'"
unset status

# Mandatory failure tracking exit code
[ "$TEST_FAILED" -eq 0 ]
