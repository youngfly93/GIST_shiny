# GIST Shiny 双域名架构实现文档

## 🎯 项目概述

成功实现了GIST Shiny应用的双域名架构，提供两个独立的应用实例：
- **AI版本** (端口4964)：包含完整的AI分析功能
- **基础版本** (端口4965)：纯分析功能，不包含AI组件

## 🏗️ 架构设计

### 核心原理
通过环境变量控制AI功能的启用/禁用，实现同一代码库支持两种不同的部署模式。

### 关键组件

#### 1. 环境变量控制
- `ENABLE_AI_ANALYSIS`: 控制AI功能总开关
- `USE_OPENROUTER`: 控制OpenRouter API使用

#### 2. 启动脚本
- `start_no_ai.R`: 启动非AI版本的专用脚本
- 标准启动: 使用默认配置启动AI版本

#### 3. 条件加载机制
```r
# 检查AI功能是否启用
enable_ai <- tolower(Sys.getenv("ENABLE_AI_ANALYSIS", "true")) == "true"

# 条件加载AI模块
if(enable_ai) {
  source("modules/ai_chat_module.R")
}
```

## 🚀 部署方式

### AI版本 (端口4964)
```bash
# 使用默认环境变量
Rscript -e "shiny::runApp(port = 4964, host = '127.0.0.1', launch.browser = FALSE)"
```

### 基础版本 (端口4966)
```bash
# 使用专用启动脚本
Rscript start_no_ai.R
```

## 🔧 技术实现细节

### 1. 环境变量设置
```r
# start_no_ai.R 中的设置
Sys.setenv(ENABLE_AI_ANALYSIS = "false")
Sys.setenv(USE_OPENROUTER = "false")
```

### 2. UI条件渲染
```r
# ui.R 中的条件组件
if(enable_ai) list(
  aiChatFloatingButtonUI("ai_chat"),
  aiChatUI("ai_chat")
)
```

### 3. 版本指示器
```r
# 页面右上角的版本标识
div(
  style = "position: fixed; top: 10px; right: 10px; z-index: 9999; ...",
  if(enable_ai) "AI版本 (4964)" else "基础版本 (4966)"
)
```

### 4. 安全的状态管理
```r
# 安全访问全局状态，避免非AI版本出错
if (!is.null(global_state) && 
    !is.null(global_state$ai_analyzing) && 
    global_state$ai_analyzing) {
  # AI相关逻辑
}
```

## 🎨 用户体验差异

### AI版本特性
- ✅ 绿色版本标签 "AI版本 (4964)"
- ✅ 浮动AI聊天按钮
- ✅ 自动AI分析功能
- ✅ AI分析历史记录
- ✅ 智能图表解读

### 基础版本特性
- ✅ 灰色版本标签 "基础版本 (4966)"
- ✅ 纯分析功能
- ✅ 数据可视化
- ✅ 结果下载
- ❌ 无AI相关组件

## 📊 日志差异对比

### AI版本启动日志
```
Loaded env var: ENABLE_AI_ANALYSIS = true ...
AI Chat Module initialized:
- Service: openrouter
- AI Analysis Enabled: TRUE
```

### 基础版本启动日志
```
Env var already set: ENABLE_AI_ANALYSIS = false ...
(无AI模块初始化信息)
```

## 🔍 访问地址

- **AI版本**: http://127.0.0.1:4964
- **基础版本**: http://127.0.0.1:4966

## ✅ 验证清单

- [x] 两个应用可同时运行
- [x] 端口隔离 (4964 vs 4966)
- [x] AI功能完全隔离
- [x] 环境变量正确控制
- [x] 视觉区分明显
- [x] 错误处理完善
- [x] 日志输出清晰
- [x] 基础版本隐藏"AI自动分析已启用"提示

## 🛠️ 故障排除

### 常见问题

1. **"argument is of length zero" 错误**
   - 原因：eventReactive在未触发时返回空向量
   - 解决：添加长度检查和错误处理

2. **全局状态访问错误**
   - 原因：非AI版本缺少AI相关状态属性
   - 解决：添加null检查

3. **模块加载失败**
   - 原因：条件加载逻辑错误
   - 解决：确保环境变量在模块加载前设置

## 📝 维护说明

### 添加新功能时注意事项
1. 检查是否需要AI功能支持
2. 添加适当的条件判断
3. 确保两个版本都能正常工作
4. 更新相关文档

### 部署建议
1. 使用不同的域名或子域名
2. 配置负载均衡
3. 监控两个版本的运行状态
4. 定期备份配置文件

## 🎉 项目成果

成功实现了用户需求的双域名架构：
- 一个域名提供完整的AI功能
- 另一个域名提供纯分析功能
- 用户可根据需要选择合适的版本
- 代码库统一，维护成本低

---

**文档版本**: 1.0  
**最后更新**: 2025-06-24  
**维护者**: Augment Agent
