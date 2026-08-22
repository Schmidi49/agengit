@echo off
:: tests/cmd/test_status.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\agengit_status_%RANDOM%.log"

echo --- Running CMD Unit Tests: agengit status ---

pushd "%TEST_REPO_DIR%"

:: Test Case 1: Standard status command
"%AGENGIT_BIN%" status > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "agengit status exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "On branch" "agengit status output check"

:: Test Case 2: Short status format (-s)
"%AGENGIT_BIN%" status -s > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit status -s exit code"

:: Test Case 3: Porcelain status format (--porcelain)
"%AGENGIT_BIN%" status --porcelain > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit status --porcelain exit code"

if exist "%LOGFILE%" del "%LOGFILE%"
popd

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
