@echo off
:: tests/cmd/test_show_branch.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\test_show_branch_out.txt"

echo --- Testing agengit show-branch ---

cd /d "%TEST_REPO_DIR%"

:: Test 1: Show branch info for main
"%AGENGIT_BIN%" show-branch main > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "show-branch main exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "main" "show-branch main output contains main"

:: Test 2: Show branch with topo ordering flag
"%AGENGIT_BIN%" show-branch --topo main dev/feature-1 > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "show-branch --topo exit code"

:: Test 3: Show branch with --more option
"%AGENGIT_BIN%" show-branch --more=1 main > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "show-branch --more=1 main exit code"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
