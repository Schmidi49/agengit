#!/usr/bin/env bash
# tests/shell/test_check_attr.sh

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

echo "--- Running Shell Unit Tests: agengit check-attr ---"

# Test Case 1: Check all attributes (--all)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" check-attr --all README.md 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit check-attr --all exit code"

# Test Case 2: Check specific attribute (text)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" check-attr text README.md 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit check-attr text exit code"
assert_contains "$OUTPUT" "README.md" "agengit check-attr text output check"

# Test Case 3: Short flag for all (-a)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" check-attr -a README.md 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit check-attr -a exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
