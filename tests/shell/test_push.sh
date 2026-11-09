#!/usr/bin/env bash
# tests/shell/test_push.sh

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
echo "--- Running Shell Unit Tests: agengit push policy ---"

# Test Case 1: ALLOW push from dev/feature-1 branch matching origin (--dry-run)
(cd "$TEST_REPO_DIR" && git checkout dev/feature-1 >/dev/null 2>&1)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" push --dry-run 2>&1)
STATUS=$?
assert_contains "$OUTPUT" "fatal:" "agengit push on dev/feature-1 allowed by policy"

# Test Case 2: DENY push from main branch
(cd "$TEST_REPO_DIR" && git checkout main >/dev/null 2>&1)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" push 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit push from main exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit push from main denied output"

# Test Case 3: DENY push from non-dev branch (feature/invalid-name)
(cd "$TEST_REPO_DIR" && git checkout feature/invalid-name >/dev/null 2>&1)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" push 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit push from feature/invalid-name exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit push from feature/invalid-name denied output"

# Test Case 4: DENY push from dev/ahead branch (ahead of origin)
(cd "$TEST_REPO_DIR" && git checkout dev/ahead >/dev/null 2>&1)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" push 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit push from dev/ahead exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit push from dev/ahead denied output"

# Test Case 5: DENY flag spoofing attempts like push -f from dev/ahead
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" push -f 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit push -f from dev/ahead exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit push -f from dev/ahead denied output"

# Test Case 6: DENY flag spoofing attempts like push --delete from main
(cd "$TEST_REPO_DIR" && git checkout main >/dev/null 2>&1)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" push --delete origin dev/feature-1 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "agengit push --delete from main exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit push --delete from main denied output"

# Test Case 7: DENY agengit -C repo push from main
OUTPUT="$("$AGENGIT_BIN" -C "$TEST_REPO_DIR" push 2>&1)"
STATUS=$?
assert_status 1 "$STATUS" "agengit -C repo push from main exit code"
assert_contains "$OUTPUT" "PERMISSION DENIED" "agengit -C repo push from main denied output"

# Return repository to main branch
(cd "$TEST_REPO_DIR" && git checkout main >/dev/null 2>&1)

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
