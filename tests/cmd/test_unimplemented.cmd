@echo off
:: tests/cmd/test_unimplemented.cmd - Windows Batch tests for agengit unimplemented subcommands failing closed
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\agengit_unimpl_test_%RANDOM%.log"

echo --- Running Windows CMD Unit Tests: agengit unimplemented subcommands ---

for %%C in (commit reset merge fetch pull clone init) do (
    "%AGENGIT_BIN%" -C "%TEST_REPO_DIR%" %%C > "%LOGFILE%" 2>&1
    set STATUS=!ERRORLEVEL!
    call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "Unimplemented command %%C exits with 1"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
