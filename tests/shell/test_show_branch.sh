#!/usr/bin/env bash
# tests/shell/test_show_branch.sh

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

echo "--- Testing agengit show-branch ---"

# Test 1: Show branch info for main
OUT_MAIN=$("$AGENGIT_BIN" show-branch main 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "show-branch main exit code"
assert_contains "$OUT_MAIN" "main" "show-branch main output contains main"

# Test 2: Show branch with topo ordering flag
OUT_TOPO=$("$AGENGIT_BIN" show-branch --topo main dev/feature-1 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "show-branch --topo exit code"
assert_contains "$OUT_TOPO" "main" "show-branch --topo output contains main"

# Test 3: Show branch with --more option
OUT_MORE=$("$AGENGIT_BIN" show-branch --more=1 main 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "show-branch --more=1 main exit code"

[ "$TEST_FAILED" -eq 0 ]
