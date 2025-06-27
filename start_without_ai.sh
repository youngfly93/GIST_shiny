#!/bin/bash

echo "========================================"
echo "   启动GIST Shiny应用 - 非AI版本"
echo "   端口: 4966"
echo "   AI功能: 禁用"
echo "========================================"

# 切换到脚本目录
cd "$(dirname "$0")"

# 备份原始.env文件
if [ -f .env ]; then
    cp .env .env.backup
    echo "已备份原始配置文件"
fi

# 使用非AI配置文件
cp .env.no-ai .env
echo "正在加载非AI配置..."

# 启动Shiny应用
echo "正在启动应用..."
Rscript -e "shiny::runApp(port = 4966, host = '127.0.0.1', launch.browser = FALSE)"

# 恢复原始.env文件
if [ -f .env.backup ]; then
    cp .env.backup .env
    rm .env.backup
    echo "已恢复原始配置文件"
fi

# 检查退出状态
if [ $? -ne 0 ]; then
    echo ""
    echo "应用启动失败，请检查错误信息"
    read -p "按Enter键退出..."
fi
