#!/bin/bash

echo "========================================"
echo "   启动GIST Shiny应用 - AI版本"
echo "   端口: 4964"
echo "   AI功能: 启用"
echo "========================================"

# 切换到脚本目录
cd "$(dirname "$0")"

# 设置环境变量 - 使用默认.env文件（启用AI）
echo "正在加载AI配置..."

# 启动Shiny应用
echo "正在启动应用..."
Rscript -e "shiny::runApp(port = 4964, host = '127.0.0.1', launch.browser = FALSE)"

# 检查退出状态
if [ $? -ne 0 ]; then
    echo ""
    echo "应用启动失败，请检查错误信息"
    read -p "按Enter键退出..."
fi
