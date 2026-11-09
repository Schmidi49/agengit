#!/usr/bin/env bash
# tests/shell/test_ls_remote.sh

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

echo "--- Running Shell Unit Tests: agengit ls-remote ---"

# Test Case 1: Query configured remote URL (--get-url origin)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" ls-remote --get-url origin 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit ls-remote --get-url origin exit code"
assert_contains "$OUTPUT" "agengit-testing-sandbox.git" "agengit ls-remote --get-url output check"

# Test Case 2: Query default remote URL (--get-url)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" ls-remote --get-url 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit ls-remote --get-url exit code"

# Test Case 3: Query symref or remote url
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" ls-remote --get-url origin 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit ls-remote --get-url repeat exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
