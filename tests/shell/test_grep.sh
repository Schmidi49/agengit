#!/usr/bin/env bash
# tests/shell/test_grep.sh

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

echo "--- Running Shell Unit Tests: agengit grep ---"

# Test Case 1: Search string in tracked files
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" grep "Agengit" 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit grep exit code"
assert_contains "$OUTPUT" "README.md" "agengit grep output check"

# Test Case 2: Line numbers mode (-n)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" grep -n "Agengit" 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit grep -n exit code"
assert_contains "$OUTPUT" "1:" "agengit grep -n output check"

# Test Case 3: Case-insensitive search (-i)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" grep -i "agengit" 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit grep -i exit code"
assert_contains "$OUTPUT" "README.md" "agengit grep -i output check"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
