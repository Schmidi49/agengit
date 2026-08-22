#!/usr/bin/env bash
# tests/shell/test_branch.sh

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
echo "--- Running Shell Unit Tests: agengit branch policy ---"

# Ensure repository is on main branch
(cd "$TEST_REPO_DIR" && git checkout main >/dev/null 2>&1)

# Test Case 1: ALLOW branch -a
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" branch -a 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit branch -a exit code"
assert_contains "$OUTPUT" "main" "agengit branch -a output check"

# Test Case 2: ALLOW branch -r
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" branch -r 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit branch -r exit code"

# Test Case 3: ALLOW branch --list
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" branch --list 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit branch --list exit code"

# Test Case 4: ALLOW creating dev/foo
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" branch dev/foo 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit branch dev/foo exit code"

# Test Case 5: ALLOW deleting merged dev/merged-feature
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" branch -d dev/merged-feature 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit branch -d dev/merged-feature exit code"

# Test Case 6: DENY deleting unmerged dev/unmerged-feature
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" branch -d dev/unmerged-feature 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit branch -d dev/unmerged-feature exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit branch -d dev/unmerged-feature denied output"

# Test Case 7: DENY deleting main branch
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" branch -d main 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit branch -d main exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit branch -d main denied output"

# Test Case 8: DENY creating non-dev branch (e.g., feature/invalid)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" branch feature/invalid 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit branch feature/invalid exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit branch feature/invalid denied output"

# Test Case 9: DENY force-deleting main branch (-D main)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" branch -D main 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit branch -D main exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit branch -D main denied output"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
