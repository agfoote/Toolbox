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
#--------------------------------------Importing csvs ---------------------------------------------------#
##########################################################################################################

import_all_csvs <- function(directory, pattern = "\\.csv$", recursive = FALSE) {
  # List all CSV files in the directory
  csv_files <- list.files(path = directory, pattern = pattern, full.names = TRUE, recursive = recursive)
  
  # Check if there are any CSV files
  if (length(csv_files) == 0) {
    warning("⚠️ No CSV files found in the specified directory.")
    return(list())
  }

  # Read each CSV into a list, naming each element by file name (without extension)
  csv_list <- lapply(csv_files, read.csv)
  names(csv_list) <- tools::file_path_sans_ext(basename(csv_files))

  return(csv_list)
}

import_selected_csvs <- function(directory, comparisons, recursive = FALSE) {
  # Combine comparisons into a single regex pattern
  pattern <- paste(comparisons, collapse = "|")

  # List matching CSV files
  csv_files <- list.files(
    path = directory,
    pattern = paste0("(", pattern, ").*\\.csv$"),
    full.names = TRUE,
    recursive = recursive
  )

  # Warn if no files found
  if (length(csv_files) == 0) {
    warning("⚠️ No matching CSV files found in the specified directory.")
    return(list())
  }

  # Import CSVs and name by filename without extension
  csv_list <- lapply(csv_files, read.csv)
  names(csv_list) <- tools::file_path_sans_ext(basename(csv_files))

  return(csv_list)
}

##########################################################################################################
#------------------------------- Generating dotplots & Nebulosa plots -----------------------------------#
##########################################################################################################

generate_marker_plots <- function(sobj, cell_markers, base_dir) {
  if (!dir.exists(base_dir)) dir.create(base_dir, recursive = TRUE)

  # Use number of unique seurat_clusters (not Idents)
  n_celltypes <- length(unique(sobj$seurat_clusters))

  for (ct in names(cell_markers)) {
    genes <- cell_markers[[ct]]
    n_genes <- length(genes)

    # Match your original logic
    height <- ifelse(n_celltypes > 10, 0.4 * n_celltypes, 4)
    width  <- ifelse(n_genes > 6, 0.5 * n_genes, 6)

    # DotPlot
    dotplot_path <- file.path(base_dir, paste0("DotPlot_", ct, ".pdf"))
    pdf(dotplot_path, width = width, height = height)
    tryCatch({
      print(DotPlot(sobj, features = genes) +
              RotatedAxis() +
              ggtitle(paste("DotPlot:", ct)) +
              theme(text = element_text(size = 12)))
    }, error = function(e) {
      message(paste("Skipping DotPlot for", ct, "due to error:", e$message))
    })
    dev.off()

    # Nebulosa
    nebulosa_path <- file.path(base_dir, paste0("Nebulosa_", ct, ".pdf"))
    pdf(nebulosa_path, width = width, height = height)
    tryCatch({
      print(plot_density(sobj, genes, joint = TRUE))
    }, error = function(e) {
      message(paste("Skipping Nebulosa plot for", ct, "due to error:", e$message))
    })
    dev.off()
  }

  message("All plots saved to: ", base_dir)
}

#Example usage:

#cell_markers <- list(
  #AT2 = c("SFTPC", "SFTPB", "ABCA3", "LAMP3", "ETV5", "FGFR2"),
 # Transitional = c("KRT8", "CLDN4", "KRT19", "SFN", "LGALS3"),
#  AT1 = c("AQP5", "PDPN", "AGER", "CAV1")
#)

#generate_marker_plots(sobj = sobj, cell_markers = cell_markers, base_dir = "./MarkerPlots")

##########################################################################################################
#------------------------------------- Save as PDF ------------------------------------------------------#
##########################################################################################################

save_plots_as_pdf <- function(seurat_object, plots, output_file = "output_plots.pdf") {
  # Extract the unique cell types from the Seurat object
  celltypes <- unique(seurat_object$seurat_clusters)  # or other relevant metadata column
  
  # Calculate width and height for the PDF
  num_celltypes <- length(celltypes)
  pdf_width <- num_celltypes * 2  # You can adjust this multiplier as needed
  pdf_height <- num_celltypes * 2  # You can adjust this multiplier as needed
  
  # Open a PDF device
  pdf(file = output_file, width = pdf_width, height = pdf_height)
  
  # Loop through the plots and save each one
  for (plot in plots) {
    print(plot)  # Print the plot to the PDF device
  }
  
  # Close the PDF device
  dev.off()
}

##########################################################################################################
#------------------------------------ Save as Tiff ------------------------------------------------------#
##########################################################################################################

save_plots_as_tiff <- function(seurat_object, plots, base_filename = "plot") {
  celltypes <- unique(seurat_object$seurat_clusters)
  num_celltypes <- length(celltypes)
  tiff_width <- num_celltypes * 2
  tiff_height <- num_celltypes * 2
  
  for (i in seq_along(plots)) {
    plot_name <- paste0(base_filename, "_", names(plots)[i], ".tiff")

    
    tiff(
      filename = plot_name,
      width = tiff_width,
      height = tiff_height,
      units = "in",
      res = 300,
      compression = "lzw",
      type = "cairo"
    )
    
    print(plots[[i]])
    dev.off()
  }
}


