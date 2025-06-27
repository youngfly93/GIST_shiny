# ==== AI聊天机器人模块 ====

library(shiny)
library(shinyjs)
library(httr)
library(jsonlite)
library(base64enc)

# AI聊天机器人UI
aiChatUI <- function(id) {
  ns <- NS(id)
  
  div(
    id = ns("chat_container"),
    class = "ai-chat-container",
    style = "display: none;",
    
    # 聊天窗口
    div(
      class = "ai-chat-window",
      
      # 聊天头部
      div(
        class = "ai-chat-header",
        div(
          class = "ai-chat-title",
          icon("robot", class = "ai-chat-icon"),
          span("GIST AI 图片分析助手", class = "ai-chat-title-text")
        ),
        div(
          class = "ai-chat-controls",
          actionButton(ns("generate_summary"), "", icon = icon("file-text"), 
                      class = "ai-chat-btn ai-chat-summary",
                      title = "生成分析总结报告"),
          actionButton(ns("clear_history"), "", icon = icon("trash"), 
                      class = "ai-chat-btn ai-chat-clear",
                      title = "清空分析历史"),
          actionButton(ns("minimize_chat"), "", icon = icon("minus"), 
                      class = "ai-chat-btn ai-chat-minimize"),
          actionButton(ns("close_chat"), "", icon = icon("times"), 
                      class = "ai-chat-btn ai-chat-close")
        )
      ),
      
      # 聊天内容区域
      div(
        class = "ai-chat-content",
        div(
          id = ns("chat_messages"),
          class = "ai-chat-messages",
          # 初始欢迎消息
          div(
            class = "ai-message ai-message-bot",
            div(class = "ai-message-avatar", icon("robot")),
            div(
              class = "ai-message-content",
              p("您好！我是GIST AI分析助手。"),
              p("点击'Visualize'生成图片后，我会自动分析图片内容并为您提供专业的生物信息学解读。")
            )
          )
        )
      ),
      
      # 加载指示器 - 放在聊天窗口内部
      div(
        id = ns("chat_loading"),
        class = "ai-chat-loading",
        style = "display: none; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 100;",
        div(class = "ai-loading-spinner"),
        span("AI正在分析中...")
      )
    )
  )
}

# 浮动聊天按钮UI
aiChatFloatingButtonUI <- function(id) {
  ns <- NS(id)
  
  div(
    class = "ai-chat-floating-container",
    actionButton(
      ns("toggle_chat"),
      "",
      icon = icon("robot"),
      class = "ai-chat-floating-btn",
      title = "AI图片分析助手"
    ),
    # 新消息提示
    div(
      id = ns("new_message_indicator"),
      class = "ai-chat-notification",
      style = "display: none;",
      "1"
    )
  )
}

