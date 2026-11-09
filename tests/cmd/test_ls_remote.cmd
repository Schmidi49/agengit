@echo off
:: tests/cmd/test_ls_remote.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"

echo --- Running CMD Unit Tests: agengit ls-remote ---

pushd "%TEST_REPO_DIR%"

:: Test Case 1: Query configured remote URL (--get-url origin)
"%AGENGIT_BIN%" ls-remote --get-url origin > "%TEMP%\test_ls_remote_out.txt" 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit ls-remote --get-url origin exit code"
call
if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
