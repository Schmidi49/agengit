@echo off
:: tests/cmd/test_check_mailmap.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"

echo --- Running CMD Unit Tests: agengit check-mailmap ---

pushd "%TEST_REPO_DIR%"

:: Test Case 1: Canonicalize contact address passed as argument
"%AGENGIT_BIN%" check-mailmap "Test Bot <testbot@agengit.local>" > "%TEMP%\test_check_mailmap_out.txt" 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit check-mailmap exit code"
call
if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
