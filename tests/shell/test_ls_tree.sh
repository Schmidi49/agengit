#!/usr/bin/env bash
# tests/shell/test_ls_tree.sh

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

echo "--- Running Shell Unit Tests: agengit ls-tree ---"

# Test Case 1: Standard ls-tree on HEAD
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" ls-tree HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit ls-tree HEAD exit code"
assert_contains "$OUTPUT" "README.md" "agengit ls-tree HEAD output check"

# Test Case 2: Recursive ls-tree (-r HEAD)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" ls-tree -r HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit ls-tree -r HEAD exit code"
assert_contains "$OUTPUT" "src/main.txt" "agengit ls-tree -r HEAD output check"

# Test Case 3: Name-only mode (--name-only HEAD)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" ls-tree --name-only HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit ls-tree --name-only HEAD exit code"
assert_contains "$OUTPUT" "README.md" "agengit ls-tree --name-only HEAD output check"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
