#!/usr/bin/env bash
# tests/shell/test_name_rev.sh

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

echo "--- Testing agengit name-rev ---"

# Test 1: name-rev --name-only main
OUT_NAME=$("$AGENGIT_BIN" name-rev --name-only main 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "name-rev --name-only main exit code"
assert_contains "$OUT_NAME" "main" "name-rev --name-only main output contains main"

# Test 2: name-rev main
OUT_HEAD=$("$AGENGIT_BIN" name-rev main 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "name-rev main exit code"
assert_contains "$OUT_HEAD" "main" "name-rev main output contains main"

# Test 3: name-rev --tags v1.0.0
OUT_TAG=$("$AGENGIT_BIN" name-rev --tags v1.0.0 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "name-rev --tags v1.0.0 exit code"

[ "$TEST_FAILED" -eq 0 ]
