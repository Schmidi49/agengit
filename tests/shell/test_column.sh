#!/usr/bin/env bash
# tests/shell/test_column.sh

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

echo "--- Running Shell Unit Tests: agengit column ---"

# Test Case 1: Column mode (--mode=column)
OUTPUT=$(cd "$TEST_REPO_DIR" && printf "item1\nitem2\nitem3\n" | "$AGENGIT_BIN" column --mode=column 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit column --mode=column exit code"
assert_contains "$OUTPUT" "item1" "agengit column output check"

# Test Case 2: Row mode (--mode=row)
OUTPUT=$(cd "$TEST_REPO_DIR" && printf "item1\nitem2\nitem3\n" | "$AGENGIT_BIN" column --mode=row 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit column --mode=row exit code"
assert_contains "$OUTPUT" "item1" "agengit column row output check"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
