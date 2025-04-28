# scRNAseq_README

# **🧰 Toolbox Functions Overview**

This toolbox includes the following functions:

- `run_cluster_umap`
- `import_all_csvs`
- `import_selected_csvs`
- `generate_marker_plots`
- `save_plots_as_pdf`
- `save_plots_as_tiff`

Each function is documented with the following structure:

- **PURPOSE**: A one-sentence description of what the function does
- **INPUT**: Arguments accepted by the function (with data types and notes on default values)
    - Optional arguments are noted with ✨
- **OUTPUT**: What the function returns or writes (e.g., R objects, plots, file types)

---

To use this toolbox, simply source it into any Jupyter Notebook or R script. For example:

```r
source("/tscc/projects/ps-sunlab/project/Annika_files/toolbox/scRNAseq_toolbox.R")

```

Once sourced, you can call the functions just like you would with any standard R package. If you're curious about how a function works, you can view its code by typing the function name and running the code chunk.

---

## 🔍 `run_cluster_umap`

### **PURPOSE**

This function performs iterative clustering and UMAP dimensionality reduction on a Seurat object across multiple dimensions and resolutions, optionally applying custom color schemes, and returns both the updated object and corresponding UMAP plots.

---

### **INPUT**

```r
run_cluster_umap(seurat_object,
                 dims = 50,
                 resolutions = c(0.2, 0.5, 0.8, 1.0, 1.5, 2.0),
                 group_by = "seurat_clusters",
                 colors_file = NULL)

```

- **`seurat_object`** *(Seurat object)*: A Seurat object containing scRNA-seq data
- **`dims`** *(numeric or vector of integers)*: Dimensions to use for PCA and UMAP
    - ⚙️ **DEFAULT**: `50`
- **`resolutions`** *(numeric vector)*: Resolutions to use for clustering
    - ⚙️ **DEFAULT**: `c(0.2, 0.5, 0.8, 1.0, 1.5, 2.0)`
- **`group_by`** *(string)*: Column name in metadata used to group cells for coloring in UMAP
    - **⚙️ DEFAULT**: `"seurat_clusters"`
- **✨`colors_file`** *(string, data frame, vector or NULL)*: variable containing cells annotations and hex codes for coloring the UMAP.
    - The input must be one of the following
        - A csv file path. The csv must contain two columns `cells` and `hex`
            - CSV file titled “colors_CIRM.csv” is uploaded on the Github that you can use
            - Double check that your cell type annotations are **exactly** the same as what is in the file. Otherwise the UMAP will colors those annotated cells gray
        - A data frame containing two columns named `cells` and `hex`
            - Double check that your cell type names are **exactly** the same as what is in the file. Otherwise the UMAP will colors those annotated cells gray
        - A named vector formatted c(”Cell type name 1” = “hex code”,  “Cell type name 2“= “hex code”)
            - Double check that your cell type names are **exactly** the same as what is in the file. Otherwise the UMAP will colors those annotated cells gray
    - **⚙️ DEFAULT**: `NULL`

---

### **OUTPUT**

```jsx
# Running the function
result <- run_cluster_umap(seurat_object, dims = dims_to_run, resolutions = c(0.5,1.0), group_by = "Final_CellType_v2", colors_file = "/tscc/projects/ps-epigen/users/a2jorgensen/sandbox/250225_humanAT2_organoids/data/Clustering/colors_CIRM.csv")

# Storing outputs
plots<- result$plots
sobj_up<-result$seurat_object

# To display a specific plot, for example, 50 dimensions, resolution 1.0, and grouped by 'seurat_clusters'
#print(plots$dim_50_res_1.0_group_seurat_clusters)
```

- The function will output a list (e.g. stored in result above) with the following
    - 📦 **Updated Seurat object**: Contains PCA, clustering, and UMAP results
    - 📊 **UMAP plots** *(stored in a named list)*: One plot per resolution/dimension combination
        - **✨** Optional visualizations: If custom colors are supplied, plots will apply the defined colors
    - I’d recommend to store the plots and the seurat object as separate variables afterwards. Especially if you want to do downstream analysis with said seurat object

---

## 📂 `import_all_csvs`

### **PURPOSE**

This function imports all `.csv` files from a specified directory (optionally recursive) into a named list of data frames.

---

### **INPUT**

```r
import_all_csvs(directory,
                pattern = "\\.csv$",
                recursive = FALSE)

```

- **`directory`** *(string)*: Path to the folder containing `.csv` files
    - Must be a valid file path (absolute or relative)
- **✨`pattern`** *(string)*: Regular expression used to match files
    - Useful if you want to match specific filename patterns (e.g., files containing “*DESeq*”)
    - ⚙️ **DEFAULT**: `"\\.csv$"` (matches all `.csv` files)
- **✨`recursive`** *(logical)*: Whether to search subdirectories within the specified directory
    - ⚙️ **DEFAULT**: `FALSE`

---

### **OUTPUT**

```r
# Example run
csv_list <- import_all_csvs("/path/to/folder", pattern = "_DESeq_.*\\.csv$", recursive = TRUE)

# Accessing individual files
head(csv_list$filename1)

```

- 📦 **Named list of data frames**: Each element is a data frame read from a `.csv` file
    - Element names correspond to the file names (without extensions)
    - You can access each CSV using `csv_list$filename`
- ⚠️ **If no matching files found**: A warning is returned and the function outputs an empty list

---

## 🎯 `import_selected_csvs`

### **PURPOSE**

This function selectively imports `.csv` files from a specified directory whose filenames match user-defined comparison patterns, returning a named list of data frames.

---

### **INPUT**

```r
import_selected_csvs(directory,
                     comparisons,
                     recursive = FALSE)

```

