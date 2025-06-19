#!/bin/bash

# Start the GIST Shiny application on port 4964

echo "🚀 Starting GIST Shiny application on port 4964..."

# Change to the script directory
cd "$(dirname "$0")"

# Run the Shiny app
Rscript -e "shiny::runApp(port = 4964, host = '127.0.0.1', launch.browser = FALSE)"

# Alternative: If you want to keep the process running in the background
# nohup Rscript -e "shiny::runApp(port = 4964, host = '127.0.0.1', launch.browser = FALSE)" > shiny.log 2>&1 &