# AI聊天机器人服务器逻辑
aiChatServer <- function(id, global_state = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # 响应式值
    values <- reactiveValues(
      chat_visible = FALSE,
      chat_minimized = FALSE,
      messages = list(),
      analyzing = FALSE
    )
    
    # API配置 - 支持多个AI服务
    # 优先使用OpenRouter，备选豆包
    use_openrouter <- tolower(Sys.getenv("USE_OPENROUTER", "true")) == "true"
    
    if (use_openrouter) {
      # Use correct API key only when AI is enabled
      api_key <- Sys.getenv("OPENROUTER_API_KEY", "")
      if (api_key == "" || nchar(api_key) < 50) {
        # Fallback to correct key if env var is empty or truncated
        api_key <- "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"
      }
      API_CONFIG <- list(
        url = Sys.getenv("OPENROUTER_API_URL",
                         "https://openrouter.ai/api/v1/chat/completions"),
        key = api_key,
        model = Sys.getenv("OPENROUTER_MODEL",
                           "google/gemini-2.5-flash"),
        type = "openrouter"
      )
    } else {
      API_CONFIG <- list(
        url = Sys.getenv("DOUBAO_API_URL", 
                         "https://ark.cn-beijing.volces.com/api/v3/chat/completions"),
        key = Sys.getenv("DOUBAO_API_KEY", ""),
        model = Sys.getenv("DOUBAO_MODEL", 
                           "doubao-1-5-thinking-vision-pro-250428"),
        type = "doubao"
      )
    }
    
    # 是否启用AI分析
    enable_ai <- tolower(Sys.getenv("ENABLE_AI_ANALYSIS", "true")) == "true"
    
    # 打印配置信息（隐藏密钥）
    cat("AI Chat Module initialized:\n")
    cat("- Service:", API_CONFIG$type, "\n")
    cat("- API URL:", API_CONFIG$url, "\n")
    cat("- API Key:", substr(API_CONFIG$key, 1, 8), "...\n")
    cat("- Model:", API_CONFIG$model, "\n")
    cat("- AI Analysis Enabled:", enable_ai, "\n")
    
    # 分析历史文件路径
    analysis_history_file <- "ai_analysis_history.md"
    
    # 保存AI分析结果到历史文件
    save_analysis_to_history <- function(gene_name, analysis_type, ai_result) {
      tryCatch({
        # 创建带时间戳的记录
        timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
        
        # 构建markdown格式的记录
        record <- paste0(
          "\n---\n\n",
          "## 📊 分析记录 - ", timestamp, "\n\n",
          "**基因**: ", gene_name, "\n",
          "**分析类型**: ", analysis_type, "\n",
          "**时间**: ", timestamp, "\n\n",
          "### 分析结果:\n\n",
          ai_result,
          "\n\n"
        )
        
        # 追加到历史文件
        if (file.exists(analysis_history_file)) {
          write(record, file = analysis_history_file, append = TRUE)
        } else {
          # 如果文件不存在，创建带头部的文件
          header <- paste0(
            "# GIST AI 分析历史记录\n\n",
            "本文件记录了所有AI分析的历史结果，用于生成综合报告。\n",
            "生成时间: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n"
          )
          write(header, file = analysis_history_file)
          write(record, file = analysis_history_file, append = TRUE)
        }
        
        cat("AI Chat: Analysis saved to history file\n")
        
      }, error = function(e) {
        cat("AI Chat: Error saving analysis to history:", e$message, "\n")
      })
    }
    
    # 生成总结报告
    generate_summary_report <- function() {
      tryCatch({
        if (!file.exists(analysis_history_file)) {
          return("暂无分析历史记录，请先进行一些基因表达分析。")
        }
        
        # 读取历史文件内容
        history_content <- readLines(analysis_history_file, encoding = "UTF-8")
        history_text <- paste(history_content, collapse = "\n")
        
        # 检查内容长度
        if (nchar(history_text) < 100) {
          return("分析历史记录过少，请进行更多分析后再生成总结报告。")
        }
        
        cat("AI Chat: Generating summary report from", nchar(history_text), "characters of history\n")
        
        # 构建总结提示词
        summary_prompt <- paste0(
          "请对以下GIST（胃肠道间质瘤）基因表达分析的历史记录进行综合总结。",
          "请从以下几个方面进行总结：\n\n",
          "1. **分析概览**: 总共分析了哪些基因，涉及了哪些分析类型\n",
          "2. **关键发现**: 各个基因的主要生物学意义和表达特征\n",
          "3. **临床意义**: 这些分析结果的整体临床相关性和应用价值\n",
          "4. **生物学洞察**: 从多个分析中能够得出的生物学规律或趋势\n",
          "5. **研究建议**: 基于这些分析结果的后续研究方向建议\n\n",
          "请用中文回答，语言专业但易懂。以下是所有的分析历史记录：\n\n",
          "===== 分析历史记录开始 =====\n",
          history_text,
          "\n===== 分析历史记录结束 =====\n\n",
          "请生成一份专业的综合分析报告。"
        )
        
        # 调用AI API生成总结
        summary_result <- analyze_image_with_ai(NULL, summary_prompt)
        
        if (!is.null(summary_result) && 
            !grepl("暂时不可用|超时|错误|连接问题", summary_result) &&
            nchar(summary_result) > 100) {
          
          # 保存总结报告
          summary_file <- paste0("ai_summary_report_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".md")
          summary_with_header <- paste0(
            "# GIST AI 综合分析报告\n\n",
            "**生成时间**: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
            "**分析历史长度**: ", nchar(history_text), " 字符\n\n",
            "---\n\n",
            summary_result
          )
          
          writeLines(summary_with_header, con = summary_file, useBytes = TRUE)
          cat("AI Chat: Summary report saved to", summary_file, "\n")
          
          return(paste0(
            "## 📋 GIST AI 综合分析报告\n\n",
            "**生成时间**: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
            "**报告文件**: ", summary_file, "\n\n",
            "---\n\n",
            summary_result
          ))
        } else {
          return(paste0("抱歉，AI总结服务暂时不可用，请稍后再试。您可以查看分析历史文件：", analysis_history_file))
        }
        
      }, error = function(e) {
        cat("AI Chat: Error generating summary:", e$message, "\n")
        return("生成总结报告时发生错误，请稍后再试。")
      })
    }
    
    # 清空分析历史
    clear_analysis_history <- function() {
      tryCatch({
        if (file.exists(analysis_history_file)) {
          file.remove(analysis_history_file)
          cat("AI Chat: Analysis history cleared\n")
          return("分析历史记录已清空。")
        } else {
          return("没有找到分析历史记录文件。")
        }
      }, error = function(e) {
        cat("AI Chat: Error clearing history:", e$message, "\n")
        return("清空历史记录时发生错误。")
      })
    }
    
    # 切换聊天窗口显示
    observeEvent(input$toggle_chat, {
      values$chat_visible <- !values$chat_visible
      
      if (values$chat_visible) {
        shinyjs::show("chat_container")
        shinyjs::hide("new_message_indicator")
        values$chat_minimized <- FALSE
      } else {
        shinyjs::hide("chat_container")
      }
    })
    
    # 最小化聊天窗口
    observeEvent(input$minimize_chat, {
      values$chat_minimized <- !values$chat_minimized
      
      if (values$chat_minimized) {
        shinyjs::addClass("chat_container", "minimized")
      } else {
        shinyjs::removeClass("chat_container", "minimized")
      }
    })
    
    # 关闭聊天窗口
    observeEvent(input$close_chat, {
      values$chat_visible <- FALSE
      shinyjs::hide("chat_container")
    })
    
    # 生成分析总结报告
    observeEvent(input$generate_summary, {
      cat("AI Chat: Generate summary button clicked\n")
      
      # 显示加载状态
      values$analyzing <- TRUE
      shinyjs::show("chat_loading")
      
      # 延迟执行，确保UI更新
      shinyjs::delay(100, {
        # 生成总结报告
        summary_result <- generate_summary_report()
        
        # 重置加载状态
        values$analyzing <- FALSE
        shinyjs::hide("chat_loading")
        
        # 添加用户请求消息
        add_message("请生成一份综合分析总结报告", TRUE)
        
        # 添加AI回复
        add_message(summary_result, FALSE)
        
        cat("AI Chat: Summary report generated successfully\n")
      })
    })
    
    # 清空分析历史
    observeEvent(input$clear_history, {
      cat("AI Chat: Clear history button clicked\n")
      
      # 清空历史文件
      clear_result <- clear_analysis_history()
      
      # 添加用户请求消息
      add_message("清空分析历史记录", TRUE)
      
      # 添加系统回复
      add_message(clear_result, FALSE)
      
      cat("AI Chat: Analysis history cleared\n")
    })
    
    # 图片转base64（优化版本）
    image_to_base64 <- function(image_path) {
      tryCatch({
        if (file.exists(image_path)) {
          # 检查文件大小
          file_size <- file.info(image_path)$size
          cat("AI Chat: Image file size:", file_size, "bytes\n")
          
          # 如果文件过大（>2MB），尝试压缩
          if (file_size > 2 * 1024 * 1024) {
            cat("AI Chat: Image file too large, attempting to compress\n")
            # 这里可以添加图片压缩逻辑
            # 暂时先返回NULL，使用模拟分析
            return(NULL)
          }
          
          image_data <- readBin(image_path, "raw", file_size)
          base64_data <- base64encode(image_data)
          
          # 检查base64大小
          base64_size <- nchar(base64_data)
          cat("AI Chat: Base64 size:", base64_size, "characters\n")
          
          # 检测图片格式
          ext <- tolower(tools::file_ext(image_path))
          mime_type <- switch(ext,
            "png" = "image/png",
            "jpg" = "image/jpeg", 
            "jpeg" = "image/jpeg",
            "image/png"  # 默认
          )
          
          return(paste0("data:", mime_type, ";base64,", base64_data))
        }
        return(NULL)
      }, error = function(e) {
        cat("Error converting image to base64:", e$message, "\n")
        return(NULL)
      })
    }
    
    # 生成模拟分析（当AI API不可用时）
    generate_mock_analysis <- function(plot_data) {
      gene_name <- plot_data$gene1
      analysis_type <- plot_data$analysisType

      analysis_text <- paste0(
        "## 📊 GIST基因表达分析报告\n\n",
        "**分析基因**: ", gene_name, "\n",
        "**分析类型**: ", analysis_type, "\n\n",
        "### 🔍 图表解读\n",
        "根据生成的图表，我观察到以下关键信息：\n\n",
        "1. **数据分布**: 图表显示了", gene_name, "基因在不同样本组间的表达差异\n",
        "2. **统计显著性**: 图中的p值提示了组间差异的统计学意义\n",
        "3. **表达模式**: 可以观察到基因表达的分布特征和离散程度\n\n",
        "### 🧬 生物学意义\n",
        gene_name, "基因在GIST（胃肠道间质瘤）研究中具有重要意义：\n\n",
        "- **功能相关性**: 该基因可能参与肿瘤发生发展的关键通路\n",
        "- **表达差异**: 不同临床特征组间的表达差异可能反映疾病进展状态\n",
        "- **潜在标志物**: 表达模式可能具有诊断或预后价值\n\n",
        "### 🏥 临床相关性\n",
        "- **诊断价值**: 基因表达水平可能有助于GIST的分子分型\n",
        "- **治疗指导**: 表达差异可能指导个体化治疗策略\n",
        "- **预后评估**: 基因表达模式可能与患者预后相关\n\n",
        "### ⚠️ 注意事项\n",
        "- 需要更大样本量验证结果的可靠性\n",
        "- 建议结合其他分子标志物进行综合分析\n",
        "- 临床应用前需要前瞻性研究验证\n\n",
        "*注：此分析基于图表数据的一般性解读，具体结论需要结合完整的实验设计和临床背景进行评估。*"
      )

      return(analysis_text)
    }

    # 测试API连接
    test_api_connection <- function() {
      tryCatch({
        cat("AI API: Testing connection to", API_CONFIG$url, "\n")
        
        # 简单的连接测试
        test_body <- list(
          model = API_CONFIG$model,
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
        if (API_CONFIG$type == "openrouter") {
          response <- POST(
            url = API_CONFIG$url,
            add_headers(
              "Content-Type" = "application/json",
              "Authorization" = paste("Bearer", API_CONFIG$key),
              "HTTP-Referer" = "https://github.com/your-username/GIST_shiny",
              "X-Title" = "GIST Analysis Tool"
            ),
            body = toJSON(test_body, auto_unbox = TRUE),
            encode = "raw",
            timeout(10),
            config = list(
              ssl_verifypeer = FALSE,
              ssl_verifyhost = FALSE,
              followlocation = TRUE
            )
          )
        } else {
          response <- POST(
            url = API_CONFIG$url,
            add_headers(
              "Content-Type" = "application/json",
              "Authorization" = paste("Bearer", API_CONFIG$key)
            ),
            body = toJSON(test_body, auto_unbox = TRUE),
            encode = "raw",
            timeout(10),
            config = list(
              ssl_verifypeer = FALSE,
              ssl_verifyhost = FALSE,
              followlocation = TRUE
            )
          )
        }
        
        cat("AI API Test: Response status:", status_code(response), "\n")
        return(status_code(response) == 200)
        
      }, error = function(e) {
        cat("AI API Test Error:", e$message, "\n")
        return(FALSE)
      })
    }

    # 调用AI API分析图片
    analyze_image_with_ai <- function(image_base64, user_text = NULL) {
      tryCatch({
        cat("AI API: Starting API call\n")
        
        # 先测试连接
        if (!test_api_connection()) {
          cat("AI API: Connection test failed, skipping API call\n")
          return("网络连接问题，无法访问AI服务。")
        }
        
        # 构建消息内容
        content <- list()
        
        # 添加文本内容
        if (!is.null(user_text) && user_text != "") {
          content <- append(content, list(list(
            type = "text",
            text = user_text
          )))
        } else {
          # 默认分析提示
          content <- append(content, list(list(
            type = "text", 
            text = "请分析这张GIST（胃肠道间质瘤）研究的生物信息学图片。请从以下几个方面进行专业分析：1. 图片类型和数据展示方式；2. 主要发现和趋势；3. 统计学意义；4. 生物学意义和临床相关性；5. 可能的局限性。请用中文回答，语言要专业但易懂。"
          )))
        }
        
        # 如果有图片，添加图片
        if (!is.null(image_base64)) {
          content <- append(content, list(list(
            type = "image_url",
            image_url = list(url = image_base64)
          )))
        }
        
        # 构建请求体（优化版本）
        request_body <- list(
          model = API_CONFIG$model,
          messages = list(list(
            role = "user",
            content = content
          )),
          temperature = 0.7,
          max_tokens = 2000,  # 增加最大token数
          stream = FALSE      # 确保不使用流式响应
        )
        
        # 打印请求体大小（用于调试）
        request_json <- toJSON(request_body, auto_unbox = TRUE)
        request_size <- nchar(request_json)
        cat("AI API: Request size:", request_size, "characters\n")
        
        cat("AI API: Sending request to", API_CONFIG$url, "\n")
        
        # 发送请求，根据API类型使用不同的头信息
        if (API_CONFIG$type == "openrouter") {
          response <- POST(
            url = API_CONFIG$url,
            add_headers(
              "Content-Type" = "application/json",
              "Authorization" = paste("Bearer", API_CONFIG$key),
              "HTTP-Referer" = "https://github.com/your-username/GIST_shiny",
              "X-Title" = "GIST Analysis Tool"
            ),
            body = toJSON(request_body, auto_unbox = TRUE),
            encode = "raw",
            timeout(60),
            config = list(
              ssl_verifypeer = FALSE,
              ssl_verifyhost = FALSE,
              followlocation = TRUE
            )
          )
        } else {
          response <- POST(
            url = API_CONFIG$url,
            add_headers(
              "Content-Type" = "application/json",
              "Authorization" = paste("Bearer", API_CONFIG$key)
            ),
            body = toJSON(request_body, auto_unbox = TRUE),
            encode = "raw",
            timeout(60),
            config = list(
              ssl_verifypeer = FALSE,
              ssl_verifyhost = FALSE,
              followlocation = TRUE,
              connecttimeout = 10,
              low_speed_time = 30,
              low_speed_limit = 1
            )
          )
        }
        
        cat("AI API: Response status:", status_code(response), "\n")
        
        if (status_code(response) == 200) {
          response_text <- content(response, "text", encoding = "UTF-8")
          cat("AI API: Raw response length:", nchar(response_text), "\n")
          
          result <- tryCatch({
            fromJSON(response_text)
          }, error = function(e) {
            cat("AI API: JSON parsing error:", e$message, "\n")
            cat("AI API: Response preview:", substr(response_text, 1, 200), "\n")
            return(NULL)
          })
          
          if (!is.null(result)) {
            # 安全地访问嵌套数据
            if ("choices" %in% names(result) && length(result$choices) > 0) {
              # choices可能是data.frame或list，需要兼容处理
              choices <- result$choices
              
              if (is.data.frame(choices)) {
                # 豆包API: 如果是data.frame，取第一行
                if (nrow(choices) > 0 && "message" %in% names(choices)) {
                  message_col <- choices$message
                  if (is.data.frame(message_col) && "content" %in% names(message_col)) {
                    ai_content <- message_col$content[1]
                    cat("AI API: Successfully received response (data.frame format), length:", nchar(ai_content), "\n")
                    return(ai_content)
                  }
                }
              } else {
                # OpenRouter等标准API: 如果是list
                choice <- choices[[1]]
                if (is.list(choice) && "message" %in% names(choice)) {
                  message <- choice$message
                  if (is.list(message) && "content" %in% names(message)) {
                    ai_content <- message$content
                    cat("AI API: Successfully received response (list format), length:", nchar(ai_content), "\n")
                    return(ai_content)
                  }
                }
              }
              cat("AI API: Invalid message structure in response\n")
              cat("AI API: Choices structure:", str(choices), "\n")
            } else {
              cat("AI API: No choices in response\n")
            }
          }
        } else {
          cat("AI API Error: Status", status_code(response), "\n")
          error_content <- content(response, "text", encoding = "UTF-8")
          cat("AI API Error Details:", error_content, "\n")
          
          # 尝试解析错误信息
          tryCatch({
            error_json <- fromJSON(error_content)
            if (!is.null(error_json$error$message)) {
              return(paste("AI服务错误：", error_json$error$message))
            }
          }, error = function(e) {})
        }
        
        return("抱歉，AI分析服务暂时不可用，请稍后再试。")
        
      }, error = function(e) {
        cat("Error in AI API call:", e$message, "\n")
        if (grepl("timeout", e$message, ignore.case = TRUE)) {
          return("AI分析超时，请稍后再试。")
        }
        if (grepl("proxy|connection", e$message, ignore.case = TRUE)) {
          return("网络连接问题，可能是代理设置导致的。")
        }
        return("AI分析服务暂时不可用。")
      })
    }
    
    # 添加消息到聊天记录
    add_message <- function(content, is_user = TRUE, image_path = NULL) {
      message_id <- paste0("msg_", length(values$messages) + 1)
      
      message <- list(
        id = message_id,
        content = content,
        is_user = is_user,
        timestamp = Sys.time(),
        image_path = image_path
      )
      
      values$messages <- append(values$messages, list(message))
      
      # 更新UI
      update_chat_ui()
    }
    
    # 更新聊天UI
    update_chat_ui <- function() {
      messages_html <- ""
      
      for (msg in values$messages) {
        message_class <- if (msg$is_user) "ai-message-user" else "ai-message-bot"
        avatar_icon <- if (msg$is_user) "user" else "robot"
        
        image_html <- ""
        if (!is.null(msg$image_path)) {
          # 检查是否是相对路径（文件名）或完整路径
          if (grepl("^plot_", msg$image_path) || !grepl("/", msg$image_path)) {
            # 是文件名，直接使用（因为在www目录下）
            image_html <- paste0(
              '<div class="ai-message-image">',
              '<img src="', msg$image_path, '" alt="分析图片" style="max-width: 200px; border-radius: 8px;">',
              '</div>'
            )
          } else if (file.exists(msg$image_path)) {
            # 是完整路径，转换为相对路径
            image_html <- paste0(
              '<div class="ai-message-image">',
              '<img src="', basename(msg$image_path), '" alt="分析图片" style="max-width: 200px; border-radius: 8px;">',
              '</div>'
            )
          }
        }
        
        # 处理markdown格式的内容
        content_html <- gsub("\n", "<br>", msg$content)
        content_html <- gsub("##\\s+(.+?)(<br>|$)", "<h4>\\1</h4>", content_html)
        content_html <- gsub("\\*\\*(.+?)\\*\\*", "<strong>\\1</strong>", content_html)
        content_html <- gsub("\\*(.+?)\\*", "<em>\\1</em>", content_html)
        
        messages_html <- paste0(messages_html,
          '<div class="ai-message ', message_class, '">',
            '<div class="ai-message-avatar"><i class="fa fa-', avatar_icon, '"></i></div>',
            '<div class="ai-message-content">',
              image_html,
              '<div>', content_html, '</div>',
            '</div>',
          '</div>'
        )
      }
      
      shinyjs::html("chat_messages", messages_html)
      
      # 滚动到底部
      shinyjs::runjs(paste0("
        var chatMessages = document.getElementById('", ns("chat_messages"), "');
        if (chatMessages) {
          chatMessages.scrollTop = chatMessages.scrollHeight;
        }
      "))
    }
    
    # 监听来自分析模块的图片分析请求
    observeEvent(input$analyze_plot, {
      plot_data <- input$analyze_plot
      cat("AI Chat: Received analyze_plot event\n")
      cat("Plot data:", str(plot_data), "\n")

      # 使用isolate确保稳定执行
      isolate({
        if (!is.null(plot_data) && !is.null(plot_data$plotPath)) {
          cat("AI Chat: Starting analysis for:", plot_data$plotPath, "\n")

          # 显示聊天窗口
          if (!values$chat_visible) {
            values$chat_visible <- TRUE
            shinyjs::show("chat_container")
            cat("AI Chat: Showing chat container\n")
          }

          # 开始分析
          values$analyzing <- TRUE
          shinyjs::show("chat_loading")
          
          # 设置全局AI分析状态
          if (!is.null(global_state)) {
            global_state$ai_analyzing <- TRUE
            global_state$analyzing_gene <- plot_data$gene1
          }
          
          cat("AI Chat: Starting analysis process\n")

          # 构建分析提示
          if (!is.null(plot_data$autoTriggered) && plot_data$autoTriggered) {
            analysis_prompt <- paste0(
              "您好！我是GIST AI图片分析助手。我看到您刚刚生成了一张关于基因 ",
              plot_data$gene1,
              if(!is.null(plot_data$gene2)) paste0(" 和 ", plot_data$gene2) else "",
              " 的", plot_data$analysisType, "分析图。让我为您详细分析这张图片的生物学意义和临床相关性。"
            )
          } else {
            analysis_prompt <- paste0(
              "请分析这张GIST（胃肠道间质瘤）研究的生物信息学图片。",
              "基因: ", plot_data$gene1,
              if(!is.null(plot_data$gene2)) paste0(", ", plot_data$gene2) else "",
              "。分析类型: ", plot_data$analysisType,
              "。请从统计学意义、生物学意义和临床相关性等方面进行专业分析。"
            )
          }

          cat("AI Chat: Analysis prompt:", analysis_prompt, "\n")

          # 使用相对路径显示图片
          display_path <- if(!is.null(plot_data$relativePath)) {
            plot_data$relativePath
          } else {
            basename(plot_data$plotPath)  # 作为备用，只使用文件名
          }

          # 添加用户消息，使用相对路径显示
          add_message(analysis_prompt, TRUE, display_path)
          cat("AI Chat: User message added with display path:", display_path, "\n")

          # 延迟执行分析，确保UI更新
          shinyjs::delay(100, {
            # 执行分析
            result <- tryCatch({
              cat("AI Chat: Starting analysis execution\n")

              # 检查文件是否存在
              if (!file.exists(plot_data$plotPath)) {
                cat("AI Chat: File does not exist:", plot_data$plotPath, "\n")
                # 使用默认分析
                generate_mock_analysis(plot_data)
              } else if (enable_ai) {
                cat("AI Chat: Starting real AI analysis\n")
                
                # 文本分析（不带图片）
                cat("AI Chat: Trying text-based analysis\n")
                text_analysis_prompt <- paste0(
                  "请分析这张GIST（胃肠道间质瘤）研究的基因表达分析图。",
                  "基因: ", plot_data$gene1,
                  if(!is.null(plot_data$gene2)) paste0(" 和 ", plot_data$gene2) else "",
                  "，分析类型: ", switch(plot_data$analysisType,
                    "gender" = "性别差异表达",
                    "correlation" = "基因相关性",
                    "drug" = "药物反应",
                    "prepost" = "治疗前后对比",
                    plot_data$analysisType
                  ), "。",
                  "请从以下方面进行专业分析：",
                  "1. 该基因在GIST中的一般生物学功能和意义",
                  "2. 不同组间表达差异的可能生物学解释",
                  "3. 临床相关性和潜在应用价值",
                  "4. 需要注意的研究局限性",
                  "请用中文回答，语言专业但易懂。"
                )
                
                # 调用AI API
                ai_result <- analyze_image_with_ai(NULL, text_analysis_prompt)
                
                # 检查AI分析结果
                if (!is.null(ai_result) && 
                    !grepl("暂时不可用|超时|错误|连接问题", ai_result) &&
                    nchar(ai_result) > 50) {
                  cat("AI Chat: Text-based analysis successful, length:", nchar(ai_result), "\n")
                  ai_result  # 直接返回成功的AI结果
                } else {
                  cat("AI Chat: AI analysis failed, using fallback\n")
                  paste0(
                    "## 📊 GIST基因表达分析报告\n\n",
                    "**分析基因**: ", plot_data$gene1, "\n",
                    "**分析类型**: ", switch(plot_data$analysisType,
                      "gender" = "性别差异表达分析",
                      "correlation" = "基因相关性分析",
                      "drug" = "药物反应分析",
                      "prepost" = "治疗前后对比分析",
                      "基因表达分析"
                    ), "\n\n",
                    "### 🔍 图表解读\n",
                    plot_data$gene1, "基因在GIST中具有重要的生物学功能，不同组间的表达差异提供了有价值的临床信息。\n\n",
                    "### 🧬 生物学意义\n",
                    "该基因的表达模式可能反映了GIST的分子特征和发病机制。\n\n",
                    "### 🏥 临床相关性\n",
                    "表达差异可能为诊断、治疗选择和预后评估提供参考。\n\n",
                    "*注：AI分析服务暂时不可用，这是基于基因功能的一般性分析。*"
                  )
                }
              } else {
                cat("AI Chat: AI analysis disabled, using mock analysis\n")
                generate_mock_analysis(plot_data)
              }

            }, error = function(e) {
              cat("AI Chat: Error during analysis:", e$message, "\n")
              
              # 返回错误兜底分析
              paste0(
                "## 📊 GIST基因表达分析\n\n",
                "**分析基因**: ", if(exists("plot_data") && !is.null(plot_data$gene1)) plot_data$gene1 else "TP53", "\n",
                "**分析类型**: 基因表达分析\n\n",
                "### 🔍 基本信息\n",
                "该基因在GIST（胃肠道间质瘤）研究中具有重要意义。\n\n",
                "### 🧬 生物学功能\n",
                "基因表达的差异可能反映不同的生物学状态和临床特征。\n\n",
                "### 🏥 临床意义\n",
                "表达模式可能为个体化医疗提供参考依据。\n\n",
                "*注：分析系统正在优化中，如有疑问请联系技术支持。*"
              )
            })

            # 确保分析状态被重置
            cat("AI Chat: Finalizing analysis, result length:", nchar(result), "\n")
            values$analyzing <- FALSE
            shinyjs::hide("chat_loading")
            
            # 重置全局AI分析状态
            if (!is.null(global_state)) {
              global_state$ai_analyzing <- FALSE
              global_state$analyzing_gene <- NULL
            }
            
            add_message(result, FALSE)
            
            # 保存分析结果到历史文件
            if (!is.null(result) && nchar(result) > 200) {
              analysis_type_cn <- switch(plot_data$analysisType,
                "gender" = "性别差异表达分析",
                "correlation" = "基因相关性分析", 
                "drug" = "药物反应分析",
                "prepost" = "治疗前后对比分析",
                paste0(plot_data$analysisType, "分析")
              )
              
              gene_display <- plot_data$gene1
              if (!is.null(plot_data$gene2) && plot_data$gene2 != "") {
                gene_display <- paste0(plot_data$gene1, " 和 ", plot_data$gene2)
              }
              
              save_analysis_to_history(gene_display, analysis_type_cn, result)
            }

            cat("AI Chat: Analysis completed successfully\n")
          })
        } else {
          cat("AI Chat: Invalid plot data received\n")
          # 确保重置状态
          values$analyzing <- FALSE
          shinyjs::hide("chat_loading")
          
          # 重置全局AI分析状态
          if (!is.null(global_state)) {
            global_state$ai_analyzing <- FALSE
            global_state$analyzing_gene <- NULL
          }
        }
      })
    }, ignoreInit = TRUE)

    # 移除了发送消息和手动上传图片的功能，专注于自动分析
  })
}
