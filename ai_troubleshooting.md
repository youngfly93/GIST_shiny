# AI分析功能故障排除指南

## 问题症状
- 浏览器控制台出现 `ERR_PROXY_CONNECTION_FAILED` 错误
- AI分析没有执行，或显示连接失败信息

## 可能原因
1. **网络代理问题**: 你的网络环境可能使用了代理服务器，阻止了到豆包API的连接
2. **防火墙设置**: 公司或学校防火墙可能阻止了外部API调用
3. **API密钥问题**: 豆包API密钥可能已过期或无效
4. **服务地区限制**: 豆包API可能在某些地区不可用

## 解决方案

### 1. 临时禁用AI分析
如果你想先使用应用的其他功能，可以禁用AI分析：

```r
# 在R控制台中设置环境变量
Sys.setenv(ENABLE_AI_ANALYSIS = "false")

# 然后重启Shiny应用
shiny::runApp()
```

### 2. 检查网络连接
在R控制台中测试网络连接：

```r
# 测试是否能访问豆包API
library(httr)
test_url <- "https://ark.cn-beijing.volces.com"
response <- GET(test_url, timeout(10))
status_code(response)  # 应该返回200或其他HTTP状态码
```

### 3. 配置代理（如果需要）
如果你的网络需要代理，可以设置：

```r
# 设置HTTP代理
Sys.setenv(http_proxy = "http://your-proxy:port")
Sys.setenv(https_proxy = "http://your-proxy:port")

# 然后重启应用
```

### 4. 使用自己的API密钥
创建 `.env` 文件来使用你自己的豆包API密钥：

```bash
# 复制示例文件
cp .env.example .env

# 编辑 .env 文件，填入你的API密钥
DOUBAO_API_KEY=your-api-key-here
ENABLE_AI_ANALYSIS=true
```

### 5. 查看详细日志
重启应用后，在R控制台查看AI相关的日志输出：
- `AI Chat Module initialized:`
- `AI API: Testing connection to...`
- `AI API Test: Response status:`

## 联系信息
如果问题持续存在，请提供以下信息：
1. 错误日志
2. 网络环境描述（是否使用代理、公司网络等）
3. 操作系统和R版本