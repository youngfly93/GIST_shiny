# ==== 模块配置文件 ====
# 定义所有分析模块的配置信息
# 参考GIST_Protemics的设计模式

# ==== 模块元数据定义 ====
module_metadata <- list(
  # 介绍页面
  introduction = list(
    title = "Welcome to GIST Gene Expression Analysis Platform",
    icon = "home",
    description = "Comprehensive bioinformatics analysis platform for GIST genomic research"
  ),
  
  # Module 1: 临床特征分析（11个子模块）
  module1_tvn = list(
    title = "Tumor vs Normal Analysis",
    icon = "balance-scale",
    description = "Compare gene expression between tumor and normal tissues",
    detailed_description = "Analyze differential gene expression patterns between tumor tissue and normal tissue samples using statistical comparisons and visualization."
  ),
  
  module1_risk = list(
    title = "Risk Level Analysis", 
    icon = "exclamation-triangle",
    description = "Analyze gene expression across different risk stratifications",
    detailed_description = "Examine how gene expression levels correlate with patient risk classifications and prognosis indicators."
  ),
  
  module1_gender = list(
    title = "Gender-based Analysis",
    icon = "venus-mars", 
    description = "Compare gene expression between male and female patients",
    detailed_description = "Investigate gender-specific differences in gene expression patterns and their clinical implications."
  ),
  
  module1_age = list(
    title = "Age Group Analysis",
    icon = "birthday-cake",
    description = "Analyze gene expression across different age groups", 
    detailed_description = "Study how patient age affects gene expression levels and identify age-related biomarkers."
  ),
  
  module1_tumor_size = list(
    title = "Tumor Size Analysis",
    icon = "expand-arrows-alt",
    description = "Correlate gene expression with tumor size measurements",
    detailed_description = "Examine the relationship between tumor size and gene expression levels using correlation analysis."
  ),
  
  module1_mitotic = list(
    title = "Mitotic Count Analysis",
    icon = "dna",
    description = "Analyze gene expression in relation to mitotic activity",
    detailed_description = "Study how mitotic count correlates with gene expression patterns in GIST samples."
  ),
  
  module1_location = list(
    title = "Tumor Location Analysis",
    icon = "map-marker-alt",
    description = "Compare gene expression across tumor locations",
    detailed_description = "Investigate location-specific gene expression differences in GIST tumors from various anatomical sites."
  ),
  
  module1_who = list(
    title = "WHO Grade Analysis", 
    icon = "layer-group",
    description = "Analyze gene expression by WHO grading system",
    detailed_description = "Compare gene expression patterns across different WHO histological grades and classifications."
  ),
  
  module1_ki67 = list(
    title = "Ki-67 Expression Analysis",
    icon = "dot-circle",
    description = "Study gene expression in relation to Ki-67 proliferation marker",
    detailed_description = "Analyze the correlation between target gene expression and Ki-67 proliferation index."
  ),
  
  module1_cd34 = list(
    title = "CD34 Expression Analysis", 
    icon = "circle",
    description = "Examine gene expression patterns with CD34 marker status",
    detailed_description = "Investigate how CD34 expression status affects target gene expression in GIST samples."
  ),
  
  module1_mutation = list(
    title = "Mutation Status Analysis",
    icon = "random",
    description = "Compare gene expression across mutation subtypes",
    detailed_description = "Analyze gene expression differences between various mutation types (KIT, PDGFRA, wild-type)."
  ),
  
  # Module 2: 单基因表达分析
  module2 = list(
    title = "Single Gene Expression Analysis",
    icon = "dna",
    description = "Comprehensive single gene expression analysis across clinical features", 
    detailed_description = "Perform detailed analysis of individual gene expression patterns across multiple clinical parameters and patient characteristics."
  ),
  
  # Module 3: 基因相关性分析
  module3 = list(
    title = "Gene Correlation Analysis",
    icon = "project-diagram", 
    description = "Analyze expression correlation between two genes",
    detailed_description = "Study the co-expression patterns and statistical correlations between pairs of genes across GIST samples."
  ),
  
  # Module 3a: 富集分析（占位符）
  module3a_enrichment = list(
    title = "Pathway Enrichment Analysis",
    icon = "sitemap",
    description = "GO, KEGG, and Reactome pathway enrichment analysis",
    detailed_description = "Perform comprehensive pathway enrichment analysis using multiple databases including Gene Ontology, KEGG pathways, and Reactome.",
    placeholder = TRUE
  ),
  
  # Module 3b: GSEA分析（占位符）
  module3b_gsea = list(
    title = "Gene Set Enrichment Analysis (GSEA)",
    icon = "chart-line", 
    description = "GSEA analysis with ridge plots and pathway visualization",
    detailed_description = "Conduct Gene Set Enrichment Analysis to identify coordinated changes in predefined gene sets and biological pathways.",
    placeholder = TRUE
  ),
  
  # Module 4: 药物耐药分析
  module4 = list(
    title = "Drug Resistance Analysis",
    icon = "pills",
    description = "Analyze drug resistance patterns with ROC curves",
    detailed_description = "Investigate gene expression patterns associated with drug resistance and generate ROC curves for predictive analysis."
  ),
  
  # Module 5: 生存分析（占位符）
  module5 = list(
    title = "Survival Analysis", 
    icon = "heartbeat",
    description = "Kaplan-Meier survival analysis and prognosis prediction",
    detailed_description = "Perform survival analysis using Kaplan-Meier curves to study the prognostic value of gene expression levels.",
    placeholder = TRUE
  )
)

