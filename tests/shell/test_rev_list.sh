#!/usr/bin/env bash
# tests/shell/test_rev_list.sh

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

echo "--- Testing agengit rev-list ---"

# Test 1: Count commits in HEAD
OUT_COUNT=$("$AGENGIT_BIN" rev-list --count HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "rev-list --count HEAD exit code"
if [[ "$OUT_COUNT" =~ ^[0-9]+$ ]] && [ "$OUT_COUNT" -gt 0 ]; then
    echo -e "  \033[0;32m[PASS]\033[0m rev-list --count HEAD returns positive count ($OUT_COUNT)"
else
    echo -e "  \033[0;31m[FAIL]\033[0m rev-list --count HEAD output invalid: '$OUT_COUNT'"
    TEST_FAILED=$((TEST_FAILED + 1))
fi

# Test 2: Limit commits with -n 1
OUT_ONE=$("$AGENGIT_BIN" rev-list -n 1 HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "rev-list -n 1 HEAD exit code"
LINE_COUNT=$(echo "$OUT_ONE" | grep -c -E '^[0-9a-fA-F]{40}$')
assert_eq "1" "$LINE_COUNT" "rev-list -n 1 HEAD returns exactly 1 commit SHA"

# Test 3: List commits with --max-count=2
OUT_TWO=$("$AGENGIT_BIN" rev-list --max-count=2 HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "rev-list --max-count=2 HEAD exit code"

[ "$TEST_FAILED" -eq 0 ]
