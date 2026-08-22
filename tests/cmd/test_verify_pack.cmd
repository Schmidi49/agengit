@echo off
:: tests/cmd/test_verify_pack.cmd
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
call "%SCRIPT_DIR%..\harness\assert.cmd"

if not defined TEST_REPO_DIR set "TEST_REPO_DIR=Z:\tmp\agengit_test_repo"
if not defined AGENGIT_BIN set "AGENGIT_BIN=Z:\workspace\build-wine\Release\agengit.exe"
if not defined TEMP set "TEMP=Z:\tmp"
set "LOGFILE=%TEMP%\test_verify_pack_out.txt"

echo --- Testing agengit verify-pack ---

cd /d "%TEST_REPO_DIR%"

git repack -a -d >nul 2>&1

set "IDX_FILE="
for %%F in (.git\objects\pack\*.idx) do set "IDX_FILE=%%F"

if defined IDX_FILE (
    "%AGENGIT_BIN%" verify-pack "!IDX_FILE!" > "%LOGFILE%" 2>&1
    set STATUS=!ERRORLEVEL!
    call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "verify-pack exit code"

    "%AGENGIT_BIN%" verify-pack -v "!IDX_FILE!" > "%LOGFILE%" 2>&1
    set STATUS=!ERRORLEVEL!
    call "%SCRIPT_DIR%..\harness\assert.cmd" assert_eq "0" "!STATUS!" "verify-pack -v exit code"
    goto :done

echo   [FAIL] No pack index file found
set /a TEST_FAILED+=1

:done
if exist "%LOGFILE%" del "%LOGFILE%"

if %TEST_FAILED% gtr 0 exit /b 1
exit /b 0
