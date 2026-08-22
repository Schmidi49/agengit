@echo off
:: tests/cmd/test_cherry.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\test_cherry_out.txt"

echo --- Testing agengit cherry ---

cd /d "%TEST_REPO_DIR%"

:: Test 1: cherry between main and dev/feature-1
"%AGENGIT_BIN%" cherry main dev/feature-1 > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "cherry main dev/feature-1 exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "+" "cherry output contains '+' sign for unmerged commit"

:: Test 2: Verbose cherry (-v)
"%AGENGIT_BIN%" cherry -v main dev/feature-1 > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "cherry -v exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "Implement feature 1" "cherry -v contains commit message"

:: Test 3: cherry on identical ref (main main)
"%AGENGIT_BIN%" cherry main main > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "cherry main main exit code"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
