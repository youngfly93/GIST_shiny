# ==== 重构后的UI文件示例 ====

# 加载模块文件
source("modules/analysis_module.R")
source("modules/cbioportal_module.R")
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
      column(width = 12, style = "padding: 0 var(--space-6); text-align: center;",
        div(style = "background: linear-gradient(135deg, var(--clr-primary-500) 0%, var(--clr-primary-700) 100%);
                     color: white;
                     padding: var(--space-8) var(--space-4);
                     border-radius: var(--radius-lg);
                     margin-bottom: var(--space-6);
                     box-shadow: var(--shadow-lg);",
          h1(class = "homeTitle", style = "color: white !important; margin-bottom: var(--space-2);",
             "Welcome to GIST Analysis Platform"),
          p(style = "font-size: var(--text-lg); opacity: 0.9; margin: 0;",
            "Professional Gene Expression Analysis & Visualization")
        )
      ),
      
      # 介绍文字部分
      column(width = 12, style = "padding: 0 var(--space-6); margin-bottom: var(--space-4);",
        div(class = "intro-text",
          textOutput("home_intro_text")
        )
      ),

      # 图片轮播部分
      column(width = 12, style = "padding: 0 var(--space-6); margin: var(--space-6) 0;",
        div(style = "background: white;
                     border-radius: var(--radius-lg);
                     box-shadow: var(--shadow-lg);
                     padding: var(--space-4);
                     overflow: hidden;",
          slickROutput("home_slick_output", width = "100%", height = "500px")
        )
      ),
      
      # 页脚部分
      column(width = 12, class = "footer-container",
        HTML('<div style="text-align: center; padding: var(--space-4);
                          background: var(--clr-primary-900);
                          color: white;
                          border-radius: var(--radius-lg);
                          margin-top: var(--space-8);">
                <p style="margin: 0; font-size: var(--text-sm); opacity: 0.9;">
                  Copyright © 2024 GIST Analysis Platform. All rights reserved.
                </p>
              </div>')
      )
    )
  )
  
  # 动态生成模块页面
  for(module_id in get_available_modules()) {
    metadata <- get_module_metadata(module_id)
    config <- get_module_config(module_id)
    
    # 特殊处理 cBioPortal 模块
    if(module_id == "module6") {
      tab_content <- tabItem(
        tabName = module_id,
        cbioportalModuleUI(id = module_id),
        # 页脚
        column(12, style = "margin-top: var(--space-8); padding: 0 var(--space-4);",
          div(style = "background: var(--clr-primary-900);
                       color: white;
                       padding: var(--space-4);
                       border-radius: var(--radius-lg);
                       text-align: center;",
            p(style = "margin: 0; font-size: var(--text-sm); opacity: 0.9;",
              "© 2024 GIST Analysis Platform. All rights reserved."
            )
          )
        )
      )
    } else {
      tab_content <- tabItem(
        tabName = module_id,
        analysisModuleUI(
          id = module_id,
          title = metadata$title,
          input_config = config$input_config,
          has_second_gene = config$has_second_gene
        ),
        # 页脚
        column(12, style = "margin-top: var(--space-8); padding: 0 var(--space-4);",
          div(style = "background: var(--clr-primary-900);
                       color: white;
                       padding: var(--space-4);
                       border-radius: var(--radius-lg);
                       text-align: center;",
            p(style = "margin: 0; font-size: var(--text-sm); opacity: 0.9;",
              "© 2024 GIST Analysis Platform. All rights reserved."
            )
          )
        )
      )
    }
    
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
    
    # 自定义CSS - 与GIST_web风格一致
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
      tags$style(HTML("
        /* 主要布局样式 */
        .content-wrapper, .right-side {
          background-color: var(--clr-primary-050) !important;
        }

        /* 标题样式 */
        .homeTitle {
          color: var(--clr-primary-500) !important;
          font-weight: 700 !important;
          text-align: center;
          margin-bottom: var(--space-4);
          font-size: var(--text-3xl) !important;
        }

        .pageTitle {
          color: var(--clr-primary-500) !important;
          font-weight: 600 !important;
          font-size: var(--text-2xl) !important;
        }

        /* 介绍文字样式 */
        .intro-text {
          background-color: white;
          padding: var(--space-6);
          border-radius: var(--radius-lg);
          box-shadow: var(--shadow-md);
          text-align: justify;
          line-height: 1.8;
          color: var(--clr-gray-700);
          max-width: 1200px;
          margin: var(--space-4) auto;
        }

        /* 页脚样式 */
        .footer-container {
          margin-top: var(--space-8);
          padding: var(--space-4);
          background-color: var(--clr-primary-900);
          color: white;
          text-align: center;
          border-radius: var(--radius-lg) var(--radius-lg) 0 0;
        }

        /* SlickR轮播样式 */
        .slick-output {
          max-width: 100%;
          overflow: hidden;
          border-radius: var(--radius-lg);
          box-shadow: var(--shadow-lg);
        }

        .slick-slide img {
          width: 100%;
          height: auto;
          object-fit: contain;
          border-radius: var(--radius-sm);
        }

        /* 导航栏样式 */
        .main-header .navbar {
          background: white !important;
          box-shadow: var(--shadow-sm) !important;
        }

        .main-header .navbar-brand {
          color: var(--clr-primary-500) !important;
          font-weight: 700 !important;
        }

        /* 侧边栏文本对比度改进 - 浅绿色背景配白色文字 */
        .main-sidebar {
          background: var(--clr-primary-500) !important;
        }

        .sidebar-menu li a {
          color: white !important;
          font-weight: 500 !important;
        }

        .sidebar-menu li a:hover,
        .sidebar-menu li.active a {
          background: var(--clr-primary-300) !important;
          color: white !important;
        }

        .sidebar-menu li a i {
          color: white !important;
        }

        .sidebar-menu li:hover a i,
        .sidebar-menu li.active a i {
          color: white !important;
        }

        /* 确保所有侧边栏文本都有足够对比度 */
        .main-sidebar .sidebar-menu .header {
          color: white !important;
          background: transparent !important;
        }

        .main-sidebar .brand-link {
          background: var(--clr-primary-500) !important;
          color: white !important;
        }

        .main-sidebar .brand-text {
          color: white !important;
          font-weight: 700 !important;
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