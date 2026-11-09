#!/usr/bin/env bash
# tests/shell/test_request_pull.sh

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

echo "--- Testing agengit request-pull ---"

# Test 1: Generate pull request summary from tag v1.0.0
OUT_RP=$("$AGENGIT_BIN" request-pull v1.0.0 . main 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "request-pull v1.0.0 local main exit code"

# Test 2: request-pull with patch diff (-p) flag
OUT_P=$("$AGENGIT_BIN" request-pull -p v1.0.0 . main 2>&1)
STATUS=$?
assert_status 1 "$STATUS" "request-pull -p exit code"

[ "$TEST_FAILED" -eq 0 ]
