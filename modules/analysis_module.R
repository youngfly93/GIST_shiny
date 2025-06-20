# ==== 通用分析模块 ====

# 模块UI函数
analysisModuleUI <- function(id, title, input_config, has_second_gene = FALSE, detailed_description = NULL) {
  ns <- NS(id)

  # 创建带有悬停提示的标题
  title_with_tooltip <- if(!is.null(detailed_description)) {
    h1(class = "pageTitle module-title-with-tooltip",
       title,
       `data-tooltip` = detailed_description,
       style = "cursor: help;"
    )
  } else {
    h1(class = "pageTitle", title)
  }

  fluidRow(
    column(width = 12, style = "padding: 20px; background-color: #f8f9fa; border-radius: 10px; margin: 10px;",
      # 标题部分
      column(width = 12, align = "center", style = "padding-top: 10px",
        actionBttn(
          inputId = ns("title_btn"),
          label = title_with_tooltip,
          style = "minimal",
          color = "primary",
          size = "lg"
        )
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
        
        # 下载按钮
        fluidRow(
          column(width = 12, align = "center", style = "padding: 20px;",
            h4("Download Results"),
            fluidRow(
              column(width = 3,
                downloadButton(ns("download_svg"), "SVG", class = "btn-outline-primary")
              ),
              column(width = 3,
                downloadButton(ns("download_pdf"), "PDF", class = "btn-outline-primary")
              ),
              column(width = 3,
                downloadButton(ns("download_png"), "PNG", class = "btn-outline-primary")
              ),
              column(width = 3,
                downloadButton(ns("download_data"), "Data", class = "btn-outline-primary")
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
      analysis_result()
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
    
    # 返回响应式值供外部使用
    return(list(
      gene1 = gene1_input,
      gene2 = gene2_input,
      plot = analysis_result,
      data = data_result
    ))
  })
} 