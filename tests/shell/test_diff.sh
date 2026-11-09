#!/usr/bin/env bash
# tests/shell/test_diff.sh

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

echo "--- Running Shell Unit Tests: agengit diff ---"

# Test Case 1: Working tree diff
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" diff 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit diff exit code"

# Test Case 2: Diff between revisions (HEAD~1 HEAD)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" diff HEAD~1 HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit diff HEAD~1 HEAD exit code"

# Test Case 3: Diff stat format (--stat)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" diff --stat HEAD~1 HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit diff --stat exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
