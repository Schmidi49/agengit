#!/usr/bin/env bash
# tests/shell/test_describe.sh

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

echo "--- Running Shell Unit Tests: agengit describe ---"

# Test Case 1: Describe matching tags (--tags)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" describe --tags 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit describe --tags exit code"
assert_contains "$OUTPUT" "v1.0" "agengit describe --tags output check"

# Test Case 2: Describe always fallback (--always)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" describe --always 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit describe --always exit code"

# Test Case 3: Custom hash abbreviation length (--abbrev=4)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" describe --tags --abbrev=4 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit describe --abbrev=4 exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
