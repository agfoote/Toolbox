library(Seurat)           # For Seurat object manipulation, RunPCA, RunUMAP, FindClusters, DotPlot, etc.
library(ggplot2)          # For plot theming (used in DotPlot modifications and titles)
library(dplyr)            # For any potential Seurat-based metadata manipulation (implicitly useful)
library(patchwork)        # For combining ggplot-based plots, potentially used in visualization steps
library(Nebulosa)         # For `plot_density()` in generate_marker_plots
library(viridis)          # Used by nebulosa when plotting 
library(igraph)           # Only needed if doing graph-based operations (used internally by Seurat)

###### Optional libraries#########
library(sctransform)      # Only required if you preprocess with SCTransform (not shown in functions)
library(readr)            # For reading in custom CSVs if using `read_csv` instead of `read.csv`



##########################################################################################################
#--------------------------------------Clustering Function-----------------------------------------------#
##########################################################################################################

# Define the function
run_cluster_umap <- function(seurat_object, dims = 50, resolutions = c(0.2, 0.5, 0.8, 1.0, 1.5, 2.0), 
                             group_by = "seurat_clusters", colors_file = NULL) {
  # Create a list to store the plots
  plots <- list()

    # Check if colors_file is provided and load it if so
  if (!is.null(colors_file)) {
  if (is.character(colors_file) && file.exists(colors_file)) {
    # Load from CSV file
    colors_df <- read.csv(colors_file, stringsAsFactors = FALSE)
    color_mapping <- setNames(colors_df$hex, colors_df$cells)
  } else if (is.data.frame(colors_file)) {
    # Use the data frame directly
    color_mapping <- setNames(colors_file$hex, colors_file$cells)
  } else if (is.vector(colors_file) && !is.null(names(colors_file))) {
    # Use named vector directly
    color_mapping <- colors_file
  } else {
    stop("colors_file must be a path to a CSV, a data frame with 'cells' and 'hex' columns, or a named vector.")
  }
} else {
  color_mapping <- NULL
}

  # Loop over each dimension to run PCA and UMAP for that number of dimensions
  for (dim in dims) {
    # Run PCA with the current number of dimensions
    seurat_object <- RunPCA(seurat_object, npcs = dim)
    
    # Loop over different resolutions
    for (res in resolutions) {
      # Run FindClusters for each resolution
      seurat_object <- FindClusters(seurat_object, resolution = res)

      # Store the clusters in the Seurat object under a unique name
      umap_name <- paste0("umap_", dim, "_res_", res)
     
      # Run UMAP for the current number of dimensions
      seurat_object <- RunUMAP(seurat_object, dims = 1:dim, reduction.name = umap_name)
    
     
      # Store the clusters in the Seurat object under a unique name
      cluster_column_name <- paste0("seurat_clusters_", dim, "_res_", res)
      seurat_object[[cluster_column_name]] <- seurat_object$seurat_clusters
      
      # Generate the UMAP plot for each resolution
      p <- DimPlot(seurat_object, reduction = umap_name, group.by = group_by) + 
           ggtitle(paste("Res", res, "w/ dims", dim, "grouped by", group_by))
      
      # Apply custom color mapping if colors_file is provided
      if (!is.null(color_mapping)) {
        p <- p + scale_color_manual(values = color_mapping)
      }
      
      plots[[paste0("dim_", dim, "_res_", res, "_group_", group_by)]] <- p
    }
  }
  
  # Return the updated Seurat object and the list of plots
  return(list(seurat_object = seurat_object, plots = plots))
}

# Example usage:
#seurat_object <- your_seurat_object  # Replace with your actual Seurat object
#dims_to_run <- c(30, 50)  # You can specify any dimensions you want to run
#group_by_var <- "seurat_clusters"  # Default grouping, can be changed
#colors_file_path <- "path/to/your/colors_file.csv"  # Specify the path to your colors file

# Example colors file format:
# group,color
# group1,#FF0000
# group2,#00FF00
# group3,#0000FF

# Running the function
#result <- run_cluster_umap(seurat_object, dims = dims_to_run, group_by = group_by_var, colors_file = colors_file_path)

# Get the updated Seurat object
#seurat_object_updated <- result$seurat_object

# Get the plots
#plots <- result$plots

# To display a specific plot, for example, 50 dimensions, resolution 1.0, and grouped by 'seurat_clusters'
#print(plots$dim_50_res_1.0_group_seurat_clusters)