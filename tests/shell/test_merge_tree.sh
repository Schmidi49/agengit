#!/usr/bin/env bash
# tests/shell/test_merge_tree.sh

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

echo "--- Testing agengit merge-tree ---"

# Test 1: merge-tree between main and dev/feature-1
OUT_MT=$("$AGENGIT_BIN" merge-tree main dev/feature-1 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "merge-tree main dev/feature-1 exit code"

# Test 2: 3-argument merge-tree with explicit base
BASE_COMMIT=$(git merge-base main dev/feature-1)
OUT_MT3=$("$AGENGIT_BIN" merge-tree "$BASE_COMMIT" main dev/feature-1 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "merge-tree with base-commit exit code"

[ "$TEST_FAILED" -eq 0 ]
