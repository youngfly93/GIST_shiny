# ==== 重构后的UI文件 ====
# 参考GIST_Protemics的设计模式和结构

# 加载模块文件
source("modules/analysis_template.R")

# 检查是否启用AI功能
# 如果enable_ai变量已经在全局环境中定义（如通过start_no_ai.R），则使用它
# 否则从环境变量中读取
if (!exists("enable_ai")) {
  enable_ai <- tolower(Sys.getenv("ENABLE_AI_ANALYSIS", "true")) == "true"
}

# 条件加载AI模块
if(enable_ai) {
  source("modules/ai_chat_module.R")
}

source("config/module_configs.R")

# 生成侧边栏菜单
generate_sidebar_menu <- function() {
  menu_items <- list(
    menuItem("Introduction", tabName = "Introduction", icon = icon("home"))
  )
  
  # Module 1: 临床特征分析（包含子菜单）
  module1_submenu <- list()
  module1_submodules <- get_module1_submodules()
  
  if(length(module1_submodules) > 0) {
    for(submodule_id in module1_submodules) {
      metadata <- get_module_metadata(submodule_id)
      if(!is.null(metadata)) {
        module1_submenu <- append(module1_submenu, list(
          menuSubItem(
            text = metadata$title,
            tabName = submodule_id
          )
        ))
      }
    }
  }
  
  # 创建Module 1菜单项（如果有子菜单的话）
  if(length(module1_submenu) > 0) {
    menu_items <- append(menu_items, list(
      do.call(menuItem, c(
        list(
          text = "Clinical Feature Analysis",
          tabName = "module1",
          icon = icon("chart-bar")
        ),
        module1_submenu
      ))
    ))
  } else {
    menu_items <- append(menu_items, list(
      menuItem(
        text = "Clinical Feature Analysis",
        tabName = "module1",
        icon = icon("chart-bar")
      )
    ))
  }
  
  # 其他主要模块
  main_modules <- c("module2", "module3", "module4")
  for(module_id in main_modules) {
    metadata <- get_module_metadata(module_id)
    menu_items <- append(menu_items, list(
      menuItem(metadata$title, tabName = module_id, icon = icon(metadata$icon))
    ))
  }
  
  # 占位符模块（高级功能）
  placeholder_modules <- c("module3a_enrichment", "module3b_gsea", "module5")
  for(module_id in placeholder_modules) {
    metadata <- get_module_metadata(module_id)
    menu_items <- append(menu_items, list(
      menuItem(metadata$title, tabName = module_id, icon = icon(metadata$icon))
    ))
  }
  
  return(do.call(sidebarMenu, c(list(id = "sidebar_menu"), menu_items)))
}

# 生成占位符页面
create_placeholder_page <- function(module_id) {
  metadata <- get_module_metadata(module_id)
  
  fluidPage(
    style = "padding: 20px;",
    h1(metadata$title, class = "pageTitle",
       style = "text-align: center; color: white; margin-bottom: 30px;"),
    div(style = "text-align: center; padding: 40px; background-color: #fff3cd;
                 border-radius: 10px; margin-top: 30px; border-left: 4px solid #ffc107;",
      h4("🚧 Module Under Development",
         style = "color: #856404; margin-bottom: 15px;"),
      p(metadata$description,
        style = "color: #856404; font-size: 16px; margin-bottom: 10px;"),
      p(metadata$detailed_description,
        style = "color: #856404; font-size: 14px; margin: 0;")
    )
  )
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
             "Welcome to GIST Gene Expression Analysis Platform"),
          p(style = "font-size: var(--text-lg); color: white !important; opacity: 0.9; margin: 0;",
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
                          background: var(--clr-primary-500);
                          color: white !important;
                          border-radius: var(--radius-lg);
                          margin-top: var(--space-8);">
                <p style="margin: 0; font-size: var(--text-sm); color: white !important; opacity: 0.9;">
                  Copyright © 2024 GIST Gene Expression Analysis Platform. All rights reserved.
                </p>
              </div>')
      )
    )
  )
  
  # 动态生成Module 1子模块页面
  module1_submodules <- get_module1_submodules()
  if(length(module1_submodules) > 0) {
    for(submodule_id in module1_submodules) {
      metadata <- get_module_metadata(submodule_id)
      config <- get_module_config(submodule_id)
      
      if(!is.null(metadata) && !is.null(config)) {
        tab_content <- tabItem(
          tabName = submodule_id,
          createAnalysisUI(
            id = submodule_id,
            title = metadata$title,
            description = metadata$description,
            has_second_gene = config$has_second_gene,
            detailed_description = metadata$detailed_description
          )
        )
        
        tab_items <- append(tab_items, list(tab_content))
      }
    }
  }
  
  # 动态生成主要模块页面
  main_modules <- c("module2", "module3", "module4")
  for(module_id in main_modules) {
    metadata <- get_module_metadata(module_id)
    config <- get_module_config(module_id)

    tab_content <- tabItem(
      tabName = module_id,
      createAnalysisUI(
        id = module_id,
        title = metadata$title,
        description = metadata$description,
        has_second_gene = config$has_second_gene,
        detailed_description = metadata$detailed_description
      )
    )
    
    tab_items <- append(tab_items, list(tab_content))
  }
  
  # 生成占位符模块页面
  placeholder_modules <- c("module3a_enrichment", "module3b_gsea", "module5")
  for(module_id in placeholder_modules) {
    tab_content <- tabItem(
      tabName = module_id,
      create_placeholder_page(module_id)
    )
    
    tab_items <- append(tab_items, list(tab_content))
  }
  
  return(do.call(tabItems, tab_items))
}

