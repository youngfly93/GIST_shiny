# ==== 数据处理工具集 ====

# 通用数据生成器类
DataGenerator <- R6::R6Class("DataGenerator",
  public = list(
    # 初始化
    initialize = function() {
      private$validate_environment()
    },
    
    # 生成性别分析数据
    generate_gender_data = function(gene_id) {
      self$validate_gene(gene_id)
      
      result_data <- data.frame()
      
      for(i in 1:length(dbGIST_matrix[Gender_ID])) {
        if(gene_id %in% rownames(dbGIST_matrix[Gender_ID][[i]]$Matrix)) {
          
          gene_expression <- as.numeric(dbGIST_matrix[Gender_ID][[i]]$Matrix[
            match(gene_id, rownames(dbGIST_matrix[Gender_ID][[i]]$Matrix)),
          ])
          
          gender_info <- dbGIST_matrix[Gender_ID][[i]]$Clinical$Gender[
            match(colnames(dbGIST_matrix[Gender_ID][[i]]$Matrix), 
                  dbGIST_matrix[Gender_ID][[i]]$Clinical$geo_accession)
          ]
          
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
      
      # 清理数据
      result_data <- self$clean_data(result_data, "Gender")
      
      return(result_data)
    },
    
    # 生成相关性分析数据
    generate_correlation_data = function(gene1_id, gene2_id) {
      self$validate_gene(gene1_id)
      self$validate_gene(gene2_id)
      
      result_data <- data.frame()
      correlation_stats <- list()
      
      for(i in 1:length(dbGIST_matrix[mRNA_ID])) {
        if(gene1_id %in% rownames(dbGIST_matrix[mRNA_ID][[i]]$Matrix) & 
           gene2_id %in% rownames(dbGIST_matrix[mRNA_ID][[i]]$Matrix)) {
          
          gene1_expression <- as.numeric(dbGIST_matrix[mRNA_ID][[i]]$Matrix[
            match(gene1_id, rownames(dbGIST_matrix[mRNA_ID][[i]]$Matrix)),
          ])
          
          gene2_expression <- as.numeric(dbGIST_matrix[mRNA_ID][[i]]$Matrix[
            match(gene2_id, rownames(dbGIST_matrix[mRNA_ID][[i]]$Matrix)),
          ])
          
          # 计算相关性
          correlation_result <- cor.test(gene1_expression, gene2_expression)
          
          sample_data <- data.frame(
            Sample_ID = colnames(dbGIST_matrix[mRNA_ID][[i]]$Matrix),
            Gene1_Expression = gene1_expression,
            Gene2_Expression = gene2_expression,
            Dataset = dbGIST_matrix[mRNA_ID][[i]]$ID,
            stringsAsFactors = FALSE
          )
          
          # 存储相关性统计
          correlation_stats[[i]] <- list(
            r = round(correlation_result$estimate, 3),
            p_value = round(correlation_result$p.value, 4),
            method = correlation_result$method,
            dataset = dbGIST_matrix[mRNA_ID][[i]]$ID
          )
          
          result_data <- rbind(result_data, sample_data)
        }
      }
      
      # 添加相关性信息作为属性
      attr(result_data, "correlation_stats") <- correlation_stats
      
      return(result_data)
    },
    
    # 生成药物响应数据
    generate_drug_data = function(gene_id) {
      self$validate_gene(gene_id)
      
      result_data <- data.frame()
      
      for(i in 1:length(dbGIST_matrix[IM_ID])) {
        if(gene_id %in% rownames(dbGIST_matrix[IM_ID][[i]]$Matrix)) {
          
          gene_expression <- as.numeric(dbGIST_matrix[IM_ID][[i]]$Matrix[
            match(gene_id, rownames(dbGIST_matrix[IM_ID][[i]]$Matrix)),
          ])
          
          drug_response <- dbGIST_matrix[IM_ID][[i]]$Clinical$Imatinib[
            match(colnames(dbGIST_matrix[IM_ID][[i]]$Matrix), 
                  dbGIST_matrix[IM_ID][[i]]$Clinical$geo_accession)
          ]
          
          sample_data <- data.frame(
            Sample_ID = colnames(dbGIST_matrix[IM_ID][[i]]$Matrix),
            Gene_Expression = gene_expression,
            Drug_Response = drug_response,
            Dataset = dbGIST_matrix[IM_ID][[i]]$ID,
            stringsAsFactors = FALSE
          )
          
          result_data <- rbind(result_data, sample_data)
        }
      }
      
      # 清理数据
      result_data <- self$clean_data(result_data, "Drug_Response")
      
      return(result_data)
    },
    
    # 生成治疗前后数据
    generate_prepost_data = function(gene_id) {
      self$validate_gene(gene_id)
      
      result_data <- data.frame()
      
      for(i in 1:length(dbGIST_matrix[Post_pre_treament_ID])) {
        if(gene_id %in% rownames(dbGIST_matrix[Post_pre_treament_ID][[i]]$Matrix)) {
          
          # 移除特定样本（与分析函数保持一致）
          Speci_GSE_cli2 <- dbGIST_matrix[Post_pre_treament_ID][[i]]$Clinical[
            -c(1,6,7,22,23,36,37,40,41,42,43,44,45,46,47,50,53,54),
          ]
          
          gene_expression <- as.numeric(dbGIST_matrix[Post_pre_treament_ID][[i]]$Matrix[
            which(rownames(dbGIST_matrix[Post_pre_treament_ID][[i]]$Matrix) == gene_id),
            match(Speci_GSE_cli2$geo_accession, colnames(dbGIST_matrix[Post_pre_treament_ID][[i]]$Matrix))
          ])
          
          sample_data <- data.frame(
            Sample_ID = Speci_GSE_cli2$geo_accession,
            Gene_Expression = gene_expression,
            Treatment_Type = Speci_GSE_cli2$Type,
            Patient_Group = Speci_GSE_cli2$Group,
            Dataset = dbGIST_matrix[Post_pre_treament_ID][[i]]$ID,
            stringsAsFactors = FALSE
          )
          
          result_data <- rbind(result_data, sample_data)
        }
      }
      
      # 按患者分组排序
      result_data <- result_data[order(result_data$Patient_Group, result_data$Treatment_Type),]
      
      return(result_data)
    },
    
    # 验证基因名
    validate_gene = function(gene_id) {
      if(is.null(gene_id) || gene_id == "" || !(gene_id %in% gene2sym$SYMBOL)) {
        stop(paste("Invalid gene symbol:", gene_id))
      }
    },
    
    # 清理数据
    clean_data = function(data, grouping_col) {
      if(grouping_col %in% names(data)) {
        # 移除缺失值和NA标记
        data <- data[!is.na(data[[grouping_col]]) & data[[grouping_col]] != "NA",]
      }
      return(data)
    },
    
    # 生成统计摘要
    generate_summary = function(data, group_col = "Gender") {
      if(nrow(data) == 0 || !group_col %in% names(data)) return(NULL)
      
      summary_stats <- data %>%
        group_by(!!sym(group_col)) %>%
        summarise(
          Count = n(),
          Mean = round(mean(Gene_Expression, na.rm = TRUE), 3),
          Median = round(median(Gene_Expression, na.rm = TRUE), 3),
          SD = round(sd(Gene_Expression, na.rm = TRUE), 3),
          Min = round(min(Gene_Expression, na.rm = TRUE), 3),
          Max = round(max(Gene_Expression, na.rm = TRUE), 3),
          .groups = 'drop'
        )
      
      return(summary_stats)
    }
  ),
  
  private = list(
    # 验证环境
    validate_environment = function() {
      required_objects <- c("gene2sym", "dbGIST_matrix", "Gender_ID", "mRNA_ID", "IM_ID", "Post_pre_treament_ID")
      
      for(obj in required_objects) {
        if(!exists(obj, envir = .GlobalEnv)) {
          stop(paste("Required object not found:", obj))
        }
      }
    }
  )
)

# 创建全局数据生成器实例
data_generator <- DataGenerator$new()

# 便利函数包装器
generate_module_data <- function(type, gene1, gene2 = NULL) {
  switch(type,
    "gender" = data_generator$generate_gender_data(gene1),
    "correlation" = data_generator$generate_correlation_data(gene1, gene2),
    "drug" = data_generator$generate_drug_data(gene1),
    "prepost" = data_generator$generate_prepost_data(gene1),
    stop("Unknown analysis type:", type)
  )
}

# 全局函数导出（用于配置文件引用）
generate_gender_data <- function(gene1, gene2 = NULL) {
  data_generator$generate_gender_data(gene1)
}

generate_correlation_data <- function(gene1, gene2) {
  data_generator$generate_correlation_data(gene1, gene2)
}

generate_drug_data <- function(gene1, gene2 = NULL) {
  data_generator$generate_drug_data(gene1)
}

generate_prepost_data <- function(gene1, gene2 = NULL) {
  data_generator$generate_prepost_data(gene1)
} 