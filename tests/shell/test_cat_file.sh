#!/usr/bin/env bash
# tests/shell/test_cat_file.sh

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

echo "--- Testing agengit cat-file ---"

# Test 1: Check object type of HEAD
OUT_TYPE=$("$AGENGIT_BIN" cat-file -t HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "cat-file -t HEAD exit code"
assert_contains "$OUT_TYPE" "commit" "cat-file -t HEAD returns commit"

# Test 2: Check object size of HEAD
OUT_SIZE=$("$AGENGIT_BIN" cat-file -s HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "cat-file -s HEAD exit code"
if [[ "$OUT_SIZE" =~ ^[0-9]+$ ]]; then
    echo -e "  \033[0;32m[PASS]\033[0m cat-file -s HEAD returns valid numeric size"
else
    echo -e "  \033[0;31m[FAIL]\033[0m cat-file -s HEAD invalid size: '$OUT_SIZE'"
    TEST_FAILED=$((TEST_FAILED + 1))
fi

# Test 3: Pretty-print content of HEAD
OUT_PRETTY=$("$AGENGIT_BIN" cat-file -p HEAD 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "cat-file -p HEAD exit code"
assert_contains "$OUT_PRETTY" "tree" "cat-file -p HEAD output contains tree object ref"

[ "$TEST_FAILED" -eq 0 ]
