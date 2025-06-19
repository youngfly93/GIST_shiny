@echo off
echo Starting GIST Shiny application on port 4964...

REM Change to the script directory
cd /d "%~dp0"

REM Run the Shiny app
Rscript -e "shiny::runApp(port = 4964, host = '127.0.0.1', launch.browser = FALSE)"

REM Keep window open if there's an error
if errorlevel 1 pause