# ==== 模块配置定义 ====
# 定义createModuleConfig函数
createModuleConfig <- function(title, icon, description, analysis_function, data_function, has_second_gene = FALSE, type = NULL) {
  list(
    title = title,
    icon = icon,
    description = description,
    analysis_function = analysis_function,
    data_function = data_function,
    has_second_gene = has_second_gene,
    type = type
  )
}

# 检查必要的变量是否存在
required_vars <- c("dbGIST_matrix", "Gender_ID", "RISK_ID", "Age_ID", "Stage_ID", 
                   "Location_ID", "Mutation_ID", "mRNA_ID", "IM_ID")
vars_exist <- sapply(required_vars, exists)

if(!all(vars_exist)) {
  missing_vars <- required_vars[!vars_exist]
  warning(paste("Missing required variables:", paste(missing_vars, collapse = ", "), 
                "\nModule configurations will be initialized later."))
  
  # 创建一个占位符配置，稍后会被实际配置替换
  module_configs <- list()
  
  # 创建一个初始化函数，稍后调用
  initialize_module_configs <- function() {
    # 再次检查变量是否存在
    vars_exist_check <- sapply(required_vars, exists, envir = .GlobalEnv)
    if(!all(vars_exist_check)) {
      stop("Required variables still missing after initialization attempt")
    }
    
    # 返回实际的配置
    list(
  # Module 1 子模块配置
  module1_tvn = createModuleConfig(
    title = module_metadata$module1_tvn$title,
    icon = module_metadata$module1_tvn$icon,
    description = module_metadata$module1_tvn$description,
    analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]), # 临时使用已有函数
    data_function = function(gene) generate_gender_summary_data(gene),
    has_second_gene = FALSE,
    type = "gender"
  ),
  
  module1_risk = createModuleConfig(
    title = module_metadata$module1_risk$title,
    icon = module_metadata$module1_risk$icon, 
    description = module_metadata$module1_risk$description,
    analysis_function = function(ID) dbGIST_boxplot_Risk(ID = ID, DB = dbGIST_matrix[RISK_ID]),
    data_function = function(gene) generate_risk_summary_data(gene),
    has_second_gene = FALSE
  ),
  
  module1_gender = createModuleConfig(
    title = module_metadata$module1_gender$title,
    icon = module_metadata$module1_gender$icon,
    description = module_metadata$module1_gender$description, 
    analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]),
    data_function = function(gene) generate_gender_summary_data(gene),
    has_second_gene = FALSE
  ),
  
  module1_age = createModuleConfig(
    title = module_metadata$module1_age$title,
    icon = module_metadata$module1_age$icon,
    description = module_metadata$module1_age$description,
    analysis_function = function(ID) dbGIST_boxplot_Age(ID = ID, DB = dbGIST_matrix[Age_ID]),
    data_function = function(gene) generate_age_summary_data(gene),
    has_second_gene = FALSE
  ),
  
  module1_tumor_size = createModuleConfig(
    title = module_metadata$module1_tumor_size$title,
    icon = module_metadata$module1_tumor_size$icon,
    description = module_metadata$module1_tumor_size$description,
    analysis_function = function(ID) dbGIST_boxplot_Tumor_size(ID = ID, DB = dbGIST_matrix[Stage_ID]),
    data_function = function(gene) generate_tumor_size_summary_data(gene),
    has_second_gene = FALSE
  ),
  
  module1_mitotic = createModuleConfig(
    title = module_metadata$module1_mitotic$title,
    icon = module_metadata$module1_mitotic$icon,
    description = module_metadata$module1_mitotic$description,
    analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]), # 占位符
    data_function = function(gene) generate_mitotic_summary_data(gene),
    has_second_gene = FALSE
  ),
  
  module1_location = createModuleConfig(
    title = module_metadata$module1_location$title,
    icon = module_metadata$module1_location$icon,
    description = module_metadata$module1_location$description,
    analysis_function = function(ID) dbGIST_boxplot_Site(ID = ID, DB = dbGIST_matrix[Location_ID]),
    data_function = function(gene) generate_location_summary_data(gene),
    has_second_gene = FALSE
  ),
  
  module1_who = createModuleConfig(
    title = module_metadata$module1_who$title,
    icon = module_metadata$module1_who$icon,
    description = module_metadata$module1_who$description,
    analysis_function = function(ID) dbGIST_boxplot_Grade(ID = ID, DB = dbGIST_matrix[Stage_ID]),
    data_function = function(gene) generate_who_summary_data(gene),
    has_second_gene = FALSE
  ),
  
  module1_ki67 = createModuleConfig(
    title = module_metadata$module1_ki67$title,
    icon = module_metadata$module1_ki67$icon,
    description = module_metadata$module1_ki67$description,
    analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]), # 占位符
    data_function = function(gene) generate_ki67_summary_data(gene),
    has_second_gene = FALSE
  ),
  
  module1_cd34 = createModuleConfig(
    title = module_metadata$module1_cd34$title,
    icon = module_metadata$module1_cd34$icon,
    description = module_metadata$module1_cd34$description,
    analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]), # 占位符
    data_function = function(gene) generate_cd34_summary_data(gene),
    has_second_gene = FALSE
  ),
  
  module1_mutation = createModuleConfig(
    title = module_metadata$module1_mutation$title,
    icon = module_metadata$module1_mutation$icon,
    description = module_metadata$module1_mutation$description,
    analysis_function = function(ID) dbGIST_boxplot_Mutation_ID(ID = ID, DB = dbGIST_matrix[Mutation_ID]),
    data_function = function(gene) generate_mutation_summary_data(gene),
    has_second_gene = FALSE
  ),
  
  # Module 2: 单基因表达分析
  module2 = createModuleConfig(
    title = module_metadata$module2$title,
    icon = module_metadata$module2$icon,
    description = module_metadata$module2$description,
    analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]),
    data_function = function(gene) generate_gender_summary_data(gene),
    has_second_gene = FALSE
  ),
  
  # Module 3: 基因相关性分析
  module3 = createModuleConfig(
    title = module_metadata$module3$title,
    icon = module_metadata$module3$icon,
    description = module_metadata$module3$description,
    analysis_function = function(ID, ID2) dbGIST_cor_ID(ID = ID, ID2 = ID2, DB = dbGIST_matrix[mRNA_ID]),
    data_function = function(gene1, gene2) generate_correlation_summary_data(gene1, gene2),
    has_second_gene = TRUE
  ),
  
  # Module 4: 药物耐药分析
  module4 = createModuleConfig(
    title = module_metadata$module4$title,
    icon = module_metadata$module4$icon,
    description = module_metadata$module4$description,
    analysis_function = function(ID) dbGIST_boxplot_Drug(ID = ID, DB = dbGIST_matrix[IM_ID]),
    data_function = function(gene) generate_drug_summary_data(gene),
    has_second_gene = FALSE
  )
)
  }
  
  # 导出初始化函数到全局环境
  assign("initialize_module_configs", initialize_module_configs, envir = .GlobalEnv)
  
} else {
  # 如果所有变量都存在，直接创建配置
  module_configs <- list(
    # Module 1 子模块配置
    module1_tvn = createModuleConfig(
      title = module_metadata$module1_tvn$title,
      icon = module_metadata$module1_tvn$icon,
      description = module_metadata$module1_tvn$description,
      analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]), # 临时使用已有函数
      data_function = function(gene) generate_gender_summary_data(gene),
      has_second_gene = FALSE,
      type = "gender"
    ),
    
    module1_risk = createModuleConfig(
      title = module_metadata$module1_risk$title,
      icon = module_metadata$module1_risk$icon, 
      description = module_metadata$module1_risk$description,
      analysis_function = function(ID) dbGIST_boxplot_Risk(ID = ID, DB = dbGIST_matrix[RISK_ID]),
      data_function = function(gene) generate_risk_summary_data(gene),
      has_second_gene = FALSE
    ),
    
    module1_gender = createModuleConfig(
      title = module_metadata$module1_gender$title,
      icon = module_metadata$module1_gender$icon,
      description = module_metadata$module1_gender$description, 
      analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]),
      data_function = function(gene) generate_gender_summary_data(gene),
      has_second_gene = FALSE
    ),
    
    module1_age = createModuleConfig(
      title = module_metadata$module1_age$title,
      icon = module_metadata$module1_age$icon,
      description = module_metadata$module1_age$description,
      analysis_function = function(ID) dbGIST_boxplot_Age(ID = ID, DB = dbGIST_matrix[Age_ID]),
      data_function = function(gene) generate_age_summary_data(gene),
      has_second_gene = FALSE
    ),
    
    module1_tumor_size = createModuleConfig(
      title = module_metadata$module1_tumor_size$title,
      icon = module_metadata$module1_tumor_size$icon,
      description = module_metadata$module1_tumor_size$description,
      analysis_function = function(ID) dbGIST_boxplot_Tumor_size(ID = ID, DB = dbGIST_matrix[Stage_ID]),
      data_function = function(gene) generate_tumor_size_summary_data(gene),
      has_second_gene = FALSE
    ),
    
    module1_mitotic = createModuleConfig(
      title = module_metadata$module1_mitotic$title,
      icon = module_metadata$module1_mitotic$icon,
      description = module_metadata$module1_mitotic$description,
      analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]), # 占位符
      data_function = function(gene) generate_mitotic_summary_data(gene),
      has_second_gene = FALSE
    ),
    
    module1_location = createModuleConfig(
      title = module_metadata$module1_location$title,
      icon = module_metadata$module1_location$icon,
      description = module_metadata$module1_location$description,
      analysis_function = function(ID) dbGIST_boxplot_Site(ID = ID, DB = dbGIST_matrix[Location_ID]),
      data_function = function(gene) generate_location_summary_data(gene),
      has_second_gene = FALSE
    ),
    
    module1_who = createModuleConfig(
      title = module_metadata$module1_who$title,
      icon = module_metadata$module1_who$icon,
      description = module_metadata$module1_who$description,
      analysis_function = function(ID) dbGIST_boxplot_Grade(ID = ID, DB = dbGIST_matrix[Stage_ID]),
      data_function = function(gene) generate_who_summary_data(gene),
      has_second_gene = FALSE
    ),
    
    module1_ki67 = createModuleConfig(
      title = module_metadata$module1_ki67$title,
      icon = module_metadata$module1_ki67$icon,
      description = module_metadata$module1_ki67$description,
      analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]), # 占位符
      data_function = function(gene) generate_ki67_summary_data(gene),
      has_second_gene = FALSE
    ),
    
    module1_cd34 = createModuleConfig(
      title = module_metadata$module1_cd34$title,
      icon = module_metadata$module1_cd34$icon,
      description = module_metadata$module1_cd34$description,
      analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]), # 占位符
      data_function = function(gene) generate_cd34_summary_data(gene),
      has_second_gene = FALSE
    ),
    
    module1_mutation = createModuleConfig(
      title = module_metadata$module1_mutation$title,
      icon = module_metadata$module1_mutation$icon,
      description = module_metadata$module1_mutation$description,
      analysis_function = function(ID) dbGIST_boxplot_Mutation_ID(ID = ID, DB = dbGIST_matrix[Mutation_ID]),
      data_function = function(gene) generate_mutation_summary_data(gene),
      has_second_gene = FALSE
    ),
    
    # Module 2: 单基因分析
    module2 = createModuleConfig(
      title = module_metadata$module2$title,
      icon = module_metadata$module2$icon,
      description = module_metadata$module2$description,
      analysis_function = function(ID) dbGIST_boxplot_Gender(ID = ID, DB = dbGIST_matrix[Gender_ID]),
      data_function = function(gene) generate_gender_summary_data(gene),
      has_second_gene = FALSE
    ),
    
    # Module 3: 基因相关性分析
    module3 = createModuleConfig(
      title = module_metadata$module3$title,
      icon = module_metadata$module3$icon,
      description = module_metadata$module3$description,
      analysis_function = function(ID, ID2) dbGIST_cor_ID(ID = ID, ID2 = ID2, DB = dbGIST_matrix[mRNA_ID]),
      data_function = function(gene1, gene2) generate_correlation_summary_data(gene1, gene2),
      has_second_gene = TRUE
    ),
    
    # Module 4: 药物耐药分析
    module4 = createModuleConfig(
      title = module_metadata$module4$title,
      icon = module_metadata$module4$icon,
      description = module_metadata$module4$description,
      analysis_function = function(ID) dbGIST_boxplot_Drug(ID = ID, DB = dbGIST_matrix[IM_ID]),
      data_function = function(gene) generate_drug_summary_data(gene),
      has_second_gene = FALSE
    )
  )
}

