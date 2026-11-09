#!/usr/bin/env bash
# tests/shell/test_unimplemented.sh - Unit tests for agengit unimplemented / unapproved subcommands failing closed

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/../harness/assert.sh"

# Locate agengit executable
if [ -n "${AGENGIT_BIN:-}" ]; then
    AGENGIT="$AGENGIT_BIN"
elif command -v agengit >/dev/null 2>&1; then
    AGENGIT="agengit"
elif [ -x "$REPO_ROOT/build-host/Release/agengit" ]; then
    AGENGIT="$REPO_ROOT/build-host/Release/agengit"
elif [ -x "$REPO_ROOT/build-host/agengit" ]; then
    AGENGIT="$REPO_ROOT/build-host/agengit"
elif [ -x "$REPO_ROOT/build/Release/agengit" ]; then
    AGENGIT="$REPO_ROOT/build/Release/agengit"
elif [ -x "$REPO_ROOT/build/agengit" ]; then
    AGENGIT="$REPO_ROOT/build/agengit"
elif [ -x "/workspace/build/Release/agengit" ]; then
    AGENGIT="/workspace/build/Release/agengit"
elif [ -x "/workspace/build/agengit" ]; then
    AGENGIT="/workspace/build/agengit"
else
    AGENGIT="agengit"
fi

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

if [ ! -d "$TEST_REPO_DIR" ]; then
    "$REPO_ROOT/tests/create_test_repo.sh" "$TEST_REPO_DIR" >/dev/null 2>&1 || true
fi

echo "--- Running Shell Unit Tests: agengit unimplemented subcommands ---"

# Target unapproved subcommands to test: commit, reset, merge, fetch, pull, clone, init
UNIMPLEMENTED_CMDS=("commit" "reset" "merge" "fetch" "pull" "clone" "init")

for cmd in "${UNIMPLEMENTED_CMDS[@]}"; do
    output=$("$AGENGIT_BIN" -C "$TEST_REPO_DIR" "$cmd" 2>&1) || status=$?
    status=${status:-0}

    assert_status 1 "$status" "Unimplemented subcommand 'agengit $cmd' exits with status 1"
    assert_contains "$output" "#### COMMAND NOT IMPLEMENTED ####" "Unimplemented subcommand 'agengit $cmd' produces '#### COMMAND NOT IMPLEMENTED ####'"
    
    unset status
done

# Mandatory failure tracking exit code
[ "$TEST_FAILED" -eq 0 ]
