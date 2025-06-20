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
              p("点击'Visualize'生成图片后，我会自动分析图片内容并为您提供专业的生物信息学解读。"),
              p("您也可以手动上传图片让我分析。")
            )
          )
        )
      ),
      
      # 聊天输入区域
      div(
        class = "ai-chat-input-area",
        div(
          class = "ai-chat-input-container",
          fileInput(ns("manual_image"), "", 
                   accept = c(".png", ".jpg", ".jpeg"),
                   buttonLabel = icon("image"),
                   placeholder = "上传图片"),
          textAreaInput(ns("user_message"), "", 
                       placeholder = "输入您的问题...",
                       rows = 2),
          actionButton(ns("send_message"), "", icon = icon("paper-plane"),
                      class = "ai-chat-send-btn")
        )
      )
    ),
    
    # 加载指示器
    div(
      id = ns("chat_loading"),
      class = "ai-chat-loading",
      style = "display: none;",
      div(class = "ai-loading-spinner"),
      span("AI正在分析中...")
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
aiChatServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # 响应式值
    values <- reactiveValues(
      chat_visible = FALSE,
      chat_minimized = FALSE,
      messages = list(),
      analyzing = FALSE
    )
    
    # API配置
    API_CONFIG <- list(
      url = "https://ark.cn-beijing.volces.com/api/v3/chat/completions",
      key = "1a5f6b00-65a7-4ea3-9a76-62805416839e",
      model = "doubao-1-5-thinking-vision-pro-250428"
    )
    
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
    
    # 图片转base64
    image_to_base64 <- function(image_path) {
      tryCatch({
        if (file.exists(image_path)) {
          image_data <- readBin(image_path, "raw", file.info(image_path)$size)
          base64_data <- base64encode(image_data)
          
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
    
    # 调用AI API分析图片
    analyze_image_with_ai <- function(image_base64, user_text = NULL) {
      tryCatch({
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
        
        # 添加图片
        content <- append(content, list(list(
          type = "image_url",
          image_url = list(url = image_base64)
        )))
        
        # 构建请求体
        request_body <- list(
          model = API_CONFIG$model,
          messages = list(list(
            role = "user",
            content = content
          ))
        )
        
        # 发送请求
        response <- POST(
          url = API_CONFIG$url,
          add_headers(
            "Content-Type" = "application/json",
            "Authorization" = paste("Bearer", API_CONFIG$key)
          ),
          body = toJSON(request_body, auto_unbox = TRUE),
          encode = "raw"
        )
        
        if (status_code(response) == 200) {
          result <- fromJSON(content(response, "text", encoding = "UTF-8"))
          if (!is.null(result$choices) && length(result$choices) > 0) {
            return(result$choices[[1]]$message$content)
          }
        } else {
          cat("API Error:", status_code(response), "\n")
          cat("Response:", content(response, "text"), "\n")
        }
        
        return("抱歉，AI分析服务暂时不可用，请稍后再试。")
        
      }, error = function(e) {
        cat("Error in AI analysis:", e$message, "\n")
        return(paste("分析过程中出现错误：", e$message))
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
        if (!is.null(msg$image_path) && file.exists(msg$image_path)) {
          image_html <- paste0(
            '<div class="ai-message-image">',
            '<img src="', msg$image_path, '" alt="分析图片" style="max-width: 200px; border-radius: 8px;">',
            '</div>'
          )
        }
        
        messages_html <- paste0(messages_html,
          '<div class="ai-message ', message_class, '">',
            '<div class="ai-message-avatar"><i class="fa fa-', avatar_icon, '"></i></div>',
            '<div class="ai-message-content">',
              image_html,
              '<p>', gsub("\n", "<br>", msg$content), '</p>',
            '</div>',
          '</div>'
        )
      }
      
      shinyjs::html("chat_messages", messages_html)
      
      # 滚动到底部
      shinyjs::runjs("
        var chatMessages = document.getElementById('", ns("chat_messages"), "');
        if (chatMessages) {
          chatMessages.scrollTop = chatMessages.scrollHeight;
        }
      ")
    }
    
    # 监听来自分析模块的图片分析请求
    observeEvent(input$analyze_plot, {
      plot_data <- input$analyze_plot
      if (!is.null(plot_data) && !is.null(plot_data$plotPath)) {
        # 显示聊天窗口
        if (!values$chat_visible) {
          values$chat_visible <- TRUE
          shinyjs::show("chat_container")
        }

        # 开始分析
        values$analyzing <- TRUE
        shinyjs::show("chat_loading")

        # 构建分析提示
        analysis_prompt <- paste0(
          "请分析这张GIST（胃肠道间质瘤）研究的生物信息学图片。",
          "基因: ", plot_data$gene1,
          if(!is.null(plot_data$gene2)) paste0(", ", plot_data$gene2) else "",
          "。分析类型: ", plot_data$analysisType,
          "。请从统计学意义、生物学意义和临床相关性等方面进行专业分析。"
        )

        # 添加用户消息
        add_message(analysis_prompt, TRUE, plot_data$plotPath)

        # 分析图片
        image_base64 <- image_to_base64(plot_data$plotPath)
        if (!is.null(image_base64)) {
          result <- analyze_image_with_ai(image_base64, analysis_prompt)
        } else {
          result <- "无法读取图片文件，请检查文件格式。"
        }

        values$analyzing <- FALSE
        shinyjs::hide("chat_loading")
        add_message(result, FALSE)
      }
    })

    # 发送消息按钮事件
    observeEvent(input$send_message, {
      user_text <- input$user_message
      if (!is.null(user_text) && user_text != "") {
        # 添加用户消息
        add_message(user_text, TRUE)

        # 清空输入框
        updateTextAreaInput(session, "user_message", value = "")

        # 开始AI分析
        values$analyzing <- TRUE
        shinyjs::show("chat_loading")

        # 分析文本
        result <- analyze_image_with_ai(NULL, user_text)
        values$analyzing <- FALSE
        shinyjs::hide("chat_loading")
        add_message(result, FALSE)
      }
    })

    # 手动上传图片分析
    observeEvent(input$manual_image, {
      if (!is.null(input$manual_image)) {
        image_path <- input$manual_image$datapath

        # 开始分析
        values$analyzing <- TRUE
        shinyjs::show("chat_loading")

        # 添加用户消息（图片）
        add_message("请分析这张图片", TRUE, image_path)

        # 分析图片
        image_base64 <- image_to_base64(image_path)
        if (!is.null(image_base64)) {
          result <- analyze_image_with_ai(image_base64)
        } else {
          result <- "无法读取图片文件，请检查文件格式。"
        }

        values$analyzing <- FALSE
        shinyjs::hide("chat_loading")
        add_message(result, FALSE)
      }
    })
  })
}
