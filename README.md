# GIST Shiny 数据分析模块

这是 GIST_web 项目的 R Shiny 数据分析子模块，提供专业的基因表达数据分析功能。

## 功能说明

- **Module2**: 单基因表达分析
- **Module3**: 基因相关性分析  
- **Module4**: 药物耐药分析
- **Module5**: 治疗前后比较

## 独立运行

如果需要单独运行此 Shiny 应用：

```r
# 在 R 中
shiny::runApp(port = 4964)
```

## 集成运行

此模块已集成到 GIST_web 项目中，请使用父目录的启动脚本：

```bash
cd ..
./start_with_shiny.sh  # Linux/Mac
# 或
start_with_shiny.bat   # Windows
```

## 数据文件

数据文件存放在 `original/` 目录（已在 .gitignore 中排除）。