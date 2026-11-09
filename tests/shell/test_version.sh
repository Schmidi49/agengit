#!/usr/bin/env bash
# tests/shell/test_version.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../harness/assert.sh"

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

echo "--- Running Shell Unit Tests: agengit version ---"

# Test Case 1: Standard version output
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" version 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit version exit code"
assert_contains "$OUTPUT" "git version" "agengit version output check"

# Test Case 2: Version with build options (--build-options)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" version --build-options 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit version --build-options exit code"
assert_contains "$OUTPUT" "git version" "agengit version --build-options output check"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
