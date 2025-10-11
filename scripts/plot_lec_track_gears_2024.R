#!/usr/bin/env Rscript
# Plot track and gears in use on fastest lap by a single driver
# Uses the plot_track_gears function from R/plot_functions.R

# Load required packages
suppressPackageStartupMessages({
  library(f1dataR)
  library(ggplot2)
  library(dplyr)
  library(gghighcontrast)
})

# Source plotting functions
source("R/plot_functions.R")

# Configuration
SEASON <- 2024
ROUND <- 16
DRIVER <- "LEC"
OUTPUT_DIR <- "plots"

# Create directories
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

# Main execution
main <- function() {
  cat("\n")
  cat("===========================================================\n")
  cat(sprintf(
    "F1 Track and Gears Analysis - %s %d Round %d\n",
    DRIVER,
    SEASON,
    ROUND
  ))
  cat("===========================================================\n")
  cat(sprintf("Season: %d, Round: %d, Driver: %s\n", SEASON, ROUND, DRIVER))
  cat("\n")

  cat("Step 1: Creating track and gears plot...\n")

  # Use plot_track_gears function
  p <- plot_track_gears(
    season = SEASON,
    round = ROUND,
    driver = DRIVER,
    session = "R",
    color = "gear"
  )

  # Add custom styling
  p <- p + theme_high_contrast()

  cat("Step 2: Saving plot...\n")

  # Get race info for filename
  schedule <- load_schedule(season = SEASON)
  race_info <- schedule |> filter(round == ROUND)
  circuit_name <- race_info$circuit_name[1]

  # Save the plot
  plot_file <- file.path(
    OUTPUT_DIR,
    sprintf(
      "%s_track_gears_%d_race_%d_%s.png",
      DRIVER,
      SEASON,
      ROUND,
      tolower(gsub(" ", "_", circuit_name))
    )
  )

  ggsave(
    plot_file,
    p,
    width = 12,
    height = 8,
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