# ==== 获取配置的辅助函数 ====
get_module_metadata <- function(module_id) {
  if (module_id %in% names(module_metadata)) {
    metadata <- module_metadata[[module_id]]
    
    # 确保必要的字段存在
    if(is.null(metadata$title) || metadata$title == "" || length(metadata$title) == 0) {
      metadata$title <- paste("Module", module_id)
    }
    if(is.null(metadata$icon) || metadata$icon == "" || length(metadata$icon) == 0) {
      metadata$icon <- "question"
    }
    if(is.null(metadata$description) || metadata$description == "" || length(metadata$description) == 0) {
      metadata$description <- "Module not configured"
    }
    
    return(metadata)
  } else {
    return(list(title = "Unknown Module", icon = "question", description = "Module not found"))
  }
}

get_module_config <- function(module_id) {
  # 如果module_configs还未初始化，尝试初始化
  if (!exists("module_configs") || length(module_configs) == 0) {
    if (exists("initialize_module_configs")) {
      module_configs <<- initialize_module_configs()
    } else {
      warning("Module configurations not initialized")
      return(NULL)
    }
  }
  
  if (module_id %in% names(module_configs)) {
    return(module_configs[[module_id]])
  } else {
    return(NULL)
  }
}

get_available_modules <- function() {
  # 返回所有可用模块的ID
  # 如果module_configs还未初始化，尝试初始化
  if (!exists("module_configs") || length(module_configs) == 0) {
    if (exists("initialize_module_configs")) {
      module_configs <<- initialize_module_configs()
    } else {
      warning("Module configurations not initialized")
      return(character(0))
    }
  }
  return(names(module_configs))
}

