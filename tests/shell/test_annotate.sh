#!/usr/bin/env bash
# tests/shell/test_annotate.sh

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

echo "--- Running Shell Unit Tests: agengit annotate ---"

# Test Case 1: Standard annotate on file
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" annotate README.md 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit annotate README.md exit code"
assert_contains "$OUTPUT" "Test Bot" "agengit annotate README.md output check"

# Test Case 2: Line range annotate (-L 1,1)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" annotate -L 1,1 README.md 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit annotate -L 1,1 exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
