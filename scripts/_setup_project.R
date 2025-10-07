#!/usr/bin/env Rscript
# Setup script: Install all required R packages for the project

cat("\n")
cat("===========================================\n")
cat("F1 Analytics Project Setup\n")
cat("===========================================\n")
cat("\n")

# Function to install package if not already installed
install_if_missing <- function(package, repo = "CRAN") {
  if (repo == "CRAN") {
    if (!require(package, character.only = TRUE, quietly = TRUE)) {
      cat(sprintf("Installing %s from CRAN...\n", package))
      install.packages(package, repos = "https://cloud.r-project.org/")
    } else {
      cat(sprintf("✓ %s already installed\n", package))
    }
  } else if (repo == "GitHub") {
    # For GitHub packages, package should be in format "user/repo"
    pkg_name <- basename(package)
    if (!require(pkg_name, character.only = TRUE, quietly = TRUE)) {
      cat(sprintf("Installing %s from GitHub...\n", package))
      remotes::install_github(package)
    } else {
      cat(sprintf("✓ %s already installed\n", pkg_name))
    }
  }
}

# Install remotes first (needed for GitHub packages)
cat("Step 1: Installing remotes package...\n")
install_if_missing("remotes")

cat("\n")
cat("Step 2: Installing core packages...\n")

# Core packages
core_packages <- c(
  "ggplot2", # Plotting
  "dplyr", # Data manipulation
  "tidyr", # Data tidying
  "lubridate", # Date handling
  "scales", # Scale functions for ggplot2
  "readr", # Reading data files
  "tibble", # Modern data frames
  "stringr", # String manipulation
  "purrr" # Functional programming
)

for (pkg in core_packages) {
  install_if_missing(pkg)
}

cat("\n")
cat("Step 3: Installing visualization packages...\n")

viz_packages <- c(
  "viridis", # Color palettes
  "RColorBrewer", # Color palettes
  "ggrepel", # Better text labels
  "patchwork" # Combine plots
)

for (pkg in viz_packages) {
  install_if_missing(pkg)
}

cat("\n")
cat("Step 4: Installing HTTP/API dependencies...\n")

# Workaround for curl compilation issues with old libcurl
cat("Installing curl from archive (older compatible version)...\n")
tryCatch({
  # Install older version of curl that works with older libcurl
  install.packages("https://cran.r-project.org/src/contrib/Archive/curl/curl_5.2.3.tar.gz",
                   repos = NULL,
                   type = "source",
                   configure.vars = "LIB_DIR=/usr/lib/x86_64-linux-gnu INCLUDE_DIR=/usr/include")
  cat("✓ curl 5.2.3 installed successfully\n")
  
  install.packages("httr2", repos = "https://cloud.r-project.org/")
  cat("✓ httr2 installed successfully\n")
}, error = function(e) {
  cat(sprintf("Error installing HTTP dependencies: %s\n", e$message))
})

cat("\n")
cat("Step 5: Installing f1dataR from GitHub...\n")
install_if_missing("SCasanova/f1dataR", repo = "GitHub")

cat("\n")
cat("Step 6: Creating project directories...\n")

# Create necessary directories
dirs <- c("plots", "data/cache", "scripts")
for (dir in dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat(sprintf("✓ Created directory: %s\n", dir))
  } else {
    cat(sprintf("✓ Directory already exists: %s\n", dir))
  }
}

cat("\n")
cat("Step 7: Verifying installation...\n")

# Test that key packages load
test_packages <- c("ggplot2", "dplyr", "f1dataR")
all_ok <- TRUE

for (pkg in test_packages) {
  result <- tryCatch(
    {
      library(pkg, character.only = TRUE, quietly = TRUE)
      TRUE
    },
    error = function(e) {
      FALSE
    }
  )

  if (result) {
    cat(sprintf("✓ %s loads successfully\n", pkg))
  } else {
    cat(sprintf("✗ %s failed to load\n", pkg))
    all_ok <- FALSE
  }
}

cat("\n")
cat("===========================================\n")
if (all_ok) {
  cat("✓ Setup complete! Ready to analyze F1 data!\n")
} else {
  cat("✗ Setup completed with errors. Please check above.\n")
}
cat("===========================================\n")
cat("\n")

cat("Next steps:\n")
cat("1. Run example scripts: Rscript scripts/example_lap_times.R\n")
cat("2. Generate all plots: make plots\n")
cat("3. Format R code: make format\n")
cat("\n")
