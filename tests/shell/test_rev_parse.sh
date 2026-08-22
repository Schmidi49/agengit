#!/usr/bin/env bash
# tests/shell/test_rev_parse.sh

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

echo "--- Testing agengit rev-parse ---"

# Test 1: Resolve HEAD commit SHA
OUT_REV=$("$AGENGIT_BIN" rev-parse HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "rev-parse HEAD exit code"
if [[ "$OUT_REV" =~ ^[0-9a-fA-F]{40}$ ]]; then
    echo -e "  \033[0;32m[PASS]\033[0m rev-parse HEAD returns valid 40-char SHA"
else
    echo -e "  \033[0;31m[FAIL]\033[0m rev-parse HEAD invalid SHA output: '$OUT_REV'"
    TEST_FAILED=$((TEST_FAILED + 1))
fi

# Test 2: Check inside work tree
OUT_TREE=$("$AGENGIT_BIN" rev-parse --is-inside-work-tree 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "rev-parse --is-inside-work-tree exit code"
assert_contains "$OUT_TREE" "true" "rev-parse --is-inside-work-tree returns true"

# Test 3: Abbreviated ref for HEAD
OUT_REF=$("$AGENGIT_BIN" rev-parse --abbrev-ref HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "rev-parse --abbrev-ref HEAD exit code"
assert_contains "$OUT_REF" "main" "rev-parse --abbrev-ref HEAD returns main"

[ "$TEST_FAILED" -eq 0 ]
