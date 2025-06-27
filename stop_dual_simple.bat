@echo off
echo ========================================
echo    GIST Shiny Dual Stop Script
echo ========================================
echo.
echo Stopping both AI and Non-AI versions...
echo.

REM Kill processes on ports 4964 and 4966
echo Checking for processes on ports 4964 and 4966...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":4964"') do (
    echo Killing AI version process %%a on port 4964...
    taskkill /PID %%a /F >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":4966"') do (
    echo Killing Non-AI version process %%a on port 4966...
    taskkill /PID %%a /F >nul 2>&1
)

echo.
echo Both applications have been stopped.
echo.
pause
