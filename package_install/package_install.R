##########################################################################################################
#---------------------------------Install Packages function ---------------------------------------------#
##########################################################################################################

install_if_missing <- function(pkg_list, install = TRUE, github_pkgs = NULL) {
  # Install BiocManager if needed
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    if (install) install.packages("BiocManager")
  }

  # Deduplicate and remove base packages
  pkg_list <- unique(pkg_list)
  base_pkgs <- rownames(installed.packages(priority = "base"))
  pkg_list <- setdiff(pkg_list, base_pkgs)

  # Check what's already installed
  installed <- rownames(installed.packages())
  missing_pkgs <- setdiff(pkg_list, installed)

  if (length(missing_pkgs) == 0) {
    message("✅ All packages are already installed.")
    return(invisible(NULL))
  }

  # 📝 Reporting missing packages
  message("📦 Missing packages detected:")
  message(" - Missing: ", paste(missing_pkgs, collapse = ", "))

  # Prepare lists for CRAN, Bioconductor, and GitHub packages
  cran_pkgs <- c()
  bioc_pkgs <- c()
  gh_pkgs <- c()

  # Separate packages into categories
  for (pkg in missing_pkgs) {
    # Check CRAN
    cran_available <- tryCatch({
      available.packages()[pkg, ]
      TRUE
    }, error = function(e) FALSE)

    if (cran_available) {
      cran_pkgs <- c(cran_pkgs, pkg)
      next
    }

    # Check Bioconductor availability with correct repos
    bioc_available <- tryCatch({
      bioc_repos <- BiocManager::repositories()
      bioc_pkgs_all <- rownames(available.packages(repos = bioc_repos))
      pkg %in% bioc_pkgs_all
    }, error = function(e) FALSE)

    if (!is.na(bioc_available)) {
      bioc_pkgs <- c(bioc_pkgs, pkg)
      next
    }

    # Fallback to GitHub
    gh_pkgs <- c(gh_pkgs, pkg)
  }

  # 📝 Reporting
  if (length(cran_pkgs)) message(" - From CRAN: ", paste(cran_pkgs, collapse = ", "))
  if (length(bioc_pkgs)) message(" - From Bioconductor: ", paste(bioc_pkgs, collapse = ", "))
  if (length(gh_pkgs)) {
    message(" - From GitHub: ")
    for (pkg in gh_pkgs) {
      repo <- if (!is.null(github_pkgs) && pkg %in% names(github_pkgs)) {
        github_pkgs[[pkg]]
      } else {
        "<unknown repo — supply via `github_pkgs`>"
      }
      message("   • ", pkg, " => ", repo)
    }
  }

  if (!install) {
    message("⚠️  Installation skipped (install = FALSE).")
    return(invisible(list(CRAN = cran_pkgs, Bioconductor = bioc_pkgs, GitHub = gh_pkgs)))
  }

  # 🔧 Begin installations with progress bar
  total_pkgs <- length(cran_pkgs) + length(bioc_pkgs) + length(gh_pkgs)
  success_count <- total_pkgs  # Start with the total count of packages (success counter)
  progress <- 0  # Counter for progress updates
  pb <- txtProgressBar(min = 0, max = total_pkgs, style = 3)  # Create progress bar

  # Install CRAN packages
  if (length(cran_pkgs)) {
    message("📦 Installing CRAN packages: ", paste(cran_pkgs, collapse = ", "))
    for (pkg in cran_pkgs) {
      withCallingHandlers({
        tryCatch({
          install.packages(pkg)
          progress <- progress + 1
          setTxtProgressBar(pb, progress)  # Update progress bar
        }, error = function(e) {
          message(paste("❌ Failed to install CRAN package:", pkg))
          success_count <<- success_count - 1  # Decrease success counter on failure
        })
      }, warning = function(w) {
        if (grepl("non-zero exit status", w$message)) {
          dep_pkg <- strsplit(w$message, ":")[[1]][1]
          message(paste("⚠️ Warning during installation of dependency:", dep_pkg, "for package:", pkg))
          success_count <<- success_count - 1  # Decrease success counter on warning
          invokeRestart("muffleWarning")
        }
      })
    }
  }

  # Install Bioconductor packages
  if (length(bioc_pkgs)) {
    message("🧬 Installing Bioconductor packages: ", paste(bioc_pkgs, collapse = ", "))
    for (pkg in bioc_pkgs) {
      withCallingHandlers({
        tryCatch({
          BiocManager::install(pkg)
          progress <- progress + 1
          setTxtProgressBar(pb, progress)  # Update progress bar
        }, error = function(e) {
          message(paste("❌ Failed to install Bioconductor package:", pkg))
          success_count <<- success_count - 1  # Decrease success counter on failure
        })
      }, warning = function(w) {
        if (grepl("non-zero exit status", w$message)) {
          dep_pkg <- strsplit(w$message, ":")[[1]][1]
          message(paste("⚠️ Warning during installation of dependency:", dep_pkg, "for package:", pkg))
          success_count <<- success_count - 1  # Decrease success counter on warning
          invokeRestart("muffleWarning")
        }
      })
    }
  }

  # Install GitHub packages
  if (length(gh_pkgs)) {
    if (!requireNamespace("remotes", quietly = TRUE)) {
      install.packages("remotes")
    }
    for (pkg in gh_pkgs) {
      withCallingHandlers({
        tryCatch({
          repo <- if (!is.null(github_pkgs) && pkg %in% names(github_pkgs)) {
            github_pkgs[[pkg]]
          } else {
            stop(paste0("❌ Missing GitHub repo info for package: ", pkg,
                        "\nPlease supply it via the `github_pkgs` argument."))
          }
          message("🐙 Installing from GitHub: ", repo)
          remotes::install_github(repo)
          progress <- progress + 1
          setTxtProgressBar(pb, progress)  # Update progress bar
        }, error = function(e) {
          message(paste("❌ Failed to install GitHub package:", pkg))
          success_count <<- success_count - 1  # Decrease success counter on failure
        })
      }, warning = function(w) {
        if (grepl("non-zero exit status", w$message)) {
          dep_pkg <- strsplit(w$message, ":")[[1]][1]
          message(paste("⚠️ Warning during installation of dependency:", dep_pkg, "for package:", pkg))
          success_count <<- success_count - 1  # Decrease success counter on warning
          invokeRestart("muffleWarning")
        }
      })
    }
  }

  close(pb)  # Close the progress bar after installation is complete

  # Final message: report if any issues occurred
  if (success_count < total_pkgs) {
    issues <- total_pkgs - success_count
    message(paste("❗", issues, "issue(s) occurred during installation. Please review your output."))
  } else {
    message("✅ Installation completed without issues.")
  }
}