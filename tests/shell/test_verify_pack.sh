#!/usr/bin/env bash
# tests/shell/test_verify_pack.sh

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

echo "--- Testing agengit verify-pack ---"

# Ensure repository has a pack file index
git repack -a -d >/dev/null 2>&1
IDX_FILE=$(find .git/objects/pack -name "pack-*.idx" | head -n 1)

if [ -n "$IDX_FILE" ] && [ -f "$IDX_FILE" ]; then
    # Test 1: Standard verify-pack
    OUT_VP=$("$AGENGIT_BIN" verify-pack "$IDX_FILE" 2>&1)
    STATUS=$?
    assert_status 0 "$STATUS" "verify-pack exit code"

    # Test 2: Verbose verify-pack (-v)
    OUT_VPV=$("$AGENGIT_BIN" verify-pack -v "$IDX_FILE" 2>&1)
    STATUS=$?
    assert_status 0 "$STATUS" "verify-pack -v exit code"
    assert_contains "$OUT_VPV" "non delta" "verify-pack -v output contains object count summary"
else
    echo -e "  \033[0;31m[FAIL]\033[0m No pack index file found after git repack"
    TEST_FAILED=$((TEST_FAILED + 1))
fi

[ "$TEST_FAILED" -eq 0 ]
