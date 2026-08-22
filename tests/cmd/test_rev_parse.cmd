@echo off
:: tests/cmd/test_rev_parse.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\test_rev_parse_out.txt"

echo --- Testing agengit rev-parse ---

cd /d "%TEST_REPO_DIR%"

:: Test 1: Resolve HEAD commit SHA
"%AGENGIT_BIN%" rev-parse HEAD > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "rev-parse HEAD exit code"

:: Test 2: Check inside work tree
"%AGENGIT_BIN%" rev-parse --is-inside-work-tree > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "rev-parse --is-inside-work-tree exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "true" "rev-parse --is-inside-work-tree returns true"

:: Test 3: Abbreviated ref for HEAD
"%AGENGIT_BIN%" rev-parse --abbrev-ref HEAD > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "rev-parse --abbrev-ref HEAD exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "main" "rev-parse --abbrev-ref HEAD returns main"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
