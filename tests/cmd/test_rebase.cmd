@echo off
:: tests/cmd/test_rebase.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
set "TEMP=Z:\tmp"
set "TMP=Z:\tmp"
if not exist "%TEST_REPO_DIR%" if exist "/tmp/agengit_test_repo" set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
set "TEMP=Z:\tmp"
set "TMP=Z:\tmp"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not exist "%AGENGIT_BIN%" if exist "%SCRIPT_DIR%..\..\build-wine\Release\agengit.exe" set "AGENGIT_BIN=%SCRIPT_DIR%..\..\build-wine\Release\agengit.exe"

echo --- Running CMD Unit Tests: agengit rebase policy ---

pushd "%TEST_REPO_DIR%"

set "LOGFILE=%TEST_REPO_DIR%\agengit_rebase_%RANDOM%.log"

:: Test Case 1: DENY rebase main
"%AGENGIT_BIN%" rebase main > "%LOGFILE%" 2>&1
set "STATUS=!ERRORLEVEL!"
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "agengit rebase main exit code"
call
if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0

:check_contains
set "LOG_PATH=%~1"
set "NEEDLE=%~2"
set "DESC=%~3"
set "FOUND="
if exist "%LOG_PATH%" (
    for /f "usebackq delims=" %%L in ("%LOG_PATH%") do (
        set "LINE=%%L"
        if not "!LINE!"=="!LINE:%NEEDLE%=!" set "FOUND=1"
if defined FOUND (
    echo   [PASS] %DESC%
    goto :eof
echo   [FAIL] %DESC%
set /a TEST_FAILED+=1
goto :eof
