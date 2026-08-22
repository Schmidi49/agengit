#!/usr/bin/env bash
# tests/shell/test_show.sh

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

echo "--- Running Shell Unit Tests: agengit show ---"

# Test Case 1: Show HEAD commit
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" show HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit show HEAD exit code"
assert_contains "$OUTPUT" "commit" "agengit show HEAD output check"

# Test Case 2: Show commit with stat format (--stat)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" show --stat HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit show --stat HEAD exit code"

# Test Case 3: Show tag object (v1.0.0)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" show v1.0.0 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit show v1.0.0 exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
