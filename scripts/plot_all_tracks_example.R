#!/usr/bin/env Rscript
# Example: Plot all tracks for a driver in a season using facet_wrap
# Uses the plot_all_tracks_season function from R/plot_functions.R

# Load required packages
suppressPackageStartupMessages({
  library(f1dataR)
  library(ggplot2)
  library(dplyr)
})

# Source plotting functions
source("R/plot_functions.R")

# Configuration
SEASON <- 2022
DRIVER <- "VER"
OUTPUT_DIR <- "plots"

# Create directories
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

# Main execution
main <- function() {
  cat("\n")
  cat("===========================================================\n")
  cat(sprintf("F1 All Tracks Analysis - %s %d Season\n", DRIVER, SEASON))
  cat("===========================================================\n")
  cat("\n")

  # Create faceted plot for all tracks in the season
  p <- plot_all_tracks_season(
    season = SEASON,
    driver = DRIVER,
    session = "R",
    color = "gear"
  )

  cat("\nSaving plot...\n")

  # Save the plot
  plot_file <- file.path(
    OUTPUT_DIR,
    sprintf(
      "%s_all_tracks_%d_season.png",
      DRIVER,
      SEASON
    )
  )

  ggsave(
    plot_file,
    p,
    width = 24,
    height = 12,
    dpi = 300
  )

  cat(sprintf("✓ Plot saved to: %s\n", plot_file))

  cat("\n")
  cat("===========================================================\n")
  cat("Analysis complete!\n")
  cat("===========================================================\n")
  cat("\n")
}

# Run main function
main()
