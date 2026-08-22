#!/usr/bin/env bash
# tests/shell/test_whatchanged.sh

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

echo "--- Running Shell Unit Tests: agengit whatchanged ---"

# Test Case 1: Standard whatchanged with commit count (-n 1)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" whatchanged -n 1 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit whatchanged -n 1 exit code"
assert_contains "$OUTPUT" "commit" "agengit whatchanged output check"

# Test Case 2: Oneline format (--oneline)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" whatchanged --oneline -n 2 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit whatchanged --oneline exit code"

# Test Case 3: Diffstat format (--stat)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" whatchanged --stat -n 1 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit whatchanged --stat exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
