@echo off
:: tests/cmd/test_global_flags.cmd - Windows Batch tests for agengit global flags, option smuggling, and malformed flags
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\agengit_gf_test_%RANDOM%.txt"

echo --- Running Windows CMD Unit Tests: agengit global flags ---

:: 1. Valid Global Flags
"%AGENGIT_BIN%" -C "%TEST_REPO_DIR%" status > "%LOGFILE%" 2>&1
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "%ERRORLEVEL%" "agengit -C status succeeds"

"%AGENGIT_BIN%" -C "%TEST_REPO_DIR%" -c user.name=TestUser status > "%LOGFILE%" 2>&1
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "%ERRORLEVEL%" "agengit -c status succeeds"

"%AGENGIT_BIN%" --git-dir="%TEST_REPO_DIR%\.git" --work-tree="%TEST_REPO_DIR%" status > "%LOGFILE%" 2>&1
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "%ERRORLEVEL%" "agengit --git-dir status succeeds"

:: 2. Option Smuggling Attempts
"%AGENGIT_BIN%" -C "%TEST_REPO_DIR%" rebase > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "Option smuggling -C rebase exits with 1"

"%AGENGIT_BIN%" -C "%TEST_REPO_DIR%" -c user.name=Test rebase > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "Option smuggling -c rebase exits with 1"

"%AGENGIT_BIN%" --git-dir="%TEST_REPO_DIR%\.git" rebase > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "Option smuggling --git-dir rebase exits with 1"

"%AGENGIT_BIN%" --work-tree="%TEST_REPO_DIR%" --git-dir="%TEST_REPO_DIR%\.git" rebase > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "Option smuggling --work-tree rebase exits with 1"

"%AGENGIT_BIN%" -C "%TEST_REPO_DIR%" --namespace=testns rebase > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "Option smuggling --namespace rebase exits with 1"

:: 3. Malformed Global Flags
"%AGENGIT_BIN%" -C > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "Malformed agengit -C exits with 1"

"%AGENGIT_BIN%" -c > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "Malformed agengit -c exits with 1"

"%AGENGIT_BIN%" --git-dir > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "Malformed agengit --git-dir exits with 1"

"%AGENGIT_BIN%" --work-tree > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "Malformed agengit --work-tree exits with 1"

"%AGENGIT_BIN%" --namespace > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "1" "!STATUS!" "Malformed agengit --namespace exits with 1"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0