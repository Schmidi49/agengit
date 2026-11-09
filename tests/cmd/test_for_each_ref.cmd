@echo off
:: tests/cmd/test_for_each_ref.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\test_for_each_ref_out.txt"

echo --- Testing agengit for-each-ref ---

cd /d "%TEST_REPO_DIR%"

:: Test 1: List all heads refs
"%AGENGIT_BIN%" for-each-ref refs/heads/ > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "for-each-ref refs/heads/ exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "refs/heads/main" "for-each-ref output contains refs/heads/main"

:: Test 2: Custom format for branch short names
"%AGENGIT_BIN%" for-each-ref --format="%%(refname:short)" refs/heads/ > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "for-each-ref format option exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "main" "for-each-ref format output contains main"

:: Test 3: List tag refs
"%AGENGIT_BIN%" for-each-ref refs/tags/ > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "for-each-ref refs/tags/ exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "refs/tags/v1.0.0" "for-each-ref output contains refs/tags/v1.0.0"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
