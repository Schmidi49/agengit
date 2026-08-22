#!/usr/bin/env bash
# tests/shell/test_var.sh

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

echo "--- Running Shell Unit Tests: agengit var ---"

# Test Case 1: Query GIT_AUTHOR_IDENT
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" var GIT_AUTHOR_IDENT 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit var GIT_AUTHOR_IDENT exit code"
assert_contains "$OUTPUT" "Test Bot" "agengit var GIT_AUTHOR_IDENT output check"

# Test Case 2: Query GIT_COMMITTER_IDENT
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" var GIT_COMMITTER_IDENT 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit var GIT_COMMITTER_IDENT exit code"
assert_contains "$OUTPUT" "Test Bot" "agengit var GIT_COMMITTER_IDENT output check"

# Test Case 3: List all variables (-l)
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" var -l 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit var -l exit code"
assert_contains "$OUTPUT" "GIT_" "agengit var -l output check"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