get_module1_submodules <- function() {
  # 返回Module 1的所有子模块
  # 如果module_configs还未初始化，尝试初始化
  if (!exists("module_configs") || length(module_configs) == 0) {
    if (exists("initialize_module_configs")) {
      module_configs <<- initialize_module_configs()
    } else {
      warning("Module configurations not initialized")
      return(character(0))
    }
  }
  module1_submodules <- names(module_configs)[grepl("^module1_", names(module_configs))]
  return(module1_submodules)
}

is_placeholder_module <- function(module_id) {
  metadata <- get_module_metadata(module_id)
  return(isTRUE(metadata$placeholder))
}

# ==== 数据提取函数（占位符实现） ====
# 这些函数为每个模块提供数据提取功能

generate_gender_summary_data <- function(gene) {
  # 检查必要的变量是否存在
  if (!exists("dbGIST_matrix") || !exists("Gender_ID")) {
    warning("Required data not loaded yet")
    return(data.frame(
      Sample_ID = character(0),
      Gene_Expression = numeric(0),
      Gender = character(0),
      Dataset = character(0),
      stringsAsFactors = FALSE
    ))
  }
  
  # 为性别分析生成汇总数据
  result_data <- data.frame()
  
  for(i in 1:length(dbGIST_matrix[Gender_ID])) {
    if(gene %in% rownames(dbGIST_matrix[Gender_ID][[i]]$Matrix)) {
      gene_expression <- as.numeric(dbGIST_matrix[Gender_ID][[i]]$Matrix[match(gene, rownames(dbGIST_matrix[Gender_ID][[i]]$Matrix)),])
      gender_info <- dbGIST_matrix[Gender_ID][[i]]$Clinical$Gender[match(colnames(dbGIST_matrix[Gender_ID][[i]]$Matrix), dbGIST_matrix[Gender_ID][[i]]$Clinical$geo_accession)]
      
      sample_data <- data.frame(
        Sample_ID = colnames(dbGIST_matrix[Gender_ID][[i]]$Matrix),
        Gene_Expression = gene_expression,
        Gender = gender_info,
        Dataset = paste0("Dataset_", i),
        stringsAsFactors = FALSE
      )
      
      result_data <- rbind(result_data, sample_data)
    }
  }
  
  return(result_data)
}

generate_risk_summary_data <- function(gene) {
  # 风险分析数据提取
  return(data.frame(
    Sample_ID = c("Sample1", "Sample2"),
    Gene_Expression = c(1.2, 2.3),
    Risk_Level = c("High", "Low"),
    stringsAsFactors = FALSE
  ))
}

generate_age_summary_data <- function(gene) {
  # 年龄分析数据提取
  return(data.frame(
    Sample_ID = c("Sample1", "Sample2"),
    Gene_Expression = c(1.2, 2.3),
    Age_Group = c("Young", "Old"),
    stringsAsFactors = FALSE
  ))
}

generate_tumor_size_summary_data <- function(gene) {
  # 肿瘤大小分析数据提取
  return(data.frame(
    Sample_ID = c("Sample1", "Sample2"),
    Gene_Expression = c(1.2, 2.3),
    Tumor_Size = c(5.0, 8.5),
    stringsAsFactors = FALSE
  ))
}

generate_mitotic_summary_data <- function(gene) {
  # 有丝分裂计数分析数据提取
  return(data.frame(
    Sample_ID = c("Sample1", "Sample2"),
    Gene_Expression = c(1.2, 2.3),
    Mitotic_Count = c("Low", "High"),
    stringsAsFactors = FALSE
  ))
}

