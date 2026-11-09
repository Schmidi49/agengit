@echo off
:: tests/cmd/test_merge_tree.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"

cd /d "%TEST_REPO_DIR%"

echo --- Testing agengit merge-tree ---

:: Test 1: merge-tree between main and dev/feature-1
"%AGENGIT_BIN%" merge-tree main dev/feature-1 > "%TEMP%\test_merge_tree_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "merge-tree main dev/feature-1 exit code"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
