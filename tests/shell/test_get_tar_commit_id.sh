#!/usr/bin/env bash
# tests/shell/test_get_tar_commit_id.sh

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

echo "--- Testing agengit get-tar-commit-id ---"

EXPECTED_HEAD=$(git rev-parse HEAD)

# Test 1: Extract commit ID from git archive tar stream for HEAD
OUT_ID=$(git archive HEAD | "$AGENGIT_BIN" get-tar-commit-id 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "get-tar-commit-id HEAD archive exit code"
ACTUAL_SHA=$(echo "$OUT_ID" | awk '{print $1}')
assert_eq "$EXPECTED_HEAD" "$ACTUAL_SHA" "get-tar-commit-id returns matching HEAD SHA"

# Test 2: Extract commit ID from git archive for tag v1.0.0
EXPECTED_TAG=$(git rev-parse v1.0.0^{commit})
OUT_TAG_ID=$(git archive v1.0.0 | "$AGENGIT_BIN" get-tar-commit-id 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "get-tar-commit-id v1.0.0 archive exit code"
ACTUAL_TAG_SHA=$(echo "$OUT_TAG_ID" | awk '{print $1}')
assert_eq "$EXPECTED_TAG" "$ACTUAL_TAG_SHA" "get-tar-commit-id returns matching v1.0.0 SHA"

[ "$TEST_FAILED" -eq 0 ]
