# API配置说明

## 概述

本应用需要AI API来提供智能分析功能。为了保护API密钥安全，请按照以下步骤进行配置。

## 配置步骤

### 1. 复制环境变量文件
```bash
cp .env.example .env
```

### 2. 编辑 .env 文件
打开 `.env` 文件并填入你的真实API密钥：

```bash
# OpenRouter配置（推荐，更稳定）
USE_OPENROUTER=true
OPENROUTER_API_KEY=你的OpenRouter密钥
OPENROUTER_API_URL=https://openrouter.ai/api/v1/chat/completions
OPENROUTER_MODEL=google/gemini-2.5-flash

# 豆包AI配置（备选）
USE_OPENROUTER=false
DOUBAO_API_KEY=你的豆包API密钥
DOUBAO_API_URL=https://ark.cn-beijing.volces.com/api/v3/chat/completions
DOUBAO_MODEL=doubao-1-5-thinking-vision-pro-250428

# 通用设置
ENABLE_AI_ANALYSIS=true
```

### 3. 获取API密钥

#### OpenRouter (推荐)
1. 访问 https://openrouter.ai/
2. 注册账号并获取API密钥
3. 填入 `OPENROUTER_API_KEY`

#### 豆包AI (备选)
1. 访问豆包AI开发者平台
2. 创建应用并获取API密钥
3. 填入 `DOUBAO_API_KEY`

## 安全注意事项

⚠️ **重要提醒**：
- **绝不要**将 `.env` 文件提交到Git仓库
- **绝不要**在代码中硬编码API密钥
- **绝不要**在公开渠道分享API密钥
- 定期轮换API密钥

## 测试配置

配置完成后，启动应用：
```bash
Rscript run_app.R
```

如果配置正确，AI聊天功能应该可以正常工作。

## 故障排除

1. **AI分析不工作**：
   - 检查 `.env` 文件是否存在
   - 确认API密钥正确无误
   - 检查网络连接

2. **API调用失败**：
   - 验证API密钥有效性
   - 检查API配额是否用完
   - 尝试切换到备用API服务

3. **环境变量未加载**：
   - 确保 `.env` 文件在项目根目录
   - 重启R会话
   - 检查文件权限