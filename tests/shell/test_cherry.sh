#!/usr/bin/env bash
# tests/shell/test_cherry.sh

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

echo "--- Testing agengit cherry ---"

# Test 1: cherry between main and dev/feature-1
OUT_CHERRY=$("$AGENGIT_BIN" cherry main dev/feature-1 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "cherry main dev/feature-1 exit code"
assert_contains "$OUT_CHERRY" "+" "cherry output contains '+' sign for unmerged commit"

# Test 2: Verbose cherry (-v)
OUT_V=$("$AGENGIT_BIN" cherry -v main dev/feature-1 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "cherry -v exit code"
assert_contains "$OUT_V" "Implement feature 1" "cherry -v contains commit message"

# Test 3: cherry on identical ref (main main)
OUT_SAME=$("$AGENGIT_BIN" cherry main main 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "cherry main main exit code"

[ "$TEST_FAILED" -eq 0 ]
