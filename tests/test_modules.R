# ==== 模块化测试框架 ====

library(testthat)
library(shiny)

# 设置测试环境
setup_test_environment <- function() {
  # 加载必要的文件
  source("global.R")
  source("modules/data_utils.R")
  source("config/module_configs.R")
}

# 测试数据生成器
test_that("DataGenerator class works correctly", {
  setup_test_environment()
  
  # 测试初始化
  expect_no_error({
    dg <- DataGenerator$new()
  })
  
  # 测试基因验证
  expect_error({
    dg$validate_gene("INVALID_GENE")
  })
  
  # 测试有效基因
  expect_no_error({
    dg$validate_gene("TP53")  # 假设TP53存在于数据中
  })
})

# 测试模块配置
test_that("Module configurations are valid", {
  setup_test_environment()
  
  # 测试所有模块都有有效配置
  for(module_id in c("module2", "module3", "module4", "module5")) {
    config <- get_module_config(module_id)
    
    expect_true(!is.null(config$type))
    expect_true(!is.null(config$analysis_function))
    expect_true(!is.null(config$data_function))
    expect_true(!is.null(config$table_caption))
    expect_true(!is.null(config$input_config))
    
    # 测试元数据
    metadata <- get_module_metadata(module_id)
    expect_true(!is.null(metadata$title))
    expect_true(!is.null(metadata$description))
    expect_true(!is.null(metadata$icon))
  }
})

# 测试数据生成功能
test_that("Data generation functions work correctly", {
  setup_test_environment()
  
  test_gene <- "TP53"  # 使用一个应该存在的基因
  
  # 跳过测试如果基因不存在
  skip_if_not(test_gene %in% gene2sym$SYMBOL, "Test gene not found in dataset")
  
  # 测试性别分析数据生成
  expect_no_error({
    gender_data <- generate_module_data("gender", test_gene)
    expect_true(is.data.frame(gender_data))
    expect_true("Gene_Expression" %in% names(gender_data))
    expect_true("Gender" %in% names(gender_data))
  })
  
  # 测试药物响应数据生成
  expect_no_error({
    drug_data <- generate_module_data("drug", test_gene)
    expect_true(is.data.frame(drug_data))
    expect_true("Gene_Expression" %in% names(drug_data))
    expect_true("Drug_Response" %in% names(drug_data))
  })
})

# 模块集成测试
test_that("Module integration works correctly", {
  setup_test_environment()
  
  # 创建测试应用
  test_app <- function() {
    ui <- fluidPage(
      analysisModuleUI("test_module", "Test Module", 
                      list(gene1_label = "Gene", gene1_placeholder = "TP53"))
    )
    
    server <- function(input, output, session) {
      config <- get_module_config("module2")
      analysisModuleServer("test_module", config)
    }
    
    shinyApp(ui, server)
  }
  
  # 测试应用创建不出错
  expect_no_error({
    app <- test_app()
  })
})

# 性能测试
test_that("Performance is acceptable", {
  setup_test_environment()
  
  test_gene <- "TP53"
  skip_if_not(test_gene %in% gene2sym$SYMBOL, "Test gene not found in dataset")
  
  # 测试数据生成性能
  timing <- system.time({
    data <- generate_module_data("gender", test_gene)
  })
  
  # 期望在合理时间内完成（例如5秒）
  expect_lt(timing[["elapsed"]], 5)
})

# 运行所有测试的函数
run_all_tests <- function() {
  cat("Starting comprehensive module tests...\n")
  
  test_results <- test_dir("tests/", reporter = "summary")
  
  if(any(test_results$failed > 0)) {
    cat("Some tests failed. Please check the results above.\n")
    return(FALSE)
  } else {
    cat("All tests passed successfully!\n")
    return(TRUE)
  }
}

# 如果直接运行此文件，执行所有测试
if(length(sys.calls()) == 0) {
  run_all_tests()
} 