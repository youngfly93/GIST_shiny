#!/usr/bin/env Rscript

# Run the GIST Shiny application on port 4964
# This script can be called from the GIST_web project

# Set working directory to the app directory
setwd(dirname(sys.frame(1)$ofile))

# Run the Shiny app on port 4964
shiny::runApp(
  appDir = ".",
  port = 4964,
  host = "127.0.0.1",
  launch.browser = FALSE
)