@echo off
:: tests/cmd/test_rev_list.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"

cd /d "%TEST_REPO_DIR%"

echo --- Testing agengit rev-list ---

:: Test 1: Count commits in HEAD
"%AGENGIT_BIN%" rev-list --count HEAD > "%TEMP%\test_rev_list_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "rev-list --count HEAD exit code"

:: Test 2: Limit commits with -n 1
"%AGENGIT_BIN%" rev-list -n 1 HEAD > "%TEMP%\test_rev_list_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "rev-list -n 1 HEAD exit code"

:: Test 3: List commits with --max-count=2
"%AGENGIT_BIN%" rev-list --max-count=2 HEAD > "%TEMP%\test_rev_list_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "rev-list --max-count=2 HEAD exit code"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
