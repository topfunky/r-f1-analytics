#!/usr/bin/env Rscript
# Example: Using patchwork to create custom track layouts
# This script demonstrates plot_tracks_patchwork() with specific rounds

# Load required packages
library(ggplot2)
library(patchwork)

# Source plotting functions
source("R/plot_functions.R")

# Configuration
season <- 2022
driver <- "VER"
rounds <- c(1, 5, 10, 15) # Bahrain, China, Austria, Belgium
output_file <- sprintf("plots/tracks_patchwork_%s_%d.png", driver, season)

cat(sprintf("Creating patchwork layout for %s - Season %d\n", driver, season))
cat(sprintf("Rounds: %s\n", paste(rounds, collapse = ", ")))

# Create patchwork plot with 2x2 grid
p <- plot_tracks_patchwork(
  season = season,
  rounds = rounds,
  driver = driver,
  session = "R",
  color = "gear",
  ncol = 2,
  nrow = 2
)

# Save plot
cat(sprintf("Saving plot to: %s\n", output_file))
ggsave(
  filename = output_file,
  plot = p,
  width = 12,
  height = 12,
  dpi = 300
)

cat("Done!\n")
