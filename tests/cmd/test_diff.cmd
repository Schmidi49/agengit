@echo off
:: tests/cmd/test_diff.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"

echo --- Running CMD Unit Tests: agengit diff ---

pushd "%TEST_REPO_DIR%"

:: Test Case 1: Working tree diff
"%AGENGIT_BIN%" diff >nul 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit diff exit code"

:: Test Case 2: Diff between revisions (HEAD~1 HEAD)
"%AGENGIT_BIN%" diff HEAD~1 HEAD >nul 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit diff HEAD~1 HEAD exit code"

:: Test Case 3: Diff stat format (--stat)
"%AGENGIT_BIN%" diff --stat HEAD~1 HEAD >nul 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit diff --stat exit code"

popd

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
