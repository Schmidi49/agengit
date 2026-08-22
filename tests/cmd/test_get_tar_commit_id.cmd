@echo off
:: tests/cmd/test_get_tar_commit_id.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"

cd /d "%TEST_REPO_DIR%"

echo --- Testing agengit get-tar-commit-id ---

:: Test 1: Extract commit ID from git archive tar stream for HEAD
git archive HEAD | "%AGENGIT_BIN%" get-tar-commit-id > "%TEMP%\test_tar_commit_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "get-tar-commit-id HEAD archive exit code"

:: Test 2: Extract commit ID from git archive for tag v1.0.0
git archive v1.0.0 | "%AGENGIT_BIN%" get-tar-commit-id > "%TEMP%\test_tar_commit_out.txt" 2>&1
set STATUS=%ERRORLEVEL%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "get-tar-commit-id v1.0.0 archive exit code"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
