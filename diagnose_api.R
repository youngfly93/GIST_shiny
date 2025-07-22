# AI API 诊断工具
# 帮助诊断和解决API连接问题

cat("🔍 GIST AI API 诊断工具\n")
cat("=======================\n\n")

# 加载必要的库
if (!requireNamespace("httr", quietly = TRUE)) {
  cat("❌ httr包未安装，请运行: install.packages('httr')\n")
  stop("缺少必要的包")
}

if (!requireNamespace("jsonlite", quietly = TRUE)) {
  cat("❌ jsonlite包未安装，请运行: install.packages('jsonlite')\n")
  stop("缺少必要的包")
}

library(httr)
library(jsonlite)

# 步骤1: 检查.env文件
cat("📁 检查配置文件\n")
cat("================\n")

env_file <- ".env"
if (file.exists(env_file)) {
  cat("✅ .env文件存在\n")
  
  # 读取并手动加载环境变量
  env_lines <- readLines(env_file, encoding = "UTF-8")
  for (line in env_lines) {
    if (grepl("^[A-Z_]+=", line) && !grepl("^#", line)) {
      parts <- strsplit(line, "=", fixed = TRUE)[[1]]
      if (length(parts) >= 2) {
        key <- parts[1]
        value <- paste(parts[2:length(parts)], collapse = "=")
        do.call(Sys.setenv, setNames(list(value), key))
      }
    }
  }
  
} else {
  cat("❌ .env文件不存在，请创建配置文件\n")
  stop("缺少配置文件")
}

# 步骤2: 检查环境变量
cat("\n🔧 检查环境变量\n")
cat("================\n")

api_key <- Sys.getenv("OPENROUTER_API_KEY", "")
api_url <- Sys.getenv("OPENROUTER_API_URL", "https://openrouter.ai/api/v1/chat/completions")
api_model <- Sys.getenv("OPENROUTER_MODEL", "google/gemini-2.5-flash")
use_openrouter <- Sys.getenv("USE_OPENROUTER", "true")

cat("📋 配置信息:\n")
cat("- USE_OPENROUTER:", use_openrouter, "\n")
cat("- API_URL:", api_url, "\n")
cat("- API_MODEL:", api_model, "\n")

if (api_key == "") {
  cat("❌ OPENROUTER_API_KEY 未设置\n")
  stop("API密钥未配置")
} else {
  cat("- API_KEY: ", substr(api_key, 1, 8), "...(", nchar(api_key), "字符)\n")
}

# 步骤3: 验证API密钥格式
cat("\n🔑 验证API密钥格式\n")
cat("===================\n")

if (!grepl("^sk-or-v1-", api_key)) {
  cat("❌ API密钥格式错误 - 应以 'sk-or-v1-' 开头\n")
  cat("💡 请检查是否复制了完整的密钥\n")
} else if (nchar(api_key) < 50) {
  cat("⚠️ API密钥长度可能过短 (", nchar(api_key), "字符)\n")
  cat("💡 完整的OpenRouter密钥通常有60+字符\n")
} else {
  cat("✅ API密钥格式正确\n")
}

# 步骤4: 测试网络连接
cat("\n🌐 测试网络连接\n")
cat("================\n")

cat("🔗 测试连接到:", api_url, "\n")

tryCatch({
  # 构建测试请求
  test_body <- list(
    model = api_model,
    messages = list(list(
      role = "user",
      content = list(list(
        type = "text",
        text = "测试连接"
      ))
    )),
    max_tokens = 10
  )
  
  # 发送请求
  response <- POST(
    url = api_url,
    add_headers(
      "Content-Type" = "application/json",
      "Authorization" = paste("Bearer", api_key),
      "HTTP-Referer" = "https://github.com/your-username/GIST_shiny",
      "X-Title" = "GIST Analysis Tool"
    ),
    body = toJSON(test_body, auto_unbox = TRUE),
    encode = "raw",
    timeout(10)
  )
  
  status <- status_code(response)
  cat("📊 响应状态码:", status, "\n")
  
  if (status == 200) {
    cat("✅ API连接成功！\n")
    cat("🎉 您的配置正确，AI功能应该可以正常工作\n")
    
    # 尝试解析响应
    response_text <- content(response, "text", encoding = "UTF-8")
    result <- fromJSON(response_text)
    if ("choices" %in% names(result) && length(result$choices) > 0) {
      cat("✅ API响应格式正确\n")
    }
    
  } else if (status == 401) {
    cat("❌ 认证失败 (401)\n")
    cat("🔍 可能的原因:\n")
    cat("   1. API密钥无效或已过期\n")
    cat("   2. 账户余额不足\n")
    cat("   3. 密钥权限不够\n")
    cat("\n💡 解决方案:\n")
    cat("   1. 登录 https://openrouter.ai 检查账户状态\n")
    cat("   2. 检查账户余额\n")
    cat("   3. 生成新的API密钥\n")
    cat("   4. 确认密钥有正确的权限\n")
    
    # 尝试显示错误详情
    error_content <- content(response, "text", encoding = "UTF-8")
    if (nchar(error_content) > 0) {
      cat("\n📄 错误详情:\n")
      cat(error_content, "\n")
    }
    
  } else if (status == 403) {
    cat("❌ 访问被拒绝 (403)\n")
    cat("💡 可能是API配额或权限问题\n")
    
  } else if (status == 404) {
    cat("❌ API端点未找到 (404)\n")
    cat("💡 请检查API URL是否正确\n")
    
  } else if (status == 429) {
    cat("⏰ 请求过于频繁 (429)\n")
    cat("💡 请稍后再试\n")
    
  } else {
    cat("❌ 意外的响应状态:", status, "\n")
    error_content <- content(response, "text", encoding = "UTF-8")
    if (nchar(error_content) > 0) {
      cat("📄 错误详情:\n")
      cat(error_content, "\n")
    }
  }
  
}, error = function(e) {
  cat("❌ 网络连接失败\n")
  cat("📄 错误信息:", e$message, "\n")
  
  if (grepl("timeout", e$message, ignore.case = TRUE)) {
    cat("💡 连接超时 - 检查网络连接或防火墙设置\n")
  } else if (grepl("SSL|TLS", e$message, ignore.case = TRUE)) {
    cat("💡 SSL/TLS错误 - 可能是证书或网络安全问题\n")
  } else if (grepl("proxy", e$message, ignore.case = TRUE)) {
    cat("💡 代理问题 - 检查代理设置\n")
  }
})

# 步骤5: 提供解决建议
cat("\n🔧 解决建议\n")
cat("===========\n")
cat("1. 如果是401错误，请访问 https://openrouter.ai 检查:\n")
cat("   - 账户是否有效\n")
cat("   - API密钥是否正确\n")
cat("   - 账户余额是否充足\n\n")

cat("2. 更新API密钥的步骤:\n")
cat("   - 登录 https://openrouter.ai\n")
cat("   - 导航到 API Keys 页面\n")
cat("   - 生成新的密钥\n")
cat("   - 复制新密钥到 .env 文件中的 OPENROUTER_API_KEY\n\n")

cat("3. 如果问题持续，请:\n")
cat("   - 重启 R 会话\n")
cat("   - 重启 Shiny 应用\n")
cat("   - 检查网络连接\n")
cat("   - 联系技术支持\n\n")

cat("🎯 诊断完成！\n")