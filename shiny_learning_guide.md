# R Shiny 学习指南 - 基于 dbGIST 项目

## 📚 Shiny 基础概念

### 1. **Shiny 应用的三大核心文件**

#### 🟢 global.R
- **作用**：定义全局变量、加载数据、导入包
- **执行时机**：应用启动时执行一次
- **在你的项目中**：
  ```r
  # 加载必要的包
  library(shiny)
  library(bs4Dash)
  library(ggplot2)
  
  # 加载数据
  load("./original/dbGIST_matrix(2).Rdata")
  
  # 定义全局函数
  dbGIST_boxplot_Risk <- function(...) { ... }
  ```

#### 🟠 ui.R
- **作用**：定义用户界面
- **包含内容**：布局、输入控件、输出占位符
- **基本结构**：
  ```r
  ui <- bs4DashPage(
    header = bs4DashNavbar(...),
    sidebar = bs4DashSidebar(...),
    body = bs4DashBody(...)
  )
  ```

#### 🟣 server.R
- **作用**：处理服务器端逻辑
- **响应式编程**：监听输入变化，更新输出
- **基本结构**：
  ```r
  server <- function(input, output, session) {
    # 响应式表达式
    output$plot <- renderPlot({
      # 根据 input 生成图表
    })
  }
  ```

### 2. **响应式编程核心概念**

```
用户输入 (input$xxx) → 响应式表达式 → 输出结果 (output$xxx)
```

#### 常用响应式函数：
- `reactive()`: 创建响应式表达式
- `observe()`: 观察输入变化并执行操作
- `eventReactive()`: 基于特定事件触发
- `observeEvent()`: 观察特定事件

### 3. **你的 dbGIST 项目功能模块**

1. **基因符号验证** (`Judge_GENESYMBOL`)
   - 验证输入的基因名称是否有效
   - 使用 EnsDb.Hsapiens.v75 数据库

2. **单基因表达分析**
   - `dbGIST_boxplot_Risk`: 按风险分组
   - `dbGIST_boxplot_Gender`: 按性别分组
   - `dbGIST_boxplot_Stage`: 按分期分组

3. **基因相关性分析** (`dbGIST_cor_ID`)
   - 分析两个基因的表达相关性
   - 生成散点图和相关系数

4. **耐药基因分析** (`dbGIST_boxplot_Drug`)
   - 比较耐药/敏感组的基因表达
   - 生成 ROC 曲线

5. **治疗前后分析** (`dbGIST_boxplot_PrePost`)
   - 配对样本分析
   - 治疗前后基因表达变化

## 🎯 新手学习建议

### 第一步：理解数据流
```
global.R (数据准备) → ui.R (界面设计) → server.R (交互逻辑)
```

### 第二步：从简单开始
1. 先创建一个简单的输入-输出示例
2. 逐步添加复杂功能
3. 测试每个功能模块

### 第三步：常用 UI 组件
- **输入**：
  - `textInput()`: 文本输入
  - `selectInput()`: 下拉选择
  - `sliderInput()`: 滑块
  - `actionButton()`: 按钮

- **输出**：
  - `plotOutput()`: 图表输出
  - `tableOutput()`: 表格输出
  - `textOutput()`: 文本输出

### 第四步：调试技巧
1. 使用 `browser()` 设置断点
2. 使用 `print()` 或 `cat()` 打印调试信息
3. 查看浏览器控制台错误信息

## 💡 实践建议

1. **从修改现有代码开始**
   - 尝试修改图表颜色、标题
   - 添加新的统计信息
   - 调整界面布局

2. **理解响应式编程**
   - 观察 input 如何触发 output 更新
   - 学习使用 reactive() 缓存计算结果

3. **优化用户体验**
   - 添加加载动画 (waiter 包)
   - 提供输入验证反馈 (shinyFeedback)
   - 使用主题美化界面 (bs4Dash)

## 📖 推荐学习资源

1. [Shiny 官方教程](https://shiny.rstudio.com/tutorial/)
2. [Mastering Shiny](https://mastering-shiny.org/)
3. [Shiny Gallery](https://shiny.rstudio.com/gallery/)

记住：Shiny 的核心是响应式编程，理解了 input → reactive → output 的流程，就掌握了 Shiny 的精髓！