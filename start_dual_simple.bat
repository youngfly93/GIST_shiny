@echo off
echo ========================================
echo    GIST Shiny Dual Launch Script
echo ========================================
echo.
echo Starting both AI and Non-AI versions...
echo.
echo AI Version:     http://localhost:4964
echo Non-AI Version: http://localhost:4966
echo.
echo ========================================
echo.

REM Check directory
if not exist "start_ai.R" (
    echo Error: start_ai.R not found!
    echo Please run this script from the GIST_shiny root directory.
    pause
    exit /b 1
)

REM Check and kill existing processes on ports 4964 and 4966
echo Checking for existing processes on ports 4964 and 4966...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":4964"') do (
    echo Killing process %%a on port 4964...
    taskkill /PID %%a /F >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":4966"') do (
    echo Killing process %%a on port 4966...
    taskkill /PID %%a /F >nul 2>&1
)

REM Wait for ports to be freed
timeout /t 2 /nobreak >nul

REM Start AI version
echo Starting AI version on port 4964...
start "GIST Shiny AI" cmd /k "Rscript start_ai.R"

REM Wait 3 seconds
timeout /t 3 /nobreak >nul

REM Start Non-AI version
echo Starting Non-AI version on port 4966...
start "GIST Shiny No-AI" cmd /k "Rscript start_no_ai.R"

REM Wait for startup
timeout /t 5 /nobreak >nul

echo.
echo Both applications are starting...
echo.
echo Opening browsers...
start http://localhost:4964
timeout /t 2 /nobreak >nul
start http://localhost:4966

echo.
echo Both applications should now be running!
echo Check the separate command windows for logs.
echo.
echo To stop: Close the command windows or use Ctrl+C in each window.
echo.
pause
