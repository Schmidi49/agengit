#!/usr/bin/env bash
# tests/shell/test_verify_commit.sh

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

echo "--- Testing agengit verify-commit ---"

# Test 1: verify-commit on HEAD (unsigned commit returns status 1)
OUT_V=$("$AGENGIT_BIN" verify-commit HEAD 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "verify-commit on unsigned HEAD exit code"

# Test 2: verify-commit with -v flag
OUT_V2=$("$AGENGIT_BIN" verify-commit -v HEAD 2>&1)
STATUS2=$?
assert_status 1 "$STATUS2" "verify-commit -v on unsigned HEAD exit code"

[ "$TEST_FAILED" -eq 0 ]
