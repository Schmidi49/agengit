#!/usr/bin/env bash
# tests/shell/test_verify_tag.sh

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

cd "$TEST_REPO_DIR" || exit 1

echo "--- Testing agengit verify-tag ---"

# Test 1: verify-tag with -v flag on tag ref
OUT_V=$("$AGENGIT_BIN" verify-tag -v v1.0.1-release 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "verify-tag -v exit code"
assert_contains "$OUT_V" "no signature found" "verify-tag -v reports no signature found"

# Test 2: verify-tag with --raw flag
OUT_RAW=$("$AGENGIT_BIN" verify-tag --raw v1.0.1-release 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "verify-tag --raw exit code"
assert_contains "$OUT_RAW" "no signature found" "verify-tag --raw reports no signature found"

[ "$TEST_FAILED" -eq 0 ]