- **`directory`** *(string)*: Path to the folder containing `.csv` files
    - Must be a valid file path (absolute or relative)
- **`comparisons`** *(character vector)*: Vector of keyword patterns used to identify files to import
    - Each entry should match part of the filename (e.g., `"BPD_Chronic-BPD_Chronic_control"`)
- **✨`recursive`** *(logical)*: Whether to search subdirectories within the specified directory
    - ⚙️ **DEFAULT**: `FALSE`

---

### **OUTPUT**

```r
# Example run
csv_list <- import_selected_csvs(
  directory = "/path/to/folder",
  comparisons = c("BPD_Chronic-BPD_Chronic_control", "Active_evolving-Active_evolving_control")
)

# Accessing one of the imported CSVs
head(csv_list$BPD_Chronic_data)

```

- 📦 **Named list of data frames**: Each element is a data frame read from a matching `.csv` file
    - Element names are based on the filename (excluding the extension)
    - Enables easy downstream use with `csv_list$filename`
- ⚠️ **If no matching files found**: A warning is returned and the function outputs an empty list

---

## 🔴 `generate_marker_plots`

### **PURPOSE**

This function generates and saves DotPlot and Nebulosa plots for user-defined gene markers across Seurat clusters, adjusting plot dimensions based on gene and cluster count.

---

### **INPUT**

```r
generate_marker_plots(sobj,
                      cell_markers,
                      base_dir)

```

- **`sobj`** *(Seurat object)*: A Seurat object containing single-cell RNA-seq data
    - The object must include UMAP and clustering results (e.g., `seurat_clusters`)
- **`cell_markers`** *(named list)*: A named list where each name is a cell type and the values are character vectors of marker gene names
    - Example:
        
        ```r
        list(
          AT2 = c("SFTPC", "ABCA3"),
          AT1 = c("AGER", "PDPN")
        )
        
        ```
        
- **`base_dir`** *(string)*: Directory path where plots will be saved
    - If the directory does not exist, it will be created automatically

---

### **OUTPUT**

```r
# Example usage
generate_marker_plots(sobj = sobj,
                      cell_markers = cell_markers,
                      base_dir = "./MarkerPlots")

```

- 🔴 **DotPlot PDFs**: One file per cell type, named `DotPlot_<CellType>.pdf`, showing marker expression across clusters
- 🏔️ **Nebulosa PDFs**: One file per cell type, named `Nebulosa_<CellType>.pdf`, showing density-based expression using joint gene features
- 🗂️ **All files are saved to** the provided `base_dir`
- 📏 **Dynamic sizing**: Width and height of plots are automatically adjusted based on the number of markers and number of clusters
- ⚠️ **Error-tolerant**: If a gene or cell type cannot be plotted, the function will skip it and continue without crashing

---

## 🖨️ `save_plots_as_pdf`

### **PURPOSE**

This function saves a list of ggplot2-style plots (e.g., UMAPs or DotPlots) into a single PDF file, automatically adjusting the page size based on the number of cell types in the associated Seurat object.

---

### **INPUT**

```r
save_plots_as_pdf(seurat_object,
                  plots,
                  output_file = "output_plots.pdf")

```

- **`seurat_object`** *(Seurat object)*: A Seurat object used to determine the number of unique clusters or cell types for dynamic PDF sizing
    - Typically uses the `seurat_clusters` metadata field for cell type estimation
- **`plots`** *(list)*: A list of ggplot2-compatible plots (e.g., those generated from `run_cluster_umap()` or `DotPlot()`)
    - Plots will be printed one after another across multiple pages
- **✨`output_file`** *(string)*: File path where the resulting PDF will be saved
    - ⚙️ **DEFAULT**: `"output_plots.pdf"`

---

### **OUTPUT**

```r
# Example usage
save_plots_as_pdf(
  seurat_object = sobj,
  plots = result$plots,
  output_file = "./umap_panels.pdf"
)

```

- 🖨️ **Multi-page PDF file**: A single `.pdf` where each plot in the list is saved on its own page
- 📐 **Auto-sizing**: PDF width and height are dynamically calculated based on the number of unique `seurat_clusters` to ensure plots are readable
- 📂 **Output saved to** the specified file path

---

## 🖼️ `save_plots_as_tiff`

### **PURPOSE**

This function saves each plot in a list as a separate high-resolution TIFF file, scaling the image size based on the number of Seurat clusters and naming each file with a consistent prefix.

---

### **INPUT**

```r
save_plots_as_tiff(seurat_object,
                   plots,
                   base_filename = "plot")

```

- **`seurat_object`** *(Seurat object)*: A Seurat object used to determine the number of unique clusters (`seurat_clusters`) for plot scaling
    - The number of clusters controls the dimensions of each TIFF
- **`plots`** *(named list)*: A list of ggplot2-compatible plots to be saved
    - Each plot must have a name (e.g., `"dim_50_res_1.0"`) to be used in the filename
- **✨`base_filename`** *(string)*: Prefix for the output TIFF filenames
    - ⚙️ **DEFAULT**: `"plot"`
    - Final filenames will be formatted like `"plot_dim_50_res_1.0.tiff"`

---

### **OUTPUT**

```r
# Example usage
save_plots_as_tiff(
  seurat_object = sobj,
  plots = result$plots,
  base_filename = "./MarkerPlots/UMAP"
)

```

- 🖼️ **Individual TIFF files**: One TIFF per plot, named using the provided base filename and the plot's name
    - e.g., `"UMAP_dim_50_res_1.0.tiff"`
- 📐 **Auto-scaling**: TIFF width and height are dynamically calculated based on the number of clusters (2 inches per cluster)
- 🗂️ **Output directory**: Files are saved to the location implied by `base_filename`

---