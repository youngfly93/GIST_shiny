# ==== 分析模块模板 ====
# 用于创建标准化的分析模块UI和Server组件
# 参考GIST_Protemics的设计模式

# ==== 创建标准化分析UI ====
createAnalysisUI <- function(id, title, description, has_second_gene = FALSE, detailed_description = NULL) {
  ns <- NS(id)
  
  # 构建基因输入区域
  gene_input_area <- if (has_second_gene) {
    fluidRow(
      column(6,
        textInput(
          inputId = ns("gene1"),
          label = "Gene Symbol 1:",
          value = "TP53",
          placeholder = "Enter gene symbol..."
        )
      ),
      column(6,
        textInput(
          inputId = ns("gene2"), 
          label = "Gene Symbol 2:",
          value = "MKI67",
          placeholder = "Enter gene symbol..."
        )
      )
    )
  } else {
    fluidRow(
      column(12,
        textInput(
          inputId = ns("gene"),
          label = "Gene Symbol:",
          value = "TP53",
          placeholder = "Enter gene symbol..."
        )
      )
    )
  }
  
  # 主体UI结构
  fluidPage(
    style = "padding: 20px;",
    
    # 页面标题
    fluidRow(
      column(12,
        div(
          class = "module-header-container",
          style = "background-color: var(--clr-primary-500); text-align: center; margin-bottom: 30px; padding: 20px; border-radius: 8px;",
          h1(title, class = "pageTitle",
             style = "color: white; margin-bottom: 0; font-weight: bold;")
        )
      )
    ),
    
    # 详细描述（如果提供）
    if (!is.null(detailed_description)) {
      fluidRow(
        column(12,
          div(class = "module-description",
              style = "background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid var(--clr-primary-500);",
              p(detailed_description, style = "margin: 0; color: #495057;")
          )
        )
      )
    },
    
    # 基因输入区域
    fluidRow(
      column(12,
        div(class = "input-container",
            style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 20px;",
            h4("Gene Input", style = "color: var(--clr-primary-500); margin-bottom: 15px;"),
            gene_input_area,
            
            # 分析按钮
            fluidRow(
              column(12, style = "text-align: center; margin-top: 15px;",
                actionButton(
                  inputId = ns("analyze"),
                  label = "Start Analysis",
                  class = "btn btn-primary btn-lg",
                  style = "background-color: #1C484C; border-color: #1C484C; padding: 10px 30px; font-weight: bold;"
                )
              )
            )
        )
      )
    ),
    
    # 结果展示区域
    conditionalPanel(
      condition = paste0("input['", ns("analyze"), "'] > 0"),
      
      # 图形结果
      fluidRow(
        column(12,
          div(class = "result-container",
              style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 20px;",
              
              # 结果标题
              fluidRow(
                column(8,
                  h4("Analysis Results", style = "color: #1C484C; margin-bottom: 15px;")
                ),
                column(4, style = "text-align: right;",
                  # AI分析按钮（条件显示）
                  div(id = ns("ai_button_container"),
                    actionButton(
                      inputId = ns("ai_analyze"),
                      label = "AI Analysis",
                      class = "btn btn-success",
                      style = "background-color: #28a745; border-color: #28a745;"
                    )
                  )
                )
              ),
              
              # 图形展示
              fluidRow(
                column(12,
                  withSpinner(
                    plotOutput(ns("plot"), height = "600px"),
                    color = "#1C484C"
                  )
                )
              ),
              
              # 下载按钮区域
              fluidRow(
                column(12, style = "text-align: center; margin-top: 20px;",
                  div(class = "download-buttons",
                      h5("Download Options", style = "color: #1C484C; margin-bottom: 10px;"),
                      downloadButton(ns("download_svg"), "SVG", class = "btn btn-outline-primary"),
                      downloadButton(ns("download_pdf"), "PDF", class = "btn btn-outline-primary"),
                      downloadButton(ns("download_png"), "PNG", class = "btn btn-outline-primary"),
                      style = "display: inline-block;"
                  )
                )
              )
          )
        )
      ),
      
      # 数据表结果
      fluidRow(
        column(12,
          div(class = "data-container",
              style = "background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);",
              
              fluidRow(
                column(8,
                  h4("Data Table", style = "color: #1C484C; margin-bottom: 15px;")
                ),
                column(4, style = "text-align: right;",
                  div(class = "download-buttons",
                      downloadButton(ns("download_csv"), "CSV", class = "btn btn-outline-success btn-sm"),
                      downloadButton(ns("download_txt"), "TXT", class = "btn btn-outline-success btn-sm")
                  )
                )
              ),
              
              DT::dataTableOutput(ns("data_table"))
          )
        )
      )
    )
  )
}

