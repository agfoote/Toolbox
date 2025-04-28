# clustering_functions_README

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