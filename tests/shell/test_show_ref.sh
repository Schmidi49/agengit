#!/usr/bin/env bash
# tests/shell/test_show_ref.sh

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

echo "--- Testing agengit show-ref ---"

# Test 1: Show heads refs
OUT_HEADS=$("$AGENGIT_BIN" show-ref --heads 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "show-ref --heads exit code"
assert_contains "$OUT_HEADS" "refs/heads/main" "show-ref --heads contains refs/heads/main"

# Test 2: Show specific ref
OUT_MAIN=$("$AGENGIT_BIN" show-ref refs/heads/main 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "show-ref refs/heads/main exit code"
assert_contains "$OUT_MAIN" "refs/heads/main" "show-ref refs/heads/main contains ref path"

# Test 3: Show tags refs
OUT_TAGS=$("$AGENGIT_BIN" show-ref --tags 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "show-ref --tags exit code"
assert_contains "$OUT_TAGS" "refs/tags/v1.0.0" "show-ref --tags contains refs/tags/v1.0.0"

[ "$TEST_FAILED" -eq 0 ]