generate_location_summary_data <- function(gene) {
  # 位置分析数据提取  
  return(data.frame(
    Sample_ID = c("Sample1", "Sample2"),
    Gene_Expression = c(1.2, 2.3),
    Location = c("Stomach", "Small intestine"),
    stringsAsFactors = FALSE
  ))
}

generate_who_summary_data <- function(gene) {
  # WHO分级分析数据提取
  return(data.frame(
    Sample_ID = c("Sample1", "Sample2"),
    Gene_Expression = c(1.2, 2.3),
    WHO_Grade = c("Grade I", "Grade II"),
    stringsAsFactors = FALSE
  ))
}

generate_ki67_summary_data <- function(gene) {
  # Ki67分析数据提取
  return(data.frame(
    Sample_ID = c("Sample1", "Sample2"),
    Gene_Expression = c(1.2, 2.3),
    Ki67_Status = c("Positive", "Negative"),
    stringsAsFactors = FALSE
  ))
}

generate_cd34_summary_data <- function(gene) {
  # CD34分析数据提取
  return(data.frame(
    Sample_ID = c("Sample1", "Sample2"),
    Gene_Expression = c(1.2, 2.3),
    CD34_Status = c("Positive", "Negative"),
    stringsAsFactors = FALSE
  ))
}

generate_mutation_summary_data <- function(gene) {
  # 突变分析数据提取
  return(data.frame(
    Sample_ID = c("Sample1", "Sample2"),
    Gene_Expression = c(1.2, 2.3),
    Mutation_Type = c("KIT", "PDGFRA"),
    stringsAsFactors = FALSE
  ))
}

