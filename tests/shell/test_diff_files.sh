#!/usr/bin/env bash
# tests/shell/test_diff_files.sh

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

echo "--- Testing agengit diff-files ---"

# Test 1: Standard diff-files on clean working directory
OUT_DIFF=$("$AGENGIT_BIN" diff-files 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "diff-files clean repo exit code"

# Test 2: diff-files with -p flag
OUT_P=$("$AGENGIT_BIN" diff-files -p 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "diff-files -p exit code"

# Test 3: diff-files with --name-only flag
OUT_NAME=$("$AGENGIT_BIN" diff-files --name-only 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "diff-files --name-only exit code"

[ "$TEST_FAILED" -eq 0 ]
