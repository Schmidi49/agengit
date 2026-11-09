@echo off
:: tests/cmd/test_show_ref.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\test_show_ref_out.txt"

echo --- Testing agengit show-ref ---

cd /d "%TEST_REPO_DIR%"

:: Test 1: Show heads refs
"%AGENGIT_BIN%" show-ref --heads > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "show-ref --heads exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "refs/heads/main" "show-ref --heads contains refs/heads/main"

:: Test 2: Show specific ref
"%AGENGIT_BIN%" show-ref refs/heads/main > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "show-ref refs/heads/main exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "refs/heads/main" "show-ref refs/heads/main contains ref path"

:: Test 3: Show tags refs
"%AGENGIT_BIN%" show-ref --tags > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "show-ref --tags exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "refs/tags/v1.0.0" "show-ref --tags contains refs/tags/v1.0.0"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
