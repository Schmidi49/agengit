#!/usr/bin/env bash
# tests/shell/test_diff_tree.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../harness/assert.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
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

cd "$TEST_REPO_DIR" || exit 1

echo "--- Testing agengit diff-tree ---"

# Test 1: diff-tree HEAD
OUT_HEAD=$("$AGENGIT_BIN" diff-tree HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "diff-tree HEAD exit code"

# Test 2: Recursive diff-tree (-r)
OUT_R=$("$AGENGIT_BIN" diff-tree -r HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "diff-tree -r HEAD exit code"

# Test 3: diff-tree with patch output (-p)
OUT_P=$("$AGENGIT_BIN" diff-tree -p HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "diff-tree -p HEAD exit code"

[ "$TEST_FAILED" -eq 0 ]
