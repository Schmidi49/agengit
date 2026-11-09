#!/usr/bin/env bash
# tests/shell/test_shortlog.sh

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

echo "--- Running Shell Unit Tests: agengit shortlog ---"

# Test Case 1: Summary shortlog (-s)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" shortlog -s HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit shortlog -s exit code"
assert_contains "$OUTPUT" "Test Bot" "agengit shortlog -s output check"

# Test Case 2: Number of commits sort (-n)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" shortlog -n HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit shortlog -n exit code"

# Test Case 3: Email format (-e)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" shortlog -e HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit shortlog -e exit code"
assert_contains "$OUTPUT" "testbot@agengit.local" "agengit shortlog -e output check"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
