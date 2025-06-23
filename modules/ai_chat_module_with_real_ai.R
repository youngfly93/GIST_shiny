# 这是启用真正AI分析的示例代码片段
# 在 observeEvent(input$analyze_plot) 中的修改：

# 执行分析
result <- tryCatch({
  cat("AI Chat: Starting analysis execution\n")
  
  # 检查文件是否存在
  if (!file.exists(plot_data$plotPath)) {
    cat("AI Chat: File does not exist:", plot_data$plotPath, "\n")
    return(generate_mock_analysis(plot_data))
  }
  
  cat("AI Chat: File exists, starting analysis\n")
  
  # 尝试使用真正的AI分析
  use_real_ai <- TRUE  # 可以通过配置控制
  
  if (use_real_ai) {
    # 将图片转换为base64
    image_base64 <- image_to_base64(plot_data$plotPath)
    
    if (!is.null(image_base64)) {
      # 构建分析提示
      analysis_prompt <- paste0(
        "请分析这张GIST（胃肠道间质瘤）研究的生物信息学图片。",
        "这是关于基因 ", plot_data$gene1,
        if(!is.null(plot_data$gene2)) paste0(" 和 ", plot_data$gene2) else "",
        " 的", plot_data$analysisType, "分析图。",
        "请从以下方面分析：1. 数据分布和统计显著性；2. 生物学意义；3. 临床相关性。请用中文回答。"
      )
      
      # 调用AI API
      ai_result <- analyze_image_with_ai(image_base64, analysis_prompt)
      
      # 检查结果
      if (!is.null(ai_result) && ai_result != "抱歉，AI分析服务暂时不可用，请稍后再试。") {
        return(ai_result)
      }
    }
  }
  
  # 如果AI分析失败，使用模拟分析
  cat("AI Chat: Falling back to mock analysis\n")
  return(generate_mock_analysis(plot_data))
  
}, error = function(e) {
  cat("AI Chat: Error during analysis:", e$message, "\n")
  # 返回简化的分析文本
  return(paste0(
    "## 📊 GIST基因表达分析报告\n\n",
    "**分析基因**: ", plot_data$gene1, "\n",
    "**分析类型**: ", plot_data$analysisType, "\n\n",
    "图表分析正在处理中，请查看生成的图表了解详细信息。"
  ))
})