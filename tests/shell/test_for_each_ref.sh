#!/usr/bin/env bash
# tests/shell/test_for_each_ref.sh

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

echo "--- Testing agengit for-each-ref ---"

# Test 1: List all heads refs
OUT_HEADS=$("$AGENGIT_BIN" for-each-ref refs/heads/ 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "for-each-ref refs/heads/ exit code"
assert_contains "$OUT_HEADS" "refs/heads/main" "for-each-ref output contains refs/heads/main"

# Test 2: Custom format for branch short names
OUT_FMT=$("$AGENGIT_BIN" for-each-ref --format="%(refname:short)" refs/heads/ 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "for-each-ref format option exit code"
assert_contains "$OUT_FMT" "main" "for-each-ref format output contains main"

# Test 3: List tag refs
OUT_TAGS=$("$AGENGIT_BIN" for-each-ref refs/tags/ 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "for-each-ref refs/tags/ exit code"
assert_contains "$OUT_TAGS" "refs/tags/v1.0.0" "for-each-ref output contains refs/tags/v1.0.0"

[ "$TEST_FAILED" -eq 0 ]
