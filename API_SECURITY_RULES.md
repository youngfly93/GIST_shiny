# API密钥安全管理规则

## 🔒 安全原则

### ❌ 绝对禁止
1. **永远不要**将API密钥提交到Git仓库
2. **永远不要**在代码中硬编码API密钥
3. **永远不要**在公开渠道分享API密钥
4. **永远不要**将API密钥发送到不安全的通道

### ✅ 安全实践
1. **始终使用**环境变量或.env文件存储密钥
2. **确保**.env文件在.gitignore中
3. **定期轮换**API密钥
4. **监控**API使用情况和账单

## 📁 文件保护配置

### .gitignore 规则
```gitignore
# API Keys and Sensitive Data
.env
*.env
*api_key*
*secret*

# AI Analysis Files (may contain sensitive data)
ai_analysis_history.md
ai_summary_report_*.md

# Test Files (may contain API keys)
test_*.R
debug_*.R
```

### 当前保护状态
- ✅ .env文件已在.gitignore中
- ✅ API密钥存储在环境变量中
- ✅ 测试文件被排除在版本控制之外
- ✅ AI分析历史文件受保护

## 🔑 密钥管理

### 当前配置
- **服务商**: OpenRouter (openrouter.ai)
- **密钥格式**: sk-or-v1-[64字符]
- **存储位置**: .env文件 (不在版本控制中)
- **更新日期**: 2025-01-22

### 密钥轮换流程
1. 登录 https://openrouter.ai
2. 生成新的API密钥
3. 更新.env文件中的OPENROUTER_API_KEY
4. 测试新密钥功能
5. 删除旧密钥（在确认新密钥工作后）
6. 记录更新日期

## 🚨 安全检查清单

### 提交前检查
- [ ] 确认.env文件不在暂存区
- [ ] 检查代码中没有硬编码的密钥
- [ ] 确认测试文件没有包含真实密钥
- [ ] 验证.gitignore规则有效

### 定期安全审计
- [ ] 每月检查API使用情况
- [ ] 每季度轮换API密钥
- [ ] 监控异常API调用
- [ ] 检查账户余额和使用限制

## 🔧 技术实施

### 环境变量加载
```r
# 在global.R中安全加载
if (file.exists(".env")) {
  env_vars <- readLines(".env")
  # 安全解析和设置环境变量
}
```

### 密钥验证
```r
# 验证密钥格式
api_key <- Sys.getenv("OPENROUTER_API_KEY", "")
if (!grepl("^sk-or-v1-", api_key)) {
  stop("Invalid API key format")
}
```

## 📞 应急响应

### 密钥泄露处理
1. **立即**在OpenRouter dashboard撤销泄露的密钥
2. **生成**新的API密钥
3. **更新**所有相关配置
4. **监控**账户活动
5. **记录**事件和处理过程

### 联系方式
- OpenRouter支持: https://openrouter.ai/docs
- 项目维护者: [内部联系方式]

## 📊 合规要求

### 数据保护
- API密钥属于敏感数据
- 遵循数据最小化原则
- 定期审计访问权限
- 保持安全日志

### 审计记录
- 密钥创建/更新时间
- 使用情况监控
- 安全事件记录
- 合规检查结果

---

**⚠️ 重要提醒**: 所有团队成员都必须遵循这些安全规则。任何违反都可能导致安全风险和项目损失。

**🔒 最后更新**: 2025-01-22
**📝 下次审计**: 2025-04-22