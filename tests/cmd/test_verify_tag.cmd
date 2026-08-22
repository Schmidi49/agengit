@echo off
:: tests/cmd/test_verify_tag.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\test_verify_tag_out.txt"

echo --- Testing agengit verify-tag ---

cd /d "%TEST_REPO_DIR%"

:: Test 1: verify-tag -v v1.0.1-release
"%AGENGIT_BIN%" verify-tag -v v1.0.1-release > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "verify-tag -v exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "no signature found" "verify-tag -v reports no signature found"

:: Test 2: verify-tag --raw v1.0.1-release
"%AGENGIT_BIN%" verify-tag --raw v1.0.1-release > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "verify-tag --raw exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "no signature found" "verify-tag --raw reports no signature found"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
