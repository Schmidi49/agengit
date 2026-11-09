#!/usr/bin/env bash
# tests/shell/test_patch_id.sh

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

echo "--- Running Shell Unit Tests: agengit patch-id ---"

# Test Case 1: Compute patch-id from diff output
OUTPUT=$(cd "$TEST_REPO_DIR" && git diff HEAD~1 HEAD | "$AGENGIT_BIN" patch-id 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit patch-id exit code"

# Test Case 2: Stable patch-id mode (--stable)
OUTPUT=$(cd "$TEST_REPO_DIR" && git diff HEAD~1 HEAD | "$AGENGIT_BIN" patch-id --stable 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit patch-id --stable exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
