# ==== 重构后的Server文件 ====
# 参考GIST_Protemics的设计模式和结构

# 加载必要的模块
source("modules/analysis_template.R")
source("config/module_configs.R")

# 初始化模块配置（如果需要）
if(exists("initialize_module_configs") && is.function(initialize_module_configs)) {
  if(!exists("module_configs") || length(module_configs) == 0) {
    cat("初始化模块配置...\n")
    initialize_module_configs()
  }
}

# 条件加载AI模块
if(isTRUE(enable_ai)) {
  source("modules/ai_chat_module.R")
}

# 主Server函数
server <- function(input, output, session) {
  
  # ==== 全局状态管理 ====
  global_state <- reactiveValues(
    ai_enabled = isTRUE(enable_ai),
    ai_analyzing = FALSE,
    analyzing_gene = NULL,
    current_module = "Introduction"
  )
  
  # ==== 首页内容 ====
  # 首页介绍文字
  output$home_intro_text <- renderText({
    paste(
      "GIST Gene Expression Analysis Platform is a comprehensive bioinformatics tool designed for analyzing",
      "gastrointestinal stromal tumor (GIST) gene expression data. Our platform provides multiple analysis",
      "modules including clinical feature analysis, single gene expression analysis, gene correlation studies,",
      "drug resistance analysis, and treatment comparison tools.",
      "\n\n",
      "The platform integrates advanced statistical methods with interactive visualizations to help researchers",
      "understand gene expression patterns in GIST samples. Each analysis module provides downloadable results",
      "in multiple formats and includes comprehensive data tables for further investigation.",
      sep = " "
    )
  })
  
  # 首页图片轮播
  output$home_slick_output <- renderSlickR({
    # 使用global.R中定义的图片列表
    if(exists("slick_intro_plot") && length(slick_intro_plot) > 0) {
      slickR(slick_intro_plot, 
             slideType = "img",
             slideId = 'slick_intro_plot_id',
             height = 500,
             width = '100%') + 
        settings(dots = TRUE, arrows = TRUE, autoplay = TRUE, autoplaySpeed = 4000, 
                 adaptiveHeight = FALSE, centerMode = FALSE, slidesToShow = 1, 
                 slidesToScroll = 1, fade = TRUE, cssEase = 'linear')
    } else {
      # 如果没有图片，显示占位符
      placeholder_html <- tags$div(
        style = "height: 400px; display: flex; align-items: center; justify-content: center; background-color: #f8f9fa; border-radius: 8px;",
        tags$div(
          style = "text-align: center; color: #6c757d;",
          tags$h4("Image Gallery"),
          tags$p("Sample analysis results and visualizations will appear here")
        )
      )
      return(placeholder_html)
    }
  })
  
  # ==== 模块服务器逻辑 ====
  
  # Module 1 子模块
  module1_submodules <- get_module1_submodules()
  
  for(submodule_id in module1_submodules) {
    config <- get_module_config(submodule_id)
    
    if(!is.null(config)) {
      createAnalysisServer(
        id = submodule_id,
        analysis_function = config$analysis_function,
        extract_data_function = config$data_function,
        global_state = global_state,
        has_second_gene = config$has_second_gene
      )
    }
  }
  
  # Module 2: 单基因表达分析
  config_module2 <- get_module_config("module2")
  if(!is.null(config_module2)) {
    createAnalysisServer(
      id = "module2",
      analysis_function = config_module2$analysis_function,
      extract_data_function = config_module2$data_function,
      global_state = global_state,
      has_second_gene = config_module2$has_second_gene
    )
  }
  
  # Module 3: 基因相关性分析
  config_module3 <- get_module_config("module3")
  if(!is.null(config_module3)) {
    createAnalysisServer(
      id = "module3",
      analysis_function = config_module3$analysis_function,
      extract_data_function = config_module3$data_function,
      global_state = global_state,
      has_second_gene = config_module3$has_second_gene
    )
  }
  
  # Module 4: 药物耐药分析
  config_module4 <- get_module_config("module4")
  if(!is.null(config_module4)) {
    createAnalysisServer(
      id = "module4",
      analysis_function = config_module4$analysis_function,
      extract_data_function = config_module4$data_function,
      global_state = global_state,
      has_second_gene = config_module4$has_second_gene
    )
  }
  
  # ==== AI模块集成 ====
  if(isTRUE(enable_ai)) {
    tryCatch({
      # AI聊天模块服务器
      aiChatFloatingButtonServer("ai_chat")
      aiChatServer("ai_chat")
      
      # 监听当前活跃的模块
      observe({
        if(!is.null(input$sidebar_menu)) {
          global_state$current_module <- input$sidebar_menu
        }
      })
      
    }, error = function(e) {
      cat("AI module initialization error:", e$message, "\n")
    })
  }
  
  # ==== 侧边栏菜单监听 ====
  observe({
    # 更新当前模块状态
    if(!is.null(input$sidebar_menu)) {
      global_state$current_module <- input$sidebar_menu
    }
  })
  
  # ==== 错误处理和调试信息 ====
  session$onSessionEnded(function() {
    cat("Session ended for user\n")
  })
  
  # 全局错误处理
  options(shiny.error = function() {
    cat("Shiny error occurred\n")
  })
  
  # ==== 响应式数据监控 ====
  # 监控数据加载状态
  observe({
    # 检查关键数据对象是否加载
    required_objects <- c("dbGIST_matrix", "gene2sym")
    missing_objects <- required_objects[!sapply(required_objects, exists)]
    
    if(length(missing_objects) > 0) {
      showNotification(
        paste("Warning: Missing required data objects:", paste(missing_objects, collapse = ", ")),
        type = "warning",
        duration = 5
      )
    }
  })
  
  # 打印调试信息
  cat("=== GIST Shiny Server Initialized ===\n")
  cat("AI enabled:", isTRUE(enable_ai), "\n")
  cat("Available modules:", length(get_available_modules()), "\n")
  cat("Module 1 submodules:", length(get_module1_submodules()), "\n")
  cat("=====================================\n")
}

# 使用示例：如何在实际应用中使用
# 在你的主server.R文件中，你可以：
# 1. source("server_refactored.R")
# 2. 然后使用重构后的server函数 