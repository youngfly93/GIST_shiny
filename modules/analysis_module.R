# ==== 通用分析模块 ====

# 模块UI函数
analysisModuleUI <- function(id, title, input_config, has_second_gene = FALSE, detailed_description = NULL) {
  ns <- NS(id)

  fluidRow(
    column(width = 12, style = "padding: 20px; background-color: #f8f9fa; border-radius: 10px; margin: 10px;",
      # 标题部分
      column(width = 12, align = "center", style = "padding-top: 10px",
        actionBttn(
          inputId = ns("title_btn"),
          label = h1(class = "pageTitle", title),
          style = "minimal",
          color = "primary",
          size = "lg"
        )
      ),

      # 模块描述部分
      column(width = 12, style = "text-align: center; padding: 10px 20px;",
        p(paste("Description:", if(!is.null(detailed_description)) detailed_description else "No description provided"),
          class = "module-description",
          style = "color: #666; margin-bottom: 20px; font-size: 14px; line-height: 1.5; max-width: 800px; margin-left: auto; margin-right: auto; background-color: rgba(28, 72, 76, 0.05); border-left: 3px solid #1C484C; padding: 15px; border-radius: 0 5px 5px 0;")
      ),
      
      # 输入控件部分
      column(width = 12, style = "padding: 20px;",
        fluidRow(
          # 第一个基因输入
          column(width = if(has_second_gene) 6 else 12,
            textInput(
              inputId = ns("gene1"),
              label = input_config$gene1_label,
              placeholder = input_config$gene1_placeholder
            )
          ),
          
          # 第二个基因输入（仅相关性分析使用）
          if(has_second_gene) {
            column(width = 6,
              textInput(
                inputId = ns("gene2"),
                label = input_config$gene2_label,
                placeholder = input_config$gene2_placeholder
              )
            )
          },
          
          # 分析按钮
          column(width = 12, align = "center", style = "padding: 10px;",
            actionButton(
              inputId = ns("analyze_btn"),
              label = "Visualize",
              icon = icon('palette'),
              class = "btn-primary btn-lg"
            )
          )
        )
      ),
      
      # 结果展示区域（初始隐藏）
      column(width = 12, id = ns("result_container"),
        tabsetPanel(
          id = ns("result_tabs"),
          tabPanel("Plot",
            div(style = "width:100%; height:1200px; overflow:auto; border: 1px solid #ddd;",
              plotOutput(ns("result_plot"), height = "1200px", width = "1400px")
            )
          ),
          tabPanel("Data",
            DT::dataTableOutput(ns("result_table"))
          )
        ),
        
        # 下载按钮和AI分析
        fluidRow(
          column(width = 12, align = "center", style = "padding: 20px;",
            h4("Download Results & AI Analysis"),
            fluidRow(
              column(width = 2,
                downloadButton(ns("download_svg"), "SVG", class = "btn-outline-primary")
              ),
              column(width = 2,
                downloadButton(ns("download_pdf"), "PDF", class = "btn-outline-primary")
              ),
              column(width = 2,
                downloadButton(ns("download_png"), "PNG", class = "btn-outline-primary")
              ),
              column(width = 2,
                downloadButton(ns("download_data"), "Data", class = "btn-outline-primary")
              ),
              column(width = 4,
                div(
                  style = "text-align: center; padding: 10px; color: #7fb069; font-weight: bold;",
                  icon("robot"), " AI自动分析已启用"
                )
              )
            )
          )
        )
      )
    )
  )
}

