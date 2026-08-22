#!/usr/bin/env bash
# tests/shell/test_help.sh

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

echo "--- Running Shell Unit Tests: agengit help ---"

# Test Case 1: Standard help command
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" help 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit help exit code"
assert_contains "$OUTPUT" "git" "agengit help output check"

# Test Case 2: Guide list help (-g)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" help -g 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit help -g exit code"

# Test Case 3: List all commands (-a)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" help -a 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit help -a exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
