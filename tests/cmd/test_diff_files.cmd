@echo off
:: tests/cmd/test_diff_files.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"

cd /d "%TEST_REPO_DIR%"

echo --- Testing agengit diff-files ---

:: Test 1: Standard diff-files
"%AGENGIT_BIN%" diff-files > "%TEMP%\test_diff_files_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "diff-files clean repo exit code"

:: Test 2: diff-files -p
"%AGENGIT_BIN%" diff-files -p > "%TEMP%\test_diff_files_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "diff-files -p exit code"

:: Test 3: diff-files --name-only
"%AGENGIT_BIN%" diff-files --name-only > "%TEMP%\test_diff_files_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "diff-files --name-only exit code"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
