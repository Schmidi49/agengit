@echo off
:: tests/cmd/test_patch_id.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"

echo --- Running CMD Unit Tests: agengit patch-id ---

pushd "%TEST_REPO_DIR%"

:: Generate sample diff file using git
git diff HEAD~1 HEAD > "%TEMP%\test_patch_id_diff.txt" 2>&1

:: Test Case 1: Compute patch-id from diff input
"%AGENGIT_BIN%" patch-id < "%TEMP%\test_patch_id_diff.txt" > "%TEMP%\test_patch_id_out.txt" 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit patch-id exit code"

:: Test Case 2: Stable patch-id mode (--stable)
"%AGENGIT_BIN%" patch-id --stable < "%TEMP%\test_patch_id_diff.txt" >nul 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit patch-id --stable exit code"

popd

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
