# package_install_README

## 📦  `install_if_missing`

### **PURPOSE**

---

This function checks for missing CRAN, Bioconductor, or GitHub R packages from a provided list and optionally installs them with real-time progress tracking and error handling.

---

### **INPUT**

```r
install_if_missing(pkg_list,
                   install = TRUE,
                   github_pkgs = NULL)

```

- **`pkg_list`** *(character vector)*: List of package names to check for and install if missing
    - Must be a vector of R package names (e.g. `c("dplyr", "Seurat", "ggplot2")`)
- **`install`** *(logical)*: Whether to perform the actual installation or just return a breakdown of missing packages
    - ⚙️ **DEFAULT**: `TRUE`
- **✨`github_pkgs`** *(named character vector or NULL)*: A named vector where names are package names and values are GitHub repo paths (e.g., `c("scCustomize" = "samuel-marsh/scCustomize")`)
    - Required if any of the packages must be installed from GitHub
    - ⚙️ **DEFAULT**: `NULL`

---

### **OUTPUT**

```r
# Example run
install_if_missing(c("dplyr", "BiocGenerics", "scCustomize"), github_pkgs = c(scCustomize = "samuel-marsh/scCustomize"))

# If install = FALSE
result <- install_if_missing(pkg_list, install = FALSE, github_pkgs = github_mapping)

```

- ✅ **If `install = TRUE`**: The function will attempt to install all missing packages and print progress and success/failure messages to the console
- 📦 **If `install = FALSE`**: The function returns a named list of missing packages categorized by source
    - Example output:
        
        ```r
        list(
          CRAN = c("ggplot2", "dplyr"),
          Bioconductor = c("BiocGenerics"),
          GitHub = c("scCustomize")
        )
        
        ```
        
- 🚧 **Warnings and errors** during install will be reported, including package-specific messages
    - Will also give a summary at the end of the number of package installation issues that occurred
- 📊 **Progress bar** tracks installation success across all sources

Here is an example warning and progress bar output

![image.png](package_install_README%201de49d58874d80059174eabe023ec608/image.png)

Additionally here is a variable with all of the packages you should need to perform single cell analysis 

```jsx
packages <- c(
  "stats", "graphics", "grDevices", "utils", "datasets", "methods", "base", 
  "vctrs", "cli", "knitr", "rlang", "xfun", "generics", "glue", "listenv", 
  "colorspace", "htmltools", "gridExtra", "viridis", "scales", "fansi", "rmarkdown", 
  "grid", "evaluate", "munsell", "tibble", "fastmap", "yaml", "lifecycle", 
  "compiler", "codetools", "dplyr", "pkgconfig", "future", "rstudioapi", "digest", 
  "viridisLite", "R6", "tidyselect", "utf8", "parallelly", "parallel", "pillar", 
  "magrittr", "tools", "gtable", "globals", "ggplot2", "scCustomize", "EnhancedVolcano", 
  "ggrepel", "biomaRt", "org.Mm.eg.db", "enrichR", "data.table", "kableExtra", "topGO", 
  "SparseM", "GO.db", "AnnotationDbi", "IRanges", "S4Vectors", "Biobase", "graph", 
  "BiocGenerics", "Seurat", "SeuratObject", "sp", "future", "patchwork", "CellChat", 
  "igraph", "Seurat", "tidyverse", "reshape", "ggbeeswarm", "sctransform", "Rcpp", 
  "stringr", "pbapply", "RcppHNSW", "svglite", "shiny", "AUCell", "BiocParallel", 
  "ComplexHeatmap", "decoupleR", "fgsea", "ggtree", "GSEABase", "GSVA", "Nebulosa", 
  "scde", "singscore", "SummarizedExperiment", "UCell", "viper", "sparseMatrixStats", 
  "AnnotationHub", "KernelKnn", "RcppML", "RobustRankAggreg", "tidytree", "VAM", 
  "SeuratDisk", "RcppEigen", "spatstat", "abind", "bslib", "withr", "colorspace", 
  "RcppArmadillo", "RcppGSL", "RcppProgress", "RcppParallel", "RcppEigen", "edgeR", 
  "limma", "distillery", "flexmix", "pcaMethods", "limma", "extRemes", "pcaMethods", 
  "scde", "sctransform", "devtools", "reticulate", "uwot", "spatstat", "RANN", "patchwork", 
  "ggrepel", "fastDummies", "irGSEA", "RcppML", "coda", "FNN", "ggprism", "BiocManager", 
  "dotCall64", "carData", "RANN", "mgcv", "MatrixGenerics", "roxygen2", "cli", "purrr", 
  "leiden", "lifecycle", "uwot", "mvtnorm", "sessioninfo", "backports", "BiocParallel", 
  "annotate", "timechange", "gtable", "rjson", "ggridges", "progressr", "limma", 
  "parallel", "edgeR", "scde", "jsonlite", "RcppHNSW", "bitops", "bit64", "Rtsne", 
  "yulab.utils", "spatstat.utils", "BiocNeighbors", "jquerylib", "spatstat.univar", 
  "lazyeval", "shiny", "htmltools", "sctransform", "rappdirs", "glue", "spam", "XVector", 
  "RCurl", "extRemes", "mclust", "ks", "RMTstat", "gridExtra", "R6", "SingleCellExperiment", 
  "tidyr", "forcats", "cluster", "rngtools", "pkgload", "GenomeInfoDb", "statnet.common", 
  "DelayedArray", "tidyselect", "vipor", "xml2", "car", "munsell", "KernSmooth", 
  "htmlwidgets", "ComplexHeatmap", "RColorBrewer", "rlang", "spatstat.sparse", 
  "spatstat.explore", "remotes", "Cairo", "fansi", "beeswarm", "abind", "ggsignif", 
  "ggplotify", "tibble", "Matrix", "statmod", "callr", "tzdb", "svglite", "pkgconfig", 
  "network", "tools", "Rook", "cachem", "RSQLite", "viridisLite", "DBI", "fastmap", 
  "rmarkdown", "scales", "grid", "usethis", "ica", "broom", "sass", "Seurat", "ggplot2",
  "harmony", "dplyr", "DoubletFinder", "patchwork", "presto", "hdf5r", "Signac", "GenomeInfoDb", 
  "EnsDb.Mmusculus.v79", "chromVAR", "JASPAR2020", "TFBSTools", "GenomicRanges", "motifmatchr", 
  "BSgenome.Mmusculus.UCSC.mm10", "ggseqlogo", "clusterProfiler", "org.Mm.eg.db", "enrichplot", 
  "AnnotationDbi", "CellChat"
)
length(packages)
```