#!/usr/bin/env Rscript

# 启动AI版本的GIST Shiny应用
# 使用默认环境变量启用AI功能

cat("========================================\n")
cat("   启动GIST Shiny应用 - AI版本\n")
cat("   端口: 4964\n")
cat("   AI功能: 启用\n")
cat("========================================\n")

# 确保AI功能启用（使用默认值）
cat("AI功能已启用\n")

# 验证环境变量设置
cat("环境变量验证:\n")
cat("ENABLE_AI_ANALYSIS =", Sys.getenv("ENABLE_AI_ANALYSIS", "true"), "\n")
cat("USE_OPENROUTER =", Sys.getenv("USE_OPENROUTER", "true"), "\n")

cat("正在启动应用...\n")

# 启动Shiny应用
shiny::runApp(
  port = 4964,
  host = "127.0.0.1",
  launch.browser = FALSE
)
