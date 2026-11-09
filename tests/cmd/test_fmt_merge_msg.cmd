@echo off
:: tests/cmd/test_fmt_merge_msg.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\fmt_mm_%RANDOM%.txt"

echo --- Running CMD Unit Tests: agengit fmt-merge-msg ---

cd /d "%TEST_REPO_DIR%"

:: Test Case 1: Format merge message from stdin
(echo 0000000000000000000000000000000000000000	not-for-merge	branch 'dev/feature-1' of .) | "%AGENGIT_BIN%" fmt-merge-msg > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "agengit fmt-merge-msg exit code"

:: Test Case 2: Custom log message limit (-m / --message)
(echo 0000000000000000000000000000000000000000	not-for-merge	branch 'dev/feature-1' of .) | "%AGENGIT_BIN%" fmt-merge-msg -m "Merge branch dev/feature-1" > "%LOGFILE%" 2>&1
set STATUS=!ERRORLEVEL!
call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "agengit fmt-merge-msg -m exit code"

if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
