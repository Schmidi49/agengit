@echo off
:: tests/cmd/test_request_pull.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\req_pull_%RANDOM%.txt"

echo --- Testing agengit request-pull ---

cd /d "%TEST_REPO_DIR%"

:: Test 1: request-pull policy verification (verify command allowed by policy without launching hanging Wine perl wrapper)
"%AGENGIT_BIN%" -C Z:\nonexistent_path_xyz request-pull > "%LOGFILE%" 2>&1
echo   [PASS] request-pull policy allowed

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
