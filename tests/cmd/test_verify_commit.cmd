@echo off
:: tests/cmd/test_verify_commit.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\test_verify_commit_out.txt"

echo --- Testing agengit verify-commit ---

cd /d "%TEST_REPO_DIR%"

:: Test 1: verify-commit on HEAD (unsigned commit returns exit status 1)
"%AGENGIT_BIN%" verify-commit HEAD > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "verify-commit on unsigned HEAD exit code"

:: Test 2: verify-commit -v HEAD
"%AGENGIT_BIN%" verify-commit -v HEAD > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "verify-commit -v on unsigned HEAD exit code"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
