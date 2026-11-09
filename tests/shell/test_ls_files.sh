#!/usr/bin/env bash
# tests/shell/test_ls_files.sh

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

echo "--- Running Shell Unit Tests: agengit ls-files ---"

# Test Case 1: Standard ls-files
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" ls-files 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit ls-files exit code"
assert_contains "$OUTPUT" "README.md" "agengit ls-files output check"

# Test Case 2: Stage mode (--stage)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" ls-files --stage 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit ls-files --stage exit code"
assert_contains "$OUTPUT" "100644" "agengit ls-files --stage output check"

# Test Case 3: Modified files mode (-m)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" ls-files -m 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit ls-files -m exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
