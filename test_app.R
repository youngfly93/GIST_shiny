#!/usr/bin/env Rscript

# 简单的测试启动脚本，绕过renv问题

# 设置工作目录
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# 直接加载必要的文件
tryCatch({
  source("global.R")
  source("ui.R") 
  source("server.R")
  
  # 启动应用
  shiny::shinyApp(ui, server, options = list(
    port = 3838,
    host = "0.0.0.0",
    launch.browser = FALSE
  ))
}, error = function(e) {
  cat("Error:", e$message, "\n")
  traceback()
})
