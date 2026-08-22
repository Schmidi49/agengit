@echo off
:: tests/cmd/test_check_ignore.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"

echo --- Running CMD Unit Tests: agengit check-ignore ---

pushd "%TEST_REPO_DIR%"

:: Test Case 1: Check ignored file path (matches *.log in .gitignore)
"%AGENGIT_BIN%" check-ignore test.log > "%TEMP%\test_check_ignore_out.txt" 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit check-ignore test.log exit code"
call
if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
