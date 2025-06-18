# ==== 模块配置管理 ====

# 模块配置工厂
create_module_config <- function(type) {
  
  base_config <- list(
    type = type,
    has_second_gene = FALSE,
    analysis_function = NULL,
    data_function = NULL,
    table_caption = NULL,
    input_config = list()
  )
  
  switch(type,
    "gender" = {
      base_config$analysis_function <- dbGIST_boxplot_Gender
      base_config$data_function <- function(gene1, gene2) {
        generate_module_data("gender", gene1)
      }
      base_config$table_caption <- function(gene1, gene2) {
        paste("Gene Expression Data:", gene1, "by Gender")
      }
      base_config$input_config <- list(
        gene1_label = "Gene Symbol",
        gene1_placeholder = "e.g., TP53, MCM7"
      )
    },
    
    "correlation" = {
      base_config$has_second_gene <- TRUE
      base_config$analysis_function <- dbGIST_cor_ID
      base_config$data_function <- function(gene1, gene2) {
        generate_module_data("correlation", gene1, gene2)
      }
      base_config$table_caption <- function(gene1, gene2) {
        paste("Gene Correlation Data:", gene1, "vs", gene2)
      }
      base_config$input_config <- list(
        gene1_label = "First Gene Symbol",
        gene1_placeholder = "e.g., MCM7",
        gene2_label = "Second Gene Symbol",
        gene2_placeholder = "e.g., MKI67"
      )
    },
    
    "drug" = {
      base_config$analysis_function <- dbGIST_boxplot_Drug
      base_config$data_function <- function(gene1, gene2) {
        generate_module_data("drug", gene1)
      }
      base_config$table_caption <- function(gene1, gene2) {
        paste("Drug Response Data:", gene1, "vs Imatinib")
      }
      base_config$input_config <- list(
        gene1_label = "Gene Symbol",
        gene1_placeholder = "e.g., KIT, PDGFRA"
      )
    },
    
    "prepost" = {
      base_config$analysis_function <- dbGIST_boxplot_PrePost
      base_config$data_function <- function(gene1, gene2) {
        generate_module_data("prepost", gene1)
      }
      base_config$table_caption <- function(gene1, gene2) {
        paste("Pre/Post Treatment Data:", gene1, "Expression Changes")
      }
      base_config$input_config <- list(
        gene1_label = "Gene Symbol",
        gene1_placeholder = "e.g., KIT, CD117"
      )
    },
    
    stop("Unknown module type:", type)
  )
  
  return(base_config)
}

# 预定义的模块配置
MODULE_CONFIGS <- list(
  module2 = create_module_config("gender"),
  module3 = create_module_config("correlation"),
  module4 = create_module_config("drug"),
  module5 = create_module_config("prepost")
)

# 模块元数据
MODULE_METADATA <- list(
  module2 = list(
    title = "Single gene expression investigation",
    description = "Analyze gene expression differences between male and female GIST patients",
    icon = "atom"
  ),
  module3 = list(
    title = "Expression correlation between genes",
    description = "Examine correlation relationships between two genes in GIST patients",
    icon = "chart-line"
  ),
  module4 = list(
    title = "Drug response analysis",
    description = "Investigate gene expression in relation to Imatinib drug response",
    icon = "pills"
  ),
  module5 = list(
    title = "Pre/Post treatment analysis",
    description = "Compare gene expression before and after treatment",
    icon = "clock"
  )
)

# 获取模块配置的便利函数
get_module_config <- function(module_id) {
  if(!module_id %in% names(MODULE_CONFIGS)) {
    stop("Unknown module ID:", module_id)
  }
  return(MODULE_CONFIGS[[module_id]])
}

# 获取模块元数据的便利函数
get_module_metadata <- function(module_id) {
  if(!module_id %in% names(MODULE_METADATA)) {
    stop("Unknown module ID:", module_id)
  }
  return(MODULE_METADATA[[module_id]])
}

# 获取所有可用模块
get_available_modules <- function() {
  return(names(MODULE_CONFIGS))
} 