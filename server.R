

server <- function(input, output, session) {
  
  # ==== Introduction ====
  output$home_slick_output <- renderSlickR({
    x <- slickR(slick_intro_plot,slideType = "img",
                slideId = 'slick_intro_plot_id',
                height = 600,
                width = '50%')  + 
      settings(dots = FALSE)
  })
  
  # ==== Module2 ====
  shinyjs::hide(id ="DE_overall_vol_result_sum")
  observeEvent(input$DE_all_vol_update, {
    shinyjs::show(id ="DE_overall_vol_result_sum")
  })
  
  DE_overall_vol_dataset_tmp <- eventReactive(input$DE_all_vol_update, {
    input$DE_overall_vol_dataset
  })
  
  DE_overall_volcano_result_plot_show_tmp <- reactive({
    # feedback: 检测输入的基因是否正确
    shinyFeedback::feedbackWarning(inputId = "DE_overall_vol_dataset",
                                   show = !(DE_overall_vol_dataset_tmp() %in% gene2sym$SYMBOL),
                                   text = "Please input the correct gene symbol !")

    req(DE_overall_vol_dataset_tmp() %in% gene2sym$SYMBOL)

    dbGIST_boxplot_Gender(ID = DE_overall_vol_dataset_tmp(), DB = dbGIST_matrix[Gender_ID])
  })
  
  # 展示与性别分析相关的数据
  DE_overall_vol_result_data_panel_tmp <- reactive({
    req(DE_overall_vol_dataset_tmp() %in% gene2sym$SYMBOL)
    
    # 构建与分析相关的数据表
    result_data <- data.frame()
    
    for(i in 1:length(dbGIST_matrix[Gender_ID])) {
      if(DE_overall_vol_dataset_tmp() %in% rownames(dbGIST_matrix[Gender_ID][[i]]$Matrix)) {
        
        gene_expression <- as.numeric(dbGIST_matrix[Gender_ID][[i]]$Matrix[match(DE_overall_vol_dataset_tmp(), rownames(dbGIST_matrix[Gender_ID][[i]]$Matrix)),])
        
        gender_info <- dbGIST_matrix[Gender_ID][[i]]$Clinical$Gender[match(colnames(dbGIST_matrix[Gender_ID][[i]]$Matrix), dbGIST_matrix[Gender_ID][[i]]$Clinical$geo_accession)]
        
        sample_data <- data.frame(
          Sample_ID = colnames(dbGIST_matrix[Gender_ID][[i]]$Matrix),
          Gene_Expression = gene_expression,
          Gender = gender_info,
          Dataset = dbGIST_matrix[Gender_ID][[i]]$ID,
          stringsAsFactors = FALSE
        )
        
        result_data <- rbind(result_data, sample_data)
      }
    }
    
    return(result_data)
  })
  
  # plot
  output$DE_overall_volcano_result_plot_show <- renderPlot({
    DE_overall_volcano_result_plot_show_tmp()
  }, res = 96)
  
  # data 
  output$DE_overall_vol_result_data_panel <- renderUI({
    
    # 只有gene正确的时候才显示数据
    req(DE_overall_vol_dataset_tmp() %in% gene2sym$SYMBOL)
    
    DT::datatable(DE_overall_vol_result_data_panel_tmp(),
                  caption =paste("Gene Expression Data:",
                                 input$DE_overall_vol_dataset, "by Gender"),
                  #rownames = FALSE,
                  extensions=c('Responsive'),
                  options = list(
                    dom = 'ftipr',
                    pageLength = 10,
                    responsive = TRUE,
                    columnDefs = 
                      list(list(className = 'dt-center', 
                                targets = "_all")),
                    initComplete = DT::JS(
                      "function(settings, json) {",
                      "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
                      "}")
                  ))
  })
  
  ## Download
  output$DE_overall_volcano_download_svg<- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset,".svg",sep="")
    },
    content = function(file){
      svg(file)
      print(DE_overall_volcano_result_plot_show_tmp())
      dev.off()
    }
  )
  
  output$DE_overall_volcano_download_pdf<- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset,".pdf",sep="")
    },
    content = function(file){
      pdf(file)
      print(DE_overall_volcano_result_plot_show_tmp())
      dev.off()
    }
  )
  
  output$DE_overall_volcano_download_png<- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset,".png",sep="")
    },
    content = function(file){
      png(file)
      print(DE_overall_volcano_result_plot_show_tmp())
      dev.off()
    }
  )
  
  output$DE_overall_vol_fulldata_download_csv<-downloadHandler(
    filename = function(){
      paste("dataset_",input$DE_overall_vol_dataset,".csv",sep = "")
    },
    content = function(file){
      sep<-","
      write.table(DE_overall_vol_result_data_panel_tmp(),file,sep=sep,row.names =TRUE)
    }
  )
  
  output$DE_overall_vol_fulldata_download_txt<-downloadHandler(
    filename = function(){
      paste("dataset_",input$DE_overall_vol_dataset,".txt",sep = "")
    },
    content = function(file){
      sep<-" "
      write.table(DE_overall_vol_result_data_panel_tmp(),file,sep=sep,row.names = TRUE)
    }
  )
  
  # ==== Module3 ==== 
  shinyjs::hide(id ="DE_overall_vol_result_sum_3")
  observeEvent(input$DE_all_vol_update_3, {
    shinyjs::show(id ="DE_overall_vol_result_sum_3")
  })
  
  DE_overall_vol_dataset_tmp_3 <- eventReactive(input$DE_all_vol_update_3, {
    input$DE_overall_vol_dataset_3
  })
  DE_overall_vol_dataset_tmp_3_1 <- eventReactive(input$DE_all_vol_update_3, {
    input$DE_overall_vol_dataset_3_1
  })
  
  DE_overall_volcano_result_plot_show_tmp_3 <- reactive({
    # feedback: 检测输入的基因是否正确
    shinyFeedback::feedbackWarning(inputId = "DE_overall_vol_dataset_3",
                                   show = !(DE_overall_vol_dataset_tmp_3() %in% gene2sym$SYMBOL),
                                   text = "Please input the correct gene symbol !")
    
    req(DE_overall_vol_dataset_tmp_3() %in% gene2sym$SYMBOL)
    
    shinyFeedback::feedbackWarning(inputId = "DE_overall_vol_dataset_3_1",
                                   show = !(DE_overall_vol_dataset_tmp_3_1() %in% gene2sym$SYMBOL),
                                   text = "Please input the correct gene symbol !")
    
    req(DE_overall_vol_dataset_tmp_3_1() %in% gene2sym$SYMBOL)
    
    dbGIST_cor_ID(ID = DE_overall_vol_dataset_tmp_3(),ID2 = DE_overall_vol_dataset_tmp_3_1(), DB = dbGIST_matrix[mRNA_ID])
  })
  
  # 展示与相关性分析相关的数据
  DE_overall_vol_result_data_panel_tmp_3 <- reactive({
    req((DE_overall_vol_dataset_tmp_3() %in% gene2sym$SYMBOL) & (DE_overall_vol_dataset_tmp_3_1() %in% gene2sym$SYMBOL))
    
    # 构建相关性分析的数据表
    result_data <- data.frame()
    
    for(i in 1:length(dbGIST_matrix[mRNA_ID])) {
      if(DE_overall_vol_dataset_tmp_3() %in% rownames(dbGIST_matrix[mRNA_ID][[i]]$Matrix) & 
         DE_overall_vol_dataset_tmp_3_1() %in% rownames(dbGIST_matrix[mRNA_ID][[i]]$Matrix)) {
        
        gene1_expression <- as.numeric(dbGIST_matrix[mRNA_ID][[i]]$Matrix[match(DE_overall_vol_dataset_tmp_3(), rownames(dbGIST_matrix[mRNA_ID][[i]]$Matrix)),])
        
        gene2_expression <- as.numeric(dbGIST_matrix[mRNA_ID][[i]]$Matrix[match(DE_overall_vol_dataset_tmp_3_1(), rownames(dbGIST_matrix[mRNA_ID][[i]]$Matrix)),])
        
        # 计算相关性
        correlation_result <- cor.test(gene1_expression, gene2_expression)
        
        sample_data <- data.frame(
          Sample_ID = colnames(dbGIST_matrix[mRNA_ID][[i]]$Matrix),
          Gene1_Expression = gene1_expression,
          Gene2_Expression = gene2_expression,
          Dataset = dbGIST_matrix[mRNA_ID][[i]]$ID,
          stringsAsFactors = FALSE
        )
        
        # 添加相关性统计信息到第一行
        if(nrow(result_data) == 0) {
          attr(sample_data, "correlation") <- list(
            r = round(correlation_result$estimate, 3),
            p_value = round(correlation_result$p.value, 4),
            method = correlation_result$method
          )
        }
        
        result_data <- rbind(result_data, sample_data)
      }
    }
    
    return(result_data)
  })
  
  # plot
  output$DE_overall_volcano_result_plot_show_3 <- renderPlot({
    DE_overall_volcano_result_plot_show_tmp_3()
  }, res = 96)
  
  # data 
  output$DE_overall_vol_result_data_panel_3 <- renderUI({
    
    # 只有gene正确的时候才显示数据
    req((DE_overall_vol_dataset_tmp_3() %in% gene2sym$SYMBOL) & (DE_overall_vol_dataset_tmp_3_1() %in% gene2sym$SYMBOL))
    
    DT::datatable(DE_overall_vol_result_data_panel_tmp_3(),
                  caption =paste("Gene Correlation Data:",
                                 input$DE_overall_vol_dataset_3, "vs", input$DE_overall_vol_dataset_3_1),
                  #rownames = FALSE,
                  extensions=c('Responsive'),
                  options = list(
                    dom = 'ftipr',
                    pageLength = 10,
                    responsive = TRUE,
                    columnDefs = 
                      list(list(className = 'dt-center', 
                                targets = "_all")),
                    initComplete = DT::JS(
                      "function(settings, json) {",
                      "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
                      "}")
                  ))
  })
  
  ## Download
  output$DE_overall_volcano_download_svg_3 <- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset_3, "_", input$DE_overall_vol_dataset_3_1, ".svg",sep="")
    },
    content = function(file){
      svg(file)
      print(DE_overall_volcano_result_plot_show_tmp_3())
      dev.off()
    }
  )
  
  output$DE_overall_volcano_download_pdf_3<- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset_3, "_", input$DE_overall_vol_dataset_3_1, ".pdf",sep="")
    },
    content = function(file){
      pdf(file)
      print(DE_overall_volcano_result_plot_show_tmp_3())
      dev.off()
    }
  )
  
  output$DE_overall_volcano_download_png_3<- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset_3, "_", input$DE_overall_vol_dataset_3_1, ".png",sep="")
    },
    content = function(file){
      png(file)
      print(DE_overall_volcano_result_plot_show_tmp_3())
      dev.off()
    }
  )
  
  output$DE_overall_vol_fulldata_download_csv_3<-downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset_3, "_", input$DE_overall_vol_dataset_3_1, ".csv",sep="")
    },
    content = function(file){
      sep<-","
      write.table(DE_overall_vol_result_data_panel_tmp_3(),file,sep=sep,row.names =TRUE)
    }
  )
  
  output$DE_overall_vol_fulldata_download_txt_3<-downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset_3, "_", input$DE_overall_vol_dataset_3_1, ".txt",sep="")
    },
    content = function(file){
      sep<-" "
      write.table(DE_overall_vol_result_data_panel_tmp_3(),file,sep=sep,row.names = TRUE)
    }
  )
  
  # === Module4 ====
  shinyjs::hide(id ="DE_overall_vol_result_sum_4")
  observeEvent(input$DE_all_vol_update_4, {
    shinyjs::show(id ="DE_overall_vol_result_sum_4")
  })
  
  DE_overall_vol_dataset_tmp_4 <- eventReactive(input$DE_all_vol_update_4, {
    input$DE_overall_vol_dataset_4
  })
  
  DE_overall_volcano_result_plot_show_tmp_4 <- reactive({
    # feedback: 检测输入的基因是否正确
    shinyFeedback::feedbackWarning(inputId = "DE_overall_vol_dataset_4",
                                   show = !(DE_overall_vol_dataset_tmp_4() %in% gene2sym$SYMBOL),
                                   text = "Please input the correct gene symbol !")
    
    req(DE_overall_vol_dataset_tmp_4() %in% gene2sym$SYMBOL)
    
    dbGIST_boxplot_Drug(ID = DE_overall_vol_dataset_tmp_4(),DB = dbGIST_matrix[IM_ID])
  })
  
  # 展示与药物响应分析相关的数据
  DE_overall_vol_result_data_panel_tmp_4 <- reactive({
    req(DE_overall_vol_dataset_tmp_4() %in% gene2sym$SYMBOL)
    
    # 构建与药物响应分析相关的数据表
    result_data <- data.frame()
    
    for(i in 1:length(dbGIST_matrix[IM_ID])) {
      if(DE_overall_vol_dataset_tmp_4() %in% rownames(dbGIST_matrix[IM_ID][[i]]$Matrix)) {
        
        gene_expression <- as.numeric(dbGIST_matrix[IM_ID][[i]]$Matrix[match(DE_overall_vol_dataset_tmp_4(), rownames(dbGIST_matrix[IM_ID][[i]]$Matrix)),])
        
        drug_response <- dbGIST_matrix[IM_ID][[i]]$Clinical$Imatinib[match(colnames(dbGIST_matrix[IM_ID][[i]]$Matrix), dbGIST_matrix[IM_ID][[i]]$Clinical$geo_accession)]
        
        sample_data <- data.frame(
          Sample_ID = colnames(dbGIST_matrix[IM_ID][[i]]$Matrix),
          Gene_Expression = gene_expression,
          Drug_Response = drug_response,
          Dataset = dbGIST_matrix[IM_ID][[i]]$ID,
          stringsAsFactors = FALSE
        )
        
        # 移除缺失值
        sample_data <- sample_data[!is.na(sample_data$Drug_Response) & sample_data$Drug_Response != "NA",]
        
        result_data <- rbind(result_data, sample_data)
      }
    }
    
    return(result_data)
  })
  
  # plot
  output$DE_overall_volcano_result_plot_show_4 <- renderPlot({
    DE_overall_volcano_result_plot_show_tmp_4()
  }, res = 96)
  
  # data 
  output$DE_overall_vol_result_data_panel_4 <- renderUI({
    
    # 只有gene正确的时候才显示数据
    req(DE_overall_vol_dataset_tmp_4() %in% gene2sym$SYMBOL)
    
    DT::datatable(DE_overall_vol_result_data_panel_tmp_4(),
                  caption =paste("Drug Response Data:",
                                 input$DE_overall_vol_dataset_4, "vs Imatinib"),
                  extensions=c('Responsive'),
                  options = list(
                    dom = 'ftipr',
                    pageLength = 10,
                    responsive = TRUE,
                    columnDefs = 
                      list(list(className = 'dt-center', 
                                targets = "_all")),
                    initComplete = DT::JS(
                      "function(settings, json) {",
                      "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
                      "}")
                  ))
  })
  
  ## Download
  output$DE_overall_volcano_download_svg_4 <- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset_4,".svg",sep="")
    },
    content = function(file){
      svg(file)
      print(DE_overall_volcano_result_plot_show_tmp_4())
      dev.off()
    }
  )
  
  output$DE_overall_volcano_download_pdf_4 <- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset_4,".pdf",sep="")
    },
    content = function(file){
      pdf(file)
      print(DE_overall_volcano_result_plot_show_tmp_4())
      dev.off()
    }
  )
  
  output$DE_overall_volcano_download_png_4 <- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset_4,".png",sep="")
    },
    content = function(file){
      png(file)
      print(DE_overall_volcano_result_plot_show_tmp_4())
      dev.off()
    }
  )
  
  output$DE_overall_vol_fulldata_download_csv_4 <- downloadHandler(
    filename = function(){
      paste("dataset_",input$DE_overall_vol_dataset_4,".csv",sep = "")
    },
    content = function(file){
      sep<-","
      write.table(DE_overall_vol_result_data_panel_tmp_4(),file,sep=sep,row.names =TRUE)
    }
  )
  
  output$DE_overall_vol_fulldata_download_txt_4 <- downloadHandler(
    filename = function(){
      paste("dataset_",input$DE_overall_vol_dataset_4,".txt",sep = "")
    },
    content = function(file){
      sep<-" "
      write.table(DE_overall_vol_result_data_panel_tmp_4(),file,sep=sep,row.names = TRUE)
    }
  )
  
  # === Module5 ====
  shinyjs::hide(id ="DE_overall_vol_result_sum_5")
  observeEvent(input$DE_all_vol_update_5, {
    shinyjs::show(id ="DE_overall_vol_result_sum_5")
  })
  
  DE_overall_vol_dataset_tmp_5 <- eventReactive(input$DE_all_vol_update_5, {
    input$DE_overall_vol_dataset_5
  })
  
  DE_overall_volcano_result_plot_show_tmp_5 <- reactive({
    # feedback: 检测输入的基因是否正确
    shinyFeedback::feedbackWarning(inputId = "DE_overall_vol_dataset_5",
                                   show = !(DE_overall_vol_dataset_tmp_5() %in% gene2sym$SYMBOL),
                                   text = "Please input the correct gene symbol !")
    
    req(DE_overall_vol_dataset_tmp_5() %in% gene2sym$SYMBOL)
    
    dbGIST_boxplot_PrePost(ID = DE_overall_vol_dataset_tmp_5(),Mutation = "All",DB = dbGIST_matrix[Post_pre_treament_ID])
  })
  
  # 展示与治疗前后分析相关的数据
  DE_overall_vol_result_data_panel_tmp_5 <- reactive({
    req(DE_overall_vol_dataset_tmp_5() %in% gene2sym$SYMBOL)
    
    # 构建与治疗前后分析相关的数据表
    result_data <- data.frame()
    
    for(i in 1:length(dbGIST_matrix[Post_pre_treament_ID])) {
      if(DE_overall_vol_dataset_tmp_5() %in% rownames(dbGIST_matrix[Post_pre_treament_ID][[i]]$Matrix)) {
        
        # 移除特定样本（与分析函数保持一致）
        Speci_GSE_cli2 <- dbGIST_matrix[Post_pre_treament_ID][[i]]$Clinical[-c(1,6,7,22,23,36,37,40,41,42,43,44,45,46,47,50,53,54),]
        
        gene_expression <- as.numeric(dbGIST_matrix[Post_pre_treament_ID][[i]]$Matrix[which(rownames(dbGIST_matrix[Post_pre_treament_ID][[i]]$Matrix) == DE_overall_vol_dataset_tmp_5()),
                                                                                      match(Speci_GSE_cli2$geo_accession, colnames(dbGIST_matrix[Post_pre_treament_ID][[i]]$Matrix))])
        
        sample_data <- data.frame(
          Sample_ID = Speci_GSE_cli2$geo_accession,
          Gene_Expression = gene_expression,
          Treatment_Type = Speci_GSE_cli2$Type,  # Pre vs Post
          Patient_Group = Speci_GSE_cli2$Group,  # 患者配对ID
          Dataset = dbGIST_matrix[Post_pre_treament_ID][[i]]$ID,
          stringsAsFactors = FALSE
        )
        
        result_data <- rbind(result_data, sample_data)
      }
    }
    
    # 按患者分组排序，便于查看配对数据
    result_data <- result_data[order(result_data$Patient_Group, result_data$Treatment_Type),]
    
    return(result_data)
  })
  
  # plot
  output$DE_overall_volcano_result_plot_show_5 <- renderPlot({
    DE_overall_volcano_result_plot_show_tmp_5()
  }, res = 96)
  
  # data 
  output$DE_overall_vol_result_data_panel_5 <- renderUI({
    
    # 只有gene正确的时候才显示数据
    req(DE_overall_vol_dataset_tmp_5() %in% gene2sym$SYMBOL)
    
    DT::datatable(DE_overall_vol_result_data_panel_tmp_5(),
                  caption =paste("Pre/Post Treatment Data:",
                                 input$DE_overall_vol_dataset_5, "Expression Changes"),
                  extensions=c('Responsive'),
                  options = list(
                    dom = 'ftipr',
                    pageLength = 10,
                    responsive = TRUE,
                    columnDefs = 
                      list(list(className = 'dt-center', 
                                targets = "_all")),
                    initComplete = DT::JS(
                      "function(settings, json) {",
                      "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
                      "}")
                  ))
  })
  
  ## Download
  output$DE_overall_volcano_download_svg_5 <- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset_5,".svg",sep="")
    },
    content = function(file){
      svg(file)
      print(DE_overall_volcano_result_plot_show_tmp_5())
      dev.off()
    }
  )
  
  output$DE_overall_volcano_download_pdf_5 <- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset_5,".pdf",sep="")
    },
    content = function(file){
      pdf(file)
      print(DE_overall_volcano_result_plot_show_tmp_5())
      dev.off()
    }
  )
  
  output$DE_overall_volcano_download_png_5 <- downloadHandler(
    filename = function(){
      paste("Gene_",input$DE_overall_vol_dataset_5,".png",sep="")
    },
    content = function(file){
      png(file)
      print(DE_overall_volcano_result_plot_show_tmp_5())
      dev.off()
    }
  )
  
  output$DE_overall_vol_fulldata_download_csv_5 <- downloadHandler(
    filename = function(){
      paste("dataset_",input$DE_overall_vol_dataset_5,".csv",sep = "")
    },
    content = function(file){
      sep<-","
      write.table(DE_overall_vol_result_data_panel_tmp_5(),file,sep=sep,row.names =TRUE)
    }
  )
  
  output$DE_overall_vol_fulldata_download_txt_5 <- downloadHandler(
    filename = function(){
      paste("dataset_",input$DE_overall_vol_dataset_5,".txt",sep = "")
    },
    content = function(file){
      sep<-" "
      write.table(DE_overall_vol_result_data_panel_tmp_5(),file,sep=sep,row.names = TRUE)
    }
  )
  
}