# 模块Server函数
analysisModuleServer <- function(id, analysis_config) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # 隐藏结果区域
    shinyjs::hide("result_container")

    # 存储当前图片路径
    current_plot_path <- reactiveVal(NULL)
    
    # 响应式变量
    gene1_input <- eventReactive(input$analyze_btn, {
      input$gene1
    })
    
    gene2_input <- eventReactive(input$analyze_btn, {
      if(analysis_config$has_second_gene) input$gene2 else NULL
    })
    
    # 输入验证
    observe({
      # 验证第一个基因
      shinyFeedback::feedbackWarning(
        inputId = "gene1",
        show = !is.null(gene1_input()) && !(gene1_input() %in% gene2sym$SYMBOL),
        text = "Please input the correct gene symbol!"
      )
      
      # 验证第二个基因（如果需要）
      if(analysis_config$has_second_gene) {
        shinyFeedback::feedbackWarning(
          inputId = "gene2",
          show = !is.null(gene2_input()) && !(gene2_input() %in% gene2sym$SYMBOL),
          text = "Please input the correct gene symbol!"
        )
      }
    })
    
    # 生成分析结果
    analysis_result <- reactive({
      # 验证输入
      req(gene1_input() %in% gene2sym$SYMBOL)
      if(analysis_config$has_second_gene) {
        req(gene2_input() %in% gene2sym$SYMBOL)
      }
      
      
      # 获取函数对象
      analysis_func <- get(analysis_config$analysis_function)
      
      # 调用相应的分析函数
      if(analysis_config$type == "gender") {
        analysis_func(ID = gene1_input(), DB = dbGIST_matrix[Gender_ID])
      } else if(analysis_config$type == "correlation") {
        analysis_func(ID = gene1_input(), ID2 = gene2_input(), DB = dbGIST_matrix[mRNA_ID])
      } else if(analysis_config$type == "drug") {
        analysis_func(ID = gene1_input(), DB = dbGIST_matrix[IM_ID])
      } else if(analysis_config$type == "prepost") {
        analysis_func(ID = gene1_input(), Mutation = "All", DB = dbGIST_matrix[Post_pre_treament_ID])
      }
    })
    
    # 生成数据表
    data_result <- reactive({
      # 验证输入
      req(gene1_input() %in% gene2sym$SYMBOL)
      if(analysis_config$has_second_gene) {
        req(gene2_input() %in% gene2sym$SYMBOL)
      }
      
      # 获取数据生成函数并调用
      data_func <- get(analysis_config$data_function)
      data_func(gene1_input(), gene2_input())
    })
    
    # 显示结果区域
    observeEvent(input$analyze_btn, {
      shinyjs::show("result_container")
    })
    
    # 渲染图表
    output$result_plot <- renderPlot({
      plot_result <- analysis_result()

      # 保存图片到www目录供AI分析使用
      plot_filename <- paste0("plot_", Sys.time() %>% as.numeric() %>% round(), ".png")
      plot_path <- file.path("www", plot_filename)

      # 确保www目录存在
      if (!dir.exists("www")) {
        dir.create("www", recursive = TRUE)
      }

      # 保存图片
      png(plot_path, width = 1400, height = 1200, res = 120)
      print(plot_result)
      dev.off()

      # 存储完整路径
      current_plot_path(normalizePath(plot_path))

      # 图片生成完成后，自动触发AI分析
      cat("Plot generated, auto-triggering AI analysis\n")
      cat("Plot path:", plot_path, "\n")

      # 使用相对于www的路径，而不是绝对路径
      relative_plot_path <- plot_filename  # 只使用文件名，因为图片在www目录下

      session$sendCustomMessage("updateAIInput", list(
        plotPath = normalizePath(plot_path),  # 服务器端使用完整路径
        relativePath = relative_plot_path,    # 前端使用相对路径
        gene1 = gene1_input(),
        gene2 = if(analysis_config$has_second_gene) gene2_input() else NULL,
        analysisType = analysis_config$type,
        timestamp = as.numeric(Sys.time()),
        autoTriggered = TRUE
      ))

      return(plot_result)
    }, res = 120, height = 1200, width = 1400)
    
    # 渲染数据表
    output$result_table <- DT::renderDataTable({
      data <- data_result()
      
      DT::datatable(
        data,
        caption = analysis_config$table_caption(gene1_input(), gene2_input()),
        extensions = c('Responsive'),
        options = list(
          dom = 'ftipr',
          pageLength = 10,
          responsive = TRUE,
          columnDefs = list(list(className = 'dt-center', targets = "_all")),
          initComplete = DT::JS(
            "function(settings, json) {",
            "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
            "}"
          )
        )
      )
    })
    
    # 下载处理器
    output$download_svg <- downloadHandler(
      filename = function() {
        if(analysis_config$has_second_gene) {
          paste0("Gene_", gene1_input(), "_", gene2_input(), ".svg")
        } else {
          paste0("Gene_", gene1_input(), ".svg")
        }
      },
      content = function(file) {
        svg(file)
        print(analysis_result())
        dev.off()
      }
    )
    
    output$download_pdf <- downloadHandler(
      filename = function() {
        if(analysis_config$has_second_gene) {
          paste0("Gene_", gene1_input(), "_", gene2_input(), ".pdf")
        } else {
          paste0("Gene_", gene1_input(), ".pdf")
        }
      },
      content = function(file) {
        pdf(file)
        print(analysis_result())
        dev.off()
      }
    )
    
    output$download_png <- downloadHandler(
      filename = function() {
        if(analysis_config$has_second_gene) {
          paste0("Gene_", gene1_input(), "_", gene2_input(), ".png")
        } else {
          paste0("Gene_", gene1_input(), ".png")
        }
      },
      content = function(file) {
        png(file)
        print(analysis_result())
        dev.off()
      }
    )
    
    output$download_data <- downloadHandler(
      filename = function() {
        if(analysis_config$has_second_gene) {
          paste0("Gene_", gene1_input(), "_", gene2_input(), ".csv")
        } else {
          paste0("Gene_", gene1_input(), ".csv")
        }
      },
      content = function(file) {
        write.csv(data_result(), file, row.names = TRUE)
      }
    )
    
    # AI分析现在是自动触发的，不需要手动按钮事件

    # 返回响应式值供外部使用
    return(list(
      gene1 = gene1_input,
      gene2 = gene2_input,
      plot = analysis_result,
      data = data_result,
      plot_path = current_plot_path
    ))
  })
} 