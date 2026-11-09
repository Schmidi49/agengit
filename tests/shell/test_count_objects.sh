#!/usr/bin/env bash
# tests/shell/test_count_objects.sh

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

echo "--- Running Shell Unit Tests: agengit count-objects ---"

# Test Case 1: Standard count-objects
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" count-objects 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit count-objects exit code"
assert_contains "$OUTPUT" "objects" "agengit count-objects output check"

# Test Case 2: Verbose mode (-v)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" count-objects -v 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit count-objects -v exit code"
assert_contains "$OUTPUT" "count:" "agengit count-objects -v output check"

# Test Case 3: Human readable format (-H)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" count-objects -H 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit count-objects -H exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
