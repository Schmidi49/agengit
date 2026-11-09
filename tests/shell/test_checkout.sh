#!/usr/bin/env bash
# tests/shell/test_checkout.sh

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
echo "--- Running Shell Unit Tests: agengit checkout policy ---"

# Ensure repository is on clean main branch before testing
(cd "$TEST_REPO_DIR" && git checkout main >/dev/null 2>&1 && git reset --hard HEAD >/dev/null 2>&1)

# Test Case 1: ALLOW checkout -b dev/new-branch
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" checkout -b dev/new-branch 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit checkout -b dev/new-branch exit code"

# Test Case 2: ALLOW clean checkout main
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" checkout main 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit clean checkout main exit code"

# Test Case 3: DENY checkout -b feature/invalid
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" checkout -b feature/invalid 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit checkout -b feature/invalid exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit checkout -b feature/invalid denied output"

# Test Case 4: DENY checkout when working tree is dirty (uncommitted changes)
echo "uncommitted change" > "$TEST_REPO_DIR/dirty_file.txt"
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" checkout main 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit checkout on dirty repo exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit checkout on dirty repo denied output"
rm -f "$TEST_REPO_DIR/dirty_file.txt"

# Test Case 5: DENY bypass attempts like checkout -B master
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" checkout -B master 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit checkout -B master exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit checkout -B master denied output"

# Test Case 6: DENY bypass attempts like checkout -b release/1.0
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" checkout -b release/1.0 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit checkout -b release/1.0 exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit checkout -b release/1.0 denied output"

# Return repository to clean main branch
(cd "$TEST_REPO_DIR" && git checkout main >/dev/null 2>&1 && git reset --hard HEAD >/dev/null 2>&1)

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
