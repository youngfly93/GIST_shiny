# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

dbGIST is a Shiny web application for analyzing gastrointestinal stromal tumor (GIST) gene expression data. It provides comprehensive bioinformatics analysis tools including single gene expression analysis, gene-to-gene correlation, drug resistance gene exploration, and pre/post treatment comparison.

## Commands

### Running the Application
```bash
# Main Shiny app (multiple options)
shiny::runApp(port = 4964)          # Direct R command
./start_shiny.sh                    # Linux/Mac shell script
start_shiny.bat                     # Windows batch file
Rscript run_app.R                   # R script
```

### Testing
```r
# Run all tests
source("tests/test_modules.R")
run_all_tests()

# Run individual test categories
test_data_generator()
test_module_integration()
test_performance()
test_configuration()
```

## Architecture

### Data Structure
The core data object is `dbGIST_matrix` containing multiple datasets with:
- Expression matrices (genes × samples)
- Clinical metadata (patient info, mutations, treatment response)

### Module System
The app uses a modular architecture:
- **modules/analysis_module.R**: Reusable UI/Server components for analysis
- **modules/data_utils.R**: R6 class-based data generation and processing
- **modules/ai_chat_module.R**: AI-powered image analysis assistant
- **config/module_configs.R**: Centralized configuration management

### Analysis Modules
- **Module 2**: Single gene expression by gender
- **Module 3**: Gene-gene expression correlation  
- **Module 4**: Drug resistance with ROC curves
- **Module 5**: Pre/post treatment paired analysis

### Key Functions (global.R)
- `Judge_GENESYMBOL()`: Gene symbol validation
- `dbGIST_boxplot_*()`: Visualization functions for different analyses
- `dbGIST_cor_ID()`: Correlation analysis
- `dbGIST_boxplot_Drug()`: Drug resistance analysis with ROC
- `dbGIST_boxplot_PrePost()`: Paired treatment comparison

## Dependencies

### R Packages
- **UI**: shiny, bs4Dash, shinyjs, shinyBS, shinyWidgets, waiter, shinyFeedback
- **Visualization**: ggplot2, ggsci, ggpubr, patchwork
- **Data**: tidyverse, data.table, stringr, R6
- **Bioinformatics**: clusterProfiler, org.Hs.eg.db, EnsDb.Hsapiens.v75, AnnotationDbi
- **Statistics**: pROC, yaGST
- **Other**: slickR, shinycssloaders, DT, htmlwidgets

### Required Data Files (in original/ directory)
- `dbGIST_matrix(2).Rdata`: Main expression data
- `GSE15966_20230217.CSV`: Clinical information
- Various pathway and immune cell RData files

## Development Patterns

### Adding New Analysis Types
1. Define configuration in `config/module_configs.R`
2. Implement analysis function following `dbGIST_*` pattern
3. Add data generation method to `data_utils.R`
4. Update UI navigation in `ui.R`

### Module Usage
```r
# UI
analysisModuleUI(id = "module_id", title = "Analysis Title", 
                input_config = config$input_config)

# Server
analysisModuleServer(id = "module_id", analysis_config = config)
```

### Data Generation
```r
# Single gene
data <- generate_module_data("gender", "TP53")

# Gene correlation
data <- generate_module_data("correlation", "MCM7", "MKI67")

# Drug resistance
data <- generate_module_data("drug", "TOP2A", drug_name = "Imatinib")
```

## Important Notes

- The app uses Chinese UI with some English elements
- Default port is 4964 (configurable)
- Download functionality supports SVG, PDF, PNG for plots and CSV, TXT for data
- Input validation provides real-time user feedback
- Statistical analyses include p-values, correlations, and ROC curves
- The refactoring achieved 90% code reduction between modules
- AI chat module provides automatic analysis of generated plots