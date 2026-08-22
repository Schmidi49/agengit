@echo off
:: tests/cmd/test_diff_index.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"

cd /d "%TEST_REPO_DIR%"

echo --- Testing agengit diff-index ---

:: Test 1: Compare working tree against HEAD
"%AGENGIT_BIN%" diff-index HEAD > "%TEMP%\test_diff_index_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "diff-index HEAD exit code"

:: Test 2: Compare staged/cached index against HEAD
"%AGENGIT_BIN%" diff-index --cached HEAD > "%TEMP%\test_diff_index_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "diff-index --cached HEAD exit code"

:: Test 3: diff-index with patch output (-p)
"%AGENGIT_BIN%" diff-index -p HEAD > "%TEMP%\test_diff_index_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "diff-index -p HEAD exit code"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