generate_correlation_summary_data <- function(gene1, gene2) {
  # 相关性分析数据提取
  return(data.frame(
    Sample_ID = c("Sample1", "Sample2"),
    Gene1_Expression = c(1.2, 2.3),
    Gene2_Expression = c(2.1, 1.8),
    Correlation = c(0.75, 0.75),
    stringsAsFactors = FALSE
  ))
}

generate_drug_summary_data <- function(gene) {
  # 检查必要的变量是否存在
  if (!exists("dbGIST_matrix") || !exists("IM_ID")) {
    warning("Required data not loaded yet")
    return(data.frame(
      Sample_ID = character(0),
      Gene_Expression = numeric(0),
      Drug_Response = character(0),
      Dataset = character(0),
      stringsAsFactors = FALSE
    ))
  }
  
  # 药物耐药分析数据提取
  result_data <- data.frame()
  
  for(i in 1:length(dbGIST_matrix[IM_ID])) {
    if(gene %in% rownames(dbGIST_matrix[IM_ID][[i]]$Matrix)) {
      gene_expression <- as.numeric(dbGIST_matrix[IM_ID][[i]]$Matrix[match(gene, rownames(dbGIST_matrix[IM_ID][[i]]$Matrix)),])
      drug_response <- dbGIST_matrix[IM_ID][[i]]$Clinical$Imatinib[match(colnames(dbGIST_matrix[IM_ID][[i]]$Matrix), dbGIST_matrix[IM_ID][[i]]$Clinical$geo_accession)]
      
      sample_data <- data.frame(
        Sample_ID = colnames(dbGIST_matrix[IM_ID][[i]]$Matrix),
        Gene_Expression = gene_expression,
        Drug_Response = drug_response,
        Dataset = paste0("Dataset_", i),
        stringsAsFactors = FALSE
      )
      
      # 移除缺失值
      sample_data <- sample_data[!is.na(sample_data$Drug_Response) & sample_data$Drug_Response != "NA",]
      
      result_data <- rbind(result_data, sample_data)
    }
  }
  
  return(result_data)
} 