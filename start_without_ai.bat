@echo off
echo ========================================
echo    启动GIST Shiny应用 - 非AI版本
echo    端口: 4966
echo    AI功能: 禁用
echo ========================================

REM 切换到脚本目录
cd /d "%~dp0"

REM 备份原始.env文件
if exist .env (
    copy .env .env.backup >nul 2>&1
    echo 已备份原始配置文件
)

REM 使用非AI配置文件
copy .env.no-ai .env >nul 2>&1
echo 正在加载非AI配置...

REM 启动Shiny应用
echo 正在启动应用...
Rscript -e "shiny::runApp(port = 4966, host = '127.0.0.1', launch.browser = FALSE)"

REM 恢复原始.env文件
if exist .env.backup (
    copy .env.backup .env >nul 2>&1
    del .env.backup >nul 2>&1
    echo 已恢复原始配置文件
)

REM 如果出错则保持窗口打开
if errorlevel 1 (
    echo.
    echo 应用启动失败，请检查错误信息
    pause
)
