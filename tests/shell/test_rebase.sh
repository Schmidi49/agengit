#!/usr/bin/env bash
# tests/shell/test_rebase.sh

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
echo "--- Running Shell Unit Tests: agengit rebase policy ---"

# Test Case 1: DENY rebase main
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" rebase main 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit rebase main exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit rebase main denied output"
assert_contains "$OUTPUT" "Rebasing is a destructive history-rewriting operation" "agengit rebase explanation check"

# Test Case 2: DENY rebase --onto main
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" rebase --onto main 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit rebase --onto main exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit rebase --onto main denied output"

# Test Case 3: DENY agengit -C . rebase
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" -C . rebase 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit -C . rebase exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit -C . rebase denied output"

# Test Case 4: DENY interactive rebase (rebase -i)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" rebase -i HEAD~1 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit rebase -i HEAD~1 exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit rebase -i denied output"

# Test Case 5: DENY rebase --abort
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" rebase --abort 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit rebase --abort exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit rebase --abort denied output"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
