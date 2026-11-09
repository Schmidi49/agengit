@echo off
:: tests/cmd/test_diff_tree.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"

cd /d "%TEST_REPO_DIR%"

echo --- Testing agengit diff-tree ---

:: Test 1: diff-tree HEAD
"%AGENGIT_BIN%" diff-tree HEAD > "%TEMP%\test_diff_tree_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "diff-tree HEAD exit code"

:: Test 2: Recursive diff-tree (-r)
"%AGENGIT_BIN%" diff-tree -r HEAD > "%TEMP%\test_diff_tree_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "diff-tree -r HEAD exit code"

:: Test 3: diff-tree with patch output (-p)
"%AGENGIT_BIN%" diff-tree -p HEAD > "%TEMP%\test_diff_tree_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "diff-tree -p HEAD exit code"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
