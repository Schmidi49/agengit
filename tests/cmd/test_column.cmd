@echo off
:: tests/cmd/test_column.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"

echo --- Running CMD Unit Tests: agengit column ---

pushd "%TEST_REPO_DIR%"

:: Prepare sample input file
(
  echo item1
  echo item2
  echo item3
) > "%TEMP%\test_column_input.txt"

:: Test Case 1: Column mode (--mode=column)
"%AGENGIT_BIN%" column --mode=column < "%TEMP%\test_column_input.txt" > "%TEMP%\test_column_out.txt" 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit column --mode=column exit code"
call
if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
