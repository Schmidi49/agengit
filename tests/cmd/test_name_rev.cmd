@echo off
:: tests/cmd/test_name_rev.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\test_name_rev_out.txt"

echo --- Testing agengit name-rev ---

cd /d "%TEST_REPO_DIR%"

:: Test 1: name-rev --name-only main
"%AGENGIT_BIN%" name-rev --name-only main > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "name-rev --name-only main exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "main" "name-rev --name-only main output contains main"

:: Test 2: name-rev main
"%AGENGIT_BIN%" name-rev main > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "name-rev main exit code"

:: Test 3: name-rev --tags v1.0.0
"%AGENGIT_BIN%" name-rev --tags v1.0.0 > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "name-rev --tags v1.0.0 exit code"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
