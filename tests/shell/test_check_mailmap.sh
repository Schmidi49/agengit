#!/usr/bin/env bash
# tests/shell/test_check_mailmap.sh

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

echo "--- Running Shell Unit Tests: agengit check-mailmap ---"

# Test Case 1: Canonicalize contact address passed as argument
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" check-mailmap "Test Bot <testbot@agengit.local>" 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit check-mailmap exit code"
assert_contains "$OUTPUT" "Test Bot" "agengit check-mailmap output check"

# Test Case 2: Canonicalize custom user address argument
OUTPUT=$(cd "$TEST_REPO_DIR" && "$AGENGIT_BIN" check-mailmap "Custom User <user@example.com>" 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit check-mailmap custom address exit code"
assert_contains "$OUTPUT" "user@example.com" "agengit check-mailmap custom output check"

# Test Case 3: Canonicalize contact via stdin
OUTPUT=$(cd "$TEST_REPO_DIR" && echo "Stdin User <stdin@example.com>" | "$AGENGIT_BIN" check-mailmap --stdin 2>&1)
STATUS=$?
assert_status 0 "$STATUS" "agengit check-mailmap --stdin exit code"
assert_contains "$OUTPUT" "stdin@example.com" "agengit check-mailmap --stdin output check"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
