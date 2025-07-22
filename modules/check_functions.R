# ==== 函数存在性检查 ====
# 用于检查分析函数是否实际存在

#' 检查函数是否存在
#' @param func_name 函数名称
#' @return 逻辑值
check_function_exists <- function(func_name) {
  exists(func_name, mode = "function", envir = .GlobalEnv) ||
  exists(func_name, mode = "function", envir = parent.env(.GlobalEnv))
}

#' 获取实际存在的分析函数列表
#' @return 字符向量
get_available_analysis_functions <- function() {
  # 列出所有可能的分析函数
  possible_functions <- c(
    "dbGIST_boxplot_Gender",
    "dbGIST_boxplot_Risk", 
    "dbGIST_boxplot_Age",
    "dbGIST_boxplot_Tumor_size",
    "dbGIST_boxplot_Site",
    "dbGIST_boxplot_Grade",
    "dbGIST_boxplot_Mutation_ID",
    "dbGIST_cor_ID",
    "dbGIST_boxplot_Drug",
    "dbGIST_boxplot_PrePost"
  )
  
  # 过滤出实际存在的函数
  available_functions <- possible_functions[sapply(possible_functions, check_function_exists)]
  
  return(available_functions)
}

#' 检查模块是否应该使用占位符
#' @param module_id 模块ID
#' @return 逻辑值
should_use_placeholder <- function(module_id) {
  # 首先检查模块配置中的is_placeholder字段
  config <- get_module_config(module_id)
  if (!is.null(config) && !is.null(config$is_placeholder)) {
    return(config$is_placeholder)
  }
  
  # 尝试使用自动检测，如果失败则使用手动列表
  if (exists("should_use_placeholder_auto", mode = "function")) {
    tryCatch({
      return(should_use_placeholder_auto(module_id))
    }, error = function(e) {
      cat("Auto-detection failed, using manual fallback\n")
    })
  }
  
  # 手动备用列表 - 只标记真正缺少功能的模块
  placeholder_modules <- c(
    # 这些模块明确缺少对应功能或数据
    "module1_mitotic",     # Mitotic Count - 没有对应的数据分析函数
    "module1_ki67",        # Ki-67 Expression - 没有对应的数据分析函数  
    "module1_cd34",        # CD34 Expression - 没有对应的数据分析函数
    "module1_age",         # Age Group - 函数实现错误，使用了Risk数据
    "module1_tumor_size",  # Tumor Size - 函数实现可能有问题
    "module1_who",         # WHO Grade - 函数实现可能有问题
    "module2",             # Single Gene Expression - 功能与Module 1重复，设为占位符
    "module3a_enrichment", # 富集分析 - 完全未实现
    "module3b_gsea"        # GSEA分析 - 完全未实现
  )
  
  return(module_id %in% placeholder_modules)
}

#' 打印可用函数报告
#' @return NULL
print_available_functions_report <- function() {
  cat("\n==== Analysis Functions Availability Report ====\n")
  
  available <- get_available_analysis_functions()
  cat("\nAvailable functions:\n")
  for (func in available) {
    cat("  ✓", func, "\n")
  }
  
  all_functions <- c(
    "dbGIST_boxplot_Gender",
    "dbGIST_boxplot_Risk", 
    "dbGIST_boxplot_Age",
    "dbGIST_boxplot_Tumor_size",
    "dbGIST_boxplot_Site",
    "dbGIST_boxplot_Grade",
    "dbGIST_boxplot_Mutation_ID",
    "dbGIST_cor_ID",
    "dbGIST_boxplot_Drug",
    "dbGIST_boxplot_PrePost"
  )
  
  missing <- setdiff(all_functions, available)
  if (length(missing) > 0) {
    cat("\nMissing functions (will use placeholders):\n")
    for (func in missing) {
      cat("  ✗", func, "\n")
    }
  }
  
  cat("\n===============================================\n")
}