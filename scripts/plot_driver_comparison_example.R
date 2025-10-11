#!/usr/bin/env Rscript
# Example: Side-by-side driver comparison using patchwork
# This script demonstrates plot_driver_comparison() for teammate analysis

# Load required packages
library(ggplot2)
library(patchwork)

# Source plotting functions
source("R/plot_functions.R")

# Configuration
season <- 2024
round <- 1 # Bahrain GP
driver1 <- "VER"
driver2 <- "PER"
output_file <- sprintf(
  "plots/driver_comparison_R%d_%s_vs_%s_%d.png",
  round,
  driver1,
  driver2,
  season
)

cat(sprintf(
  "Creating driver comparison for Round %d - %s vs %s\n",
  round,
  driver1,
  driver2
))

# Create comparison plot
p <- plot_driver_comparison(
  season = season,
  round = round,
  driver1 = driver1,
  driver2 = driver2,
  session = "R",
  color = "gear"
)

# Save plot
cat(sprintf("Saving plot to: %s\n", output_file))
ggsave(
  filename = output_file,
  plot = p,
  width = 14,
  height = 6,
  dpi = 300
)

cat("Done!\n")
