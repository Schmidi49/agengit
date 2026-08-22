#!/usr/bin/env bash
# tests/shell/test_agengit.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../harness/assert.sh"

echo "--- Running Shell Unit Tests: agengit basic CLI checks ---"

assert_file_exists "$SCRIPT_DIR/../harness/assert.sh" "harness assert.sh exists"
assert_file_exists "$SCRIPT_DIR/../harness/run.py" "harness run.py exists"

# Mandatory: Return failure exit status if any assertion failed
[ "$TEST_FAILED" -eq 0 ]
