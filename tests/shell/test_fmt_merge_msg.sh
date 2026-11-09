#!/usr/bin/env bash
# tests/shell/test_fmt_merge_msg.sh

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

echo "--- Running Shell Unit Tests: agengit fmt-merge-msg ---"

# Test Case 1: Format merge message from stdin
OUTPUT=$(cd "$TEST_REPO_DIR" && printf "0000000000000000000000000000000000000000\tnot-for-merge\tbranch 'dev/feature-1' of .\n" | "$AGENGIT_BIN" fmt-merge-msg 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit fmt-merge-msg exit code"

# Test Case 2: Custom log message limit (-m / --message)
OUTPUT=$(cd "$TEST_REPO_DIR" && printf "0000000000000000000000000000000000000000\tnot-for-merge\tbranch 'dev/feature-1' of .\n" | "$AGENGIT_BIN" fmt-merge-msg -m "Merge branch dev/feature-1" 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit fmt-merge-msg -m exit code"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