# ==== 创建标准化分析Server ====
createAnalysisServer <- function(id, analysis_function, extract_data_function, global_state = NULL, has_second_gene = FALSE) {
  moduleServer(id, function(input, output, session) {
    
    # 响应式数据存储
    analysis_data <- reactiveVal(NULL)
    plot_data <- reactiveVal(NULL)
    
    # 分析逻辑
    observeEvent(input$analyze, {
      
      # 更新AI分析状态
      if (!is.null(global_state)) {
        global_state$ai_analyzing <- FALSE
        global_state$analyzing_gene <- NULL
      }
      
      # 获取基因输入
      gene1 <- if (has_second_gene) input$gene1 else input$gene
      gene2 <- if (has_second_gene) input$gene2 else NULL
      
      # 验证基因符号
      if (has_second_gene) {
        req(gene1 %in% gene2sym$SYMBOL, gene2 %in% gene2sym$SYMBOL)
        
        # 反馈验证
        shinyFeedback::feedbackWarning(
          inputId = "gene1",
          show = !(gene1 %in% gene2sym$SYMBOL),
          text = "Please input the correct gene symbol!"
        )
        shinyFeedback::feedbackWarning(
          inputId = "gene2", 
          show = !(gene2 %in% gene2sym$SYMBOL),
          text = "Please input the correct gene symbol!"
        )
      } else {
        req(gene1 %in% gene2sym$SYMBOL)
        
        shinyFeedback::feedbackWarning(
          inputId = "gene",
          show = !(gene1 %in% gene2sym$SYMBOL),
          text = "Please input the correct gene symbol!"
        )
      }
      
      # 执行分析
      tryCatch({
        if (has_second_gene) {
          result <- analysis_function(ID = gene1, ID2 = gene2)
          data_result <- extract_data_function(gene1, gene2)
        } else {
          result <- analysis_function(ID = gene1)
          data_result <- extract_data_function(gene1)
        }
        
        plot_data(result)
        analysis_data(data_result)
        
        # 更新AI状态
        if (!is.null(global_state)) {
          global_state$analyzing_gene <- if (has_second_gene) paste(gene1, gene2, sep = " vs ") else gene1
        }
        
      }, error = function(e) {
        showNotification(
          paste("Analysis failed:", e$message),
          type = "error",
          duration = 5
        )
      })
    })
    
    # 图形输出
    output$plot <- renderPlot({
      req(plot_data())
      plot_data()
    }, res = 96)
    
    # 数据表输出
    output$data_table <- DT::renderDataTable({
      req(analysis_data())
      
      DT::datatable(
        analysis_data(),
        extensions = c('Responsive'),
        options = list(
          dom = 'ftipr',
          pageLength = 10,
          responsive = TRUE,
          columnDefs = list(
            list(className = 'dt-center', targets = "_all")
          ),
          initComplete = DT::JS(
            "function(settings, json) {",
            "$(this.api().table().header()).css({'background-color': '#1C484C', 'color': '#fff'});",
            "}"
          )
        )
      )
    })
    
    # 下载处理器
    output$download_svg <- downloadHandler(
      filename = function() {
        gene_name <- if (has_second_gene) {
          paste(input$gene1, input$gene2, sep = "_")
        } else {
          input$gene
        }
        paste0("analysis_", gene_name, ".svg")
      },
      content = function(file) {
        svg(file)
        print(plot_data())
        dev.off()
      }
    )
    
    output$download_pdf <- downloadHandler(
      filename = function() {
        gene_name <- if (has_second_gene) {
          paste(input$gene1, input$gene2, sep = "_")
        } else {
          input$gene
        }
        paste0("analysis_", gene_name, ".pdf")
      },
      content = function(file) {
        pdf(file)
        print(plot_data())
        dev.off()
      }
    )
    
    output$download_png <- downloadHandler(
      filename = function() {
        gene_name <- if (has_second_gene) {
          paste(input$gene1, input$gene2, sep = "_")
        } else {
          input$gene
        }
        paste0("analysis_", gene_name, ".png")
      },
      content = function(file) {
        png(file)
        print(plot_data())
        dev.off()
      }
    )
    
    output$download_csv <- downloadHandler(
      filename = function() {
        gene_name <- if (has_second_gene) {
          paste(input$gene1, input$gene2, sep = "_")
        } else {
          input$gene
        }
        paste0("data_", gene_name, ".csv")
      },
      content = function(file) {
        write.csv(analysis_data(), file, row.names = FALSE)
      }
    )
    
    output$download_txt <- downloadHandler(
      filename = function() {
        gene_name <- if (has_second_gene) {
          paste(input$gene1, input$gene2, sep = "_")
        } else {
          input$gene
        }
        paste0("data_", gene_name, ".txt")
      },
      content = function(file) {
        write.table(analysis_data(), file, sep = "\t", row.names = FALSE)
      }
    )
    
    # AI分析功能（条件启用）
    if (!is.null(global_state)) {
      observeEvent(input$ai_analyze, {
        if (!is.null(global_state$ai_enabled) && global_state$ai_enabled) {
          # AI分析逻辑
          global_state$ai_analyzing <- TRUE
          
          # 这里将连接到AI分析模块
          showNotification(
            "AI analysis started...",
            type = "message",
            duration = 3
          )
        }
      })
    }
    
    # 返回响应式数据以供外部使用
    return(list(
      plot_data = plot_data,
      analysis_data = analysis_data
    ))
  })
}

# ==== 配置管理函数 ====
createModuleConfig <- function(title, icon, description, analysis_function, data_function, has_second_gene = FALSE) {
  list(
    title = title,
    icon = icon, 
    description = description,
    analysis_function = analysis_function,
    data_function = data_function,
    has_second_gene = has_second_gene
  )
}