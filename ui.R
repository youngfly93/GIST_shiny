# ==== 重构后的UI文件示例 ====

# 加载模块文件
source("modules/analysis_module.R")
source("config/module_configs.R")

# 生成侧边栏菜单
generate_sidebar_menu <- function() {
  menu_items <- list(
    menuItem("Introduction", tabName = "Introduction", icon = icon("home"))
  )
  
  # 动态生成模块菜单项
  for(module_id in get_available_modules()) {
    metadata <- get_module_metadata(module_id)
    menu_items <- append(menu_items, list(
      menuItem(metadata$title, tabName = module_id, icon = icon(metadata$icon))
    ))
  }
  
  return(do.call(sidebarMenu, menu_items))
}

# 生成主体内容
generate_dashboard_body <- function() {
  tab_items <- list(
    # 首页
    tabItem(
      tabName = "Introduction",
      # 标题部分
      column(width = 12, style = "padding-right:25px;padding-left:25px",
        h1(class = "homeTitle", "Welcome to GIST Analysis Platform")
      ),
      
      # 介绍文字部分
      column(width = 12, style = "padding-right:25px;padding-left:25px; margin-bottom: 20px;",
        div(class = "intro-text", 
          textOutput("home_intro_text")
        )
      ),
      
      # 图片轮播部分
      column(width = 12, style = "padding-right:25px;padding-left:25px",
        slickROutput("home_slick_output", width = "100%", height = "300px")
      ),
      
      # 页脚部分
      column(width = 12, class = "footer-container",
        HTML('<div style="text-align: center; margin-top: 40px;"><p>Copyright © 2024. All rights reserved.</p></div>')
      )
    )
  )
  
  # 动态生成模块页面
  for(module_id in get_available_modules()) {
    metadata <- get_module_metadata(module_id)
    config <- get_module_config(module_id)
    
    tab_content <- tabItem(
      tabName = module_id,
      analysisModuleUI(
        id = module_id,
        title = metadata$title,
        input_config = config$input_config,
        has_second_gene = config$has_second_gene
      ),
      # 页脚
      column(12, class = "footer-container",
        hr(),
        div(class = "footer-text",
          "© 2024 GIST Analysis Platform. All rights reserved."
        )
      )
    )
    
    tab_items <- append(tab_items, list(tab_content))
  }
  
  return(do.call(tabItems, tab_items))
}

# 主UI函数
ui <- dashboardPage(
  dark = FALSE,
  help = FALSE,
  fullscreen = TRUE,
  scrollToTop = TRUE,
  title = "GIST",
  
  dashboardHeader(title = "GIST Analysis Platform"),
  
  dashboardSidebar(
    generate_sidebar_menu()
  ),
  
  dashboardBody(
    useShinyjs(),
    useShinyFeedback(),
    
    # 自定义CSS
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
        .homeTitle {
          color: #e67e22;
          font-weight: bold;
          text-align: center;
          margin-bottom: 20px;
        }
        .pageTitle {
          color: #2c3e50;
          font-weight: bold;
        }
        .intro-text {
          background-color: white;
          padding: 20px;
          border-radius: 10px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          text-align: justify;
          line-height: 1.6;
        }
        .footer-container {
          margin-top: 40px;
          padding: 20px;
          background-color: #34495e;
          color: white;
          text-align: center;
        }
        /* 确保slickR容器不会溢出 */
        .slick-output {
          max-width: 100%;
          overflow: hidden;
        }
        /* 修复图片轮播的布局 */
        .slick-slide img {
          width: 100%;
          height: auto;
          object-fit: contain;
        }
      "))
    ),
    
    generate_dashboard_body()
  )
)

# 使用示例：如何在实际应用中使用
# 在你的主ui.R文件中，你可以：
# 1. source("ui_refactored.R")
# 2. 然后使用重构后的ui对象 