#!/usr/bin/env bash
# tests/shell/test_merge_base.sh

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

echo "--- Testing agengit merge-base ---"

# Test 1: merge-base between main and dev/feature-1
OUT_MB=$("$AGENGIT_BIN" merge-base main dev/feature-1 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "merge-base main dev/feature-1 exit code"
if [[ "$OUT_MB" =~ ^[0-9a-fA-F]{40}$ ]]; then
    echo -e "  \033[0;32m[PASS]\033[0m merge-base main dev/feature-1 returns valid 40-char SHA"
else
    echo -e "  \033[0;31m[FAIL]\033[0m merge-base returned invalid SHA: '$OUT_MB'"
    TEST_FAILED=$((TEST_FAILED + 1))
fi

# Test 2: merge-base --is-ancestor dev/merged-feature main
"$AGENGIT_BIN" merge-base --is-ancestor dev/merged-feature main 2>&1
STATUS=$?
assert_status 0 "$STATUS" "merge-base --is-ancestor dev/merged-feature main exit code"

# Test 3: merge-base --octopus main dev/feature-1 dev-bugfix-2
OUT_OCT=$("$AGENGIT_BIN" merge-base --octopus main dev/feature-1 dev-bugfix-2 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "merge-base --octopus exit code"

[ "$TEST_FAILED" -eq 0 ]
