# ==== 重构后的Server文件示例 ====

# 加载模块文件
source("modules/analysis_module.R")
source("modules/data_utils.R")
source("modules/ai_chat_module.R")
source("config/module_configs.R")

# 主Server函数
server <- function(input, output, session) {
  
  # ==== 首页内容 ====
  output$home_slick_output <- renderSlickR({
    slickR(slick_intro_plot, 
           slideType = "img",
           slideId = 'slick_intro_plot_id',
           height = 500,
           width = '100%') + 
      settings(dots = TRUE, arrows = TRUE, autoplay = TRUE, autoplaySpeed = 4000, 
               adaptiveHeight = FALSE, centerMode = FALSE, slidesToShow = 1, 
               slidesToScroll = 1, fade = TRUE, cssEase = 'linear')
  })
  
  output$home_intro_text <- renderText({
    home_whole_intro_text
  })
  
  # ==== 全局状态管理 ====
  # 先创建全局状态，以便模块使用
  global_state <- reactiveValues(
    current_module = NULL,
    analysis_history = list(),
    user_preferences = list(),
    # AI分析状态
    ai_analyzing = FALSE,
    analyzing_gene = NULL
  )
  
  # ==== 动态加载模块 ====
  module_servers <- list()
  
  # 使用lapply避免闭包问题
  module_ids <- get_available_modules()
  module_servers <- lapply(module_ids, function(module_id) {
    config <- get_module_config(module_id)

    # 调用模块服务器
    analysisModuleServer(
      id = module_id,
      analysis_config = config,
      global_state = global_state
    )
  })
  names(module_servers) <- module_ids

  # 初始化AI聊天机器人
  ai_chat_server <- aiChatServer("ai_chat", global_state)
  
  # 监听侧边栏切换
  observe({
    if(!is.null(input$sidebar_menu)) {
      global_state$current_module <- input$sidebar_menu
    }
  })
  
  # ==== 错误处理和日志记录 ====
  options(shiny.error = function() {
    cat("Error occurred at:", Sys.time(), "\n")
    cat("Current module:", global_state$current_module, "\n")
    # 这里可以添加更详细的错误日志记录
  })
  
  # ==== 可选：添加性能监控 ====
  session$onSessionEnded(function() {
    cat("Session ended at:", Sys.time(), "\n")
    # 使用 isolate 来安全访问响应式值
    isolate({
      if(!is.null(global_state$analysis_history)) {
        cat("Analysis history:", length(global_state$analysis_history), "analyses performed\n")
      }
    })
  })
}

# 使用示例：如何在实际应用中使用
# 在你的主server.R文件中，你可以：
# 1. source("server_refactored.R")
# 2. 然后使用重构后的server函数 