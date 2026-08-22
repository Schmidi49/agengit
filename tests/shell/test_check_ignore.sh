#!/usr/bin/env bash
# tests/shell/test_check_ignore.sh

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

echo "--- Running Shell Unit Tests: agengit check-ignore ---"

# Test Case 1: Check ignored file path (matches *.log in .gitignore)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" check-ignore test.log 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit check-ignore test.log exit code"
assert_contains "$OUTPUT" "test.log" "agengit check-ignore output check"

# Test Case 2: Verbose mode (-v) showing matching rule
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" check-ignore -v test.log 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit check-ignore -v exit code"
assert_contains "$OUTPUT" ".gitignore" "agengit check-ignore -v output check"

# Test Case 3: Check multiple files including ignored file
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" check-ignore test.log README.md 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit check-ignore multiple files exit code"
assert_contains "$OUTPUT" "test.log" "agengit check-ignore multiple files output check"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
