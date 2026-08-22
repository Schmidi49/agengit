@echo off
:: tests/cmd/test_merge_base.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
set "TEMP=Z:\tmp"
set "TMP=Z:\tmp"
if not defined AGENGIT_BIN set AGENGIT_BIN=%~dp0..\..\build-wine\Release\agengit.exe

cd /d "%TEST_REPO_DIR%"

echo --- Testing agengit merge-base ---

:: Test 1: merge-base between main and dev/feature-1
"%AGENGIT_BIN%" merge-base main dev/feature-1 > "%TEMP%\test_merge_base_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "merge-base main dev/feature-1 exit code"

:: Test 2: merge-base --is-ancestor dev/merged-feature main
"%AGENGIT_BIN%" merge-base --is-ancestor dev/merged-feature main > "%TEMP%\test_merge_base_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "merge-base --is-ancestor dev/merged-feature main exit code"

:: Test 3: merge-base --octopus main dev/feature-1 dev-bugfix-2
"%AGENGIT_BIN%" merge-base --octopus main dev/feature-1 dev-bugfix-2 > "%TEMP%\test_merge_base_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "merge-base --octopus exit code"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