# 主UI函数
ui <- dashboardPage(
  dark = NULL,  # 让CSS完全控制主题
  help = FALSE,
  fullscreen = TRUE,
  scrollToTop = TRUE,
  title = "GIST Gene Expression Analysis Platform",

  dashboardHeader(
    title = dashboardBrand(
      title = "GIST Gene Expression Analysis Platform",
      color = "primary",
      href = "#",
      image = NULL
    ),
    status = "primary",
    border = TRUE,
    sidebarIcon = icon("bars"),
    controlbarIcon = icon("th"),
    fixed = FALSE,

    # Version indicator
    tags$div(
      style = "position: fixed; top: 10px; right: 10px; z-index: 9999;
               background: rgba(255,255,255,0.9); padding: 5px 10px;
               border-radius: 15px; font-size: 12px; font-weight: bold;
               box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
      tags$span(
        id = "version_indicator",
        style = "color: var(--clr-primary-500);", 
        if(enable_ai) {
          "AI Version (4964)"
        } else {
          "Basic Version (4964)"
        }
      )
    )
  ),
  
  dashboardSidebar(
    fixed = TRUE,
    width = 280,
    status = "primary", 
    elevation = 3,
    collapsed = FALSE,
    minified = TRUE,
    expandOnHover = TRUE,
    id = "sidebar",
    
    generate_sidebar_menu()
  ),
  
  dashboardBody(
    useShinyjs(),
    useShinyFeedback(),
    
    # 自定义CSS - 与GIST_Protemics风格一致
    tags$head(
      includeCSS("www/custom.css"),
      # 条件加载AI聊天按钮样式
      if(isTRUE(enable_ai)) includeCSS("www/ai_chat_buttons.css"),
      # JavaScript修复标题颜色
      includeScript("www/fix-title-color.js"),

      # CSS变量定义 - 与GIST_Protemics一致
      tags$style(HTML("
        :root {
          /* 主色调 - 绿色系 */
          --clr-primary-900: #0F2B2E;
          --clr-primary-700: #163A3D;
          --clr-primary-500: #1C484C;
          --clr-primary-300: #3C6B6F;
          --clr-primary-100: #D7E4E5;
          --clr-primary-050: #F2F7F7;
          
          /* 强调色 */
          --clr-accent-coral: #E87D4C;
          --clr-accent-lime: #9CCB3B;
          --clr-accent-sky: #2F8FBF;
          
          /* 间距系统 */
          --space-1: 0.25rem;
          --space-2: 0.5rem;
          --space-3: 0.75rem;
          --space-4: 1rem;
          --space-6: 1.5rem;
          --space-8: 2rem;
          
          /* 边框半径 */
          --radius-sm: 0.125rem;
          --radius-md: 0.375rem;
          --radius-lg: 0.5rem;
          
          /* 阴影 */
          --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
          --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
          --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
          
          /* 文字大小 */
          --text-sm: 0.875rem;
          --text-base: 1rem;
          --text-lg: 1.125rem;
          --text-xl: 1.25rem;
        }
        
        /* 强制应用主题样式 - 顶部导航栏 */
        body .main-header, body .main-header .navbar,
        body.layout-fixed .main-header, body.layout-fixed .main-header .navbar,
        html body .main-header, html body .main-header .navbar,
        .skin-blue .main-header, .skin-blue .main-header .navbar,
        .wrapper .main-header, .wrapper .main-header .navbar,
        .main-header.navbar, .main-header.navbar-expand,
        .main-header.navbar-light, .main-header.navbar-dark,
        .navbar, .navbar-expand, .navbar-expand-lg,
        .navbar-light, .navbar-dark {
          background-color: var(--clr-primary-500) !important;
          background: var(--clr-primary-500) !important;
          border-bottom: none !important;
        }

        body .main-sidebar,
        body .sidebar,
        body.layout-fixed .main-sidebar,
        html body .main-sidebar,
        .skin-blue .main-sidebar,
        .wrapper .main-sidebar {
          background-color: var(--clr-primary-500) !important;
          background: var(--clr-primary-500) !important;
          width: 320px !important;
          min-width: 320px !important;
          max-width: 320px !important;
        }

        /* 调整内容区域的左边距以适应更宽的侧边栏 */
        .content-wrapper,
        .main-footer,
        body .content-wrapper,
        body .main-footer {
          margin-left: 320px !important;
        }

        body .main-sidebar .nav-sidebar .nav-item > .nav-link,
        body .sidebar .nav-sidebar .nav-item > .nav-link,
        .main-sidebar .sidebar-menu > li > a,
        .sidebar .sidebar-menu > li > a {
          color: white !important;
          background-color: transparent !important;
        }

        body .main-sidebar .nav-sidebar .nav-item > .nav-link:hover,
        body .sidebar .nav-sidebar .nav-item > .nav-link:hover,
        .main-sidebar .sidebar-menu > li > a:hover,
        .sidebar .sidebar-menu > li > a:hover {
          background-color: var(--clr-primary-300) !important;
          color: white !important;
        }

        body .content-wrapper,
        html body .content-wrapper,
        .wrapper .content-wrapper {
          background-color: var(--clr-primary-050) !important;
          background: var(--clr-primary-050) !important;
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
          background-color: var(--clr-primary-500);
          color: white !important;
          text-align: center;
          border-radius: var(--radius-lg) var(--radius-lg) 0 0;
        }

        .footer-container p {
          color: white !important;
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

        /* 子菜单项对齐样式 - 强制文字左对齐 */
        .sidebar-menu .treeview-menu > li > a,
        .main-sidebar .sidebar-menu .treeview-menu > li > a,
        .nav-treeview .nav-item .nav-link,
        .sidebar-menu .treeview-menu > li > a span,
        .main-sidebar .sidebar-menu .treeview-menu > li > a span,
        .nav-treeview .nav-item .nav-link span {
          text-align: left !important;
          padding-left: 15px !important;
          padding-right: 8px !important;
          color: rgba(255, 255, 255, 0.9) !important;
          font-size: 14px !important;
          line-height: 1.4 !important;
          white-space: nowrap !important;
          word-wrap: normal !important;
          display: block !important;
          margin: 0 !important;
          text-indent: 0 !important;
          padding-top: 8px !important;
          padding-bottom: 8px !important;
        }

        /* 确保子菜单文本span元素没有额外的缩进 */
        .sidebar-menu .treeview-menu > li > a span,
        .main-sidebar .sidebar-menu .treeview-menu > li > a span,
        .nav-treeview .nav-item .nav-link span {
          padding-left: 0 !important;
          margin-left: 0 !important;
          text-indent: 0 !important;
          display: inline !important;
        }

        .sidebar-menu .treeview-menu > li > a:hover,
        .main-sidebar .sidebar-menu .treeview-menu > li > a:hover,
        .nav-treeview .nav-item .nav-link:hover {
          background: var(--clr-primary-300) !important;
          color: white !important;
          padding-left: 15px !important;
          border-left: 3px solid var(--clr-accent-coral) !important;
          text-align: left !important;
        }

        .sidebar-menu .treeview-menu > li.active > a,
        .main-sidebar .sidebar-menu .treeview-menu > li.active > a,
        .nav-treeview .nav-item.active .nav-link {
          background: var(--clr-primary-300) !important;
          color: white !important;
          font-weight: 600 !important;
          border-left: 3px solid var(--clr-accent-coral) !important;
        }

        /* bs4Dash特定的子菜单样式 */
        .nav-treeview {
          background: var(--clr-primary-700) !important;
        }

        .nav-treeview .nav-item {
          margin: 0 !important;
        }

        .nav-treeview .nav-link {
          color: rgba(255, 255, 255, 0.9) !important;
          padding: 8px 8px 8px 8px !important;
          text-align: left !important;
          font-size: 14px !important;
          border-radius: 0 !important;
        }

        .nav-treeview .nav-link:hover {
          background: var(--clr-primary-300) !important;
          color: white !important;
        }

        .nav-treeview .nav-link.active {
          background: var(--clr-primary-300) !important;
          color: white !important;
          font-weight: 600 !important;
        }

        /* 强制所有子菜单项的文本左对齐 - 覆盖所有可能的情况 */
        .sidebar-menu .treeview-menu li,
        .main-sidebar .sidebar-menu .treeview-menu li,
        .nav-treeview .nav-item,
        .sidebar-menu .treeview-menu li a,
        .main-sidebar .sidebar-menu .treeview-menu li a,
        .nav-treeview .nav-item .nav-link,
        .sidebar-menu .treeview-menu li a *,
        .main-sidebar .sidebar-menu .treeview-menu li a *,
        .nav-treeview .nav-item .nav-link * {
          text-align: left !important;
          justify-content: flex-start !important;
          align-items: flex-start !important;
          padding-left: 15px !important;
          margin-left: 0 !important;
          text-indent: 0 !important;
          box-sizing: border-box !important;
        }

        /* 特别处理子菜单中的任何图标或文本元素 */
        .sidebar-menu .treeview-menu li a i,
        .main-sidebar .sidebar-menu .treeview-menu li a i,
        .nav-treeview .nav-item .nav-link i {
          margin-right: 8px !important;
          margin-left: 0 !important;
          text-align: center !important;
          width: 16px !important;
          display: inline-block !important;
        }

        /* 完全重置子菜单项的文本定位 - 最终方案 */
        .sidebar-menu .treeview-menu > li > a,
        .main-sidebar .sidebar-menu .treeview-menu > li > a,
        .nav-treeview .nav-item > .nav-link {
          position: relative !important;
          padding: 8px 8px 8px 8px !important;
          margin: 0 !important;
          text-align: left !important;
          display: flex !important;
          align-items: center !important;
          justify-content: flex-start !important;
          white-space: nowrap !important;
          overflow: hidden !important;
          text-overflow: ellipsis !important;
        }

        /* 子菜单文本内容强制左对齐 */
        .sidebar-menu .treeview-menu > li > a::before,
        .main-sidebar .sidebar-menu .treeview-menu > li > a::before,
        .nav-treeview .nav-item > .nav-link::before {
          content: \"\" !important;
          position: absolute !important;
          left: 8px !important;
          width: 0 !important;
          height: 0 !important;
        }

        .sidebar-menu .treeview-menu > li > a > span,
        .main-sidebar .sidebar-menu .treeview-menu > li > a > span,
        .nav-treeview .nav-item > .nav-link > span {
          margin-left: 0 !important;
          padding-left: 0 !important;
          text-indent: 0 !important;
          display: inline-block !important;
          width: 100% !important;
          text-align: left !important;
        }

        /* 强制所有侧边栏文本都是白色 */
        .main-sidebar *,
        .sidebar * {
          color: white !important;
        }

        /* 覆盖品牌链接 */
        .main-sidebar .brand-link {
          background-color: var(--clr-primary-500) !important;
          color: white !important;
          border-bottom: 1px solid var(--clr-primary-300) !important;
        }

        /* 强制覆盖默认的蓝色主题 */
        .btn-primary, .bg-primary, .badge-primary {
          background-color: var(--clr-primary-500) !important;
          border-color: var(--clr-primary-500) !important;
        }

        /* 强制所有页面标题使用绿色主题色 */
        h1, h2, h3, h4, h5, h6 {
          color: var(--clr-primary-500) !important;
        }

        h1.pageTitle, h2.pageTitle, h3.pageTitle {
          color: var(--clr-primary-500) !important;
        }

        /* 模块描述样式 */
        .module-description {
          background: #f8f9fa;
          padding: 15px;
          border-radius: 8px;
          margin-bottom: 20px;
          border-left: 4px solid var(--clr-primary-500);
        }

        /* 输入容器样式 */
        .input-container {
          background: white;
          padding: 20px;
          border-radius: 10px;
          box-shadow: var(--shadow-md);
          margin-bottom: 20px;
        }

        /* 结果容器样式 */
        .result-container, .data-container {
          background: white;
          padding: 20px;
          border-radius: 10px;
          box-shadow: var(--shadow-md);
          margin-bottom: 20px;
        }

        /* 下载按钮样式 */
        .download-buttons {
          display: inline-block;
        }

        .download-buttons .btn {
          margin: 0 5px;
        }
      ")),

      # 条件加载分析按钮禁用状态样式
      if(isTRUE(enable_ai)) tags$style(HTML("
        .btn-disabled {
          opacity: 0.5 !important;
          cursor: not-allowed !important;
          pointer-events: none !important;
        }

        .btn-disabled::after {
          content: ' (AI Analyzing...)';
          font-size: 0.8em;
          color: #666;
        }
      "))
    ),

    generate_dashboard_body(),

    # 条件加载AI聊天机器人组件
    if(isTRUE(enable_ai)) tagList(
      aiChatFloatingButtonUI("ai_chat"),
      aiChatUI("ai_chat")
    )
  )
)

# 使用示例：如何在实际应用中使用
# 在你的主ui.R文件中，你可以：
# 1. source("ui_refactored.R")
# 2. 然后使用重构后的ui对象