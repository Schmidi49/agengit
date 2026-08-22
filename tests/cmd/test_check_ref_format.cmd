@echo off
:: tests/cmd/test_check_ref_format.cmd

call "%~dp0..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
if not defined TMP set "TMP=Z:\tmp"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
        set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"

echo --- Running CMD Unit Tests: agengit check-ref-format ---

pushd "%TEST_REPO_DIR%"

:: Test Case 1: Validate full ref path (refs/heads/main)
"%AGENGIT_BIN%" check-ref-format refs/heads/main >nul 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit check-ref-format refs/heads/main exit code"

:: Test Case 2: Validate branch name (--branch main)
"%AGENGIT_BIN%" check-ref-format --branch main >nul 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit check-ref-format --branch main exit code"

:: Test Case 3: Normalize ref format (--normalize refs/heads/main)
"%AGENGIT_BIN%" check-ref-format --normalize refs/heads/main > "%TEMP%\test_check_ref_fmt_out.txt" 2>&1
set STATUS=%errorlevel%
call "%~dp0..\harness\assert.cmd" assert_eq "0" "%STATUS%" "agengit check-ref-format --normalize exit code"
call
if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
