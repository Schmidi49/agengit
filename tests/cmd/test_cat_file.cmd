@echo off
:: tests/cmd/test_cat_file.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\test_cat_file_out.txt"

echo --- Testing agengit cat-file ---

cd /d "%TEST_REPO_DIR%"

:: Test 1: Check object type of HEAD
"%AGENGIT_BIN%" cat-file -t HEAD > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "cat-file -t HEAD exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "commit" "cat-file -t HEAD returns commit"

:: Test 2: Check object size of HEAD
"%AGENGIT_BIN%" cat-file -s HEAD > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "cat-file -s HEAD exit code"

:: Test 3: Pretty-print content of HEAD
"%AGENGIT_BIN%" cat-file -p HEAD > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "cat-file -p HEAD exit code"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_contains "%LOGFILE%" "tree" "cat-file -p HEAD contains tree"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
