# ==== cBioPortal 查询模块 ====

# cBioPortal 模块 UI
cbioportalModuleUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(width = 12, style = "padding: 20px; background-color: #f8f9fa; border-radius: 10px; margin: 10px;",
        # 标题部分
        column(width = 12, align = "center", style = "padding-top: 10px",
          actionBttn(
            inputId = ns("title_btn"),
            label = h1(class = "pageTitle", "cBioPortal Gene Query"),
            style = "minimal",
            color = "primary",
            size = "lg"
          )
        ),
        
        # 描述文字
        column(width = 12, style = "text-align: center; padding: 10px;",
          p("Query gene information on cBioPortal database for GIST studies",
            style = "color: #666; margin-bottom: 20px;")
        )
      )
    ),
    
    # 输入区域
    column(width = 12, style = "padding:25px;",
      box(
        title = "Gene Input",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        
        fluidRow(
          column(width = 6,
            textInput(
              ns("gene_input"),
              label = "Gene Symbol",
              placeholder = "e.g., KIT, TP53, PDGFRA",
              width = "100%"
            ),
            helpText("Enter a gene symbol to query on cBioPortal")
          ),
          
          column(width = 6,
            br(),
            actionButton(
              ns("query_button"),
              "Query on cBioPortal",
              icon = icon("external-link-alt"),
              class = "btn-primary",
              style = "margin-top: 5px; width: 200px;"
            )
          )
        )
      )
    ),
    
    # 信息展示区域
    column(width = 12, style = "padding:25px;",
      box(
        title = "About cBioPortal",
        status = "info",
        solidHeader = FALSE,
        width = 12,
        collapsible = TRUE,
        collapsed = FALSE,
        
        div(style = "padding: 10px;",
          h4("What is cBioPortal?"),
          p("cBioPortal for Cancer Genomics is an open-access, open-source resource for interactive exploration of multidimensional cancer genomics data sets."),
          
          h4("Available GIST Studies"),
          tags$ul(
            tags$li("GIST (MSKCC, 2025)"),
            tags$li("GIST (MSKCC, 2023)"),
            tags$li("GIST (MSKCC, 2022)")
          ),
          
          h4("Data Types"),
          p("The query will show:"),
          tags$ul(
            tags$li("Mutations"),
            tags$li("Structural variants"),
            tags$li("Copy number alterations"),
            tags$li("OncoPrint visualization")
          )
        )
      )
    ),
    
    # 查询历史（可选功能）
    column(width = 12, style = "padding:25px;",
      box(
        title = "Recent Queries",
        status = "success",
        solidHeader = FALSE,
        width = 12,
        collapsible = TRUE,
        collapsed = TRUE,
        
        div(id = ns("query_history"),
          p("No recent queries", style = "color: #999; text-align: center;")
        )
      )
    )
  )
}

# cBioPortal 模块 Server
cbioportalModuleServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # 存储查询历史
    query_history <- reactiveVal(list())
    
    # 处理查询按钮点击
    observeEvent(input$query_button, {
      gene <- trimws(input$gene_input)
      
      # 验证输入
      if(gene == "") {
        showNotification(
          "请输入基因名称",
          type = "warning",
          duration = 3
        )
        return()
      }
      
      # 构建 cBioPortal URL
      base_url <- "https://www.cbioportal.org/results/oncoprint"
      params <- list(
        cancer_study_list = "gist_msk_2025,gist_msk_2022,gist_msk_2023",
        Z_SCORE_THRESHOLD = "2.0",
        RPPA_SCORE_THRESHOLD = "2.0",
        profileFilter = "mutations,structural_variants,gistic,cna",
        case_set_id = "all",
        gene_list = gene,
        geneset_list = " ",
        tab_index = "tab_visualize",
        Action = "Submit",
        plots_horz_selection = '{"selectedDataSourceOption":"gistic"}',
        plots_vert_selection = '{}',
        plots_coloring_selection = '{}'
      )
      
      # 构建完整URL
      query_string <- paste0(
        names(params), "=", 
        URLencode(as.character(params), reserved = TRUE), 
        collapse = "&"
      )
      full_url <- paste0(base_url, "?", query_string)
      
      # 使用JavaScript在新窗口打开链接
      shinyjs::runjs(sprintf("window.open('%s', '_blank');", full_url))
      
      showNotification(
        paste("正在跳转到", gene, "基因的 cBioPortal 页面..."),
        type = "message",
        duration = 3
      )
      
      # 更新查询历史
      current_history <- query_history()
      new_query <- list(
        gene = gene,
        time = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      )
      
      # 限制历史记录为最近10条
      updated_history <- c(list(new_query), current_history)
      if(length(updated_history) > 10) {
        updated_history <- updated_history[1:10]
      }
      query_history(updated_history)
      
      # 更新历史显示
      if(length(updated_history) > 0) {
        history_html <- lapply(updated_history, function(q) {
          tags$div(
            style = "padding: 5px; border-bottom: 1px solid #eee;",
            tags$strong(q$gene),
            tags$span(
              paste(" - ", q$time),
              style = "color: #999; font-size: 0.9em;"
            )
          )
        })
        
        removeUI(paste0("#", ns("query_history"), " > *"), immediate = TRUE)
        insertUI(
          paste0("#", ns("query_history")),
          ui = tagList(history_html)
        )
      }
    })
    
    # 监听回车键
    observeEvent(input$gene_input, {
      if(nchar(trimws(input$gene_input)) > 0) {
        shinyjs::runjs(sprintf("
          $('#%s').keypress(function(e) {
            if(e.which == 13) {
              $('#%s').click();
              return false;
            }
          });
        ", ns("gene_input"), ns("query_button")))
      }
    })
  })
}