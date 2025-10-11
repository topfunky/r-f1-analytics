#!/usr/bin/env Rscript
# Example: Using patchwork with annotations and custom titles
# This script demonstrates plot_tracks_annotated() for early season races

# Load required packages
library(ggplot2)
library(patchwork)

# Source plotting functions
source("R/plot_functions.R")

# Configuration
season <- 2024
driver <- "LEC"
rounds <- 1:6 # First 6 races of the season
title <- sprintf("Early Season Performance - %s", driver)
subtitle <- sprintf("%d Season Opening Rounds", season)
output_file <- sprintf("plots/tracks_annotated_%s_%d.png", driver, season)

cat(sprintf("Creating annotated patchwork layout for %s\n", driver))
cat(sprintf("Rounds: %s\n", paste(rounds, collapse = ", ")))

# Create annotated plot with 3 columns
p <- plot_tracks_annotated(
  season = season,
  rounds = rounds,
  driver = driver,
  session = "R",
  color = "gear",
  title = title,
  subtitle = subtitle,
  ncol = 3
)

# Save plot
cat(sprintf("Saving plot to: %s\n", output_file))
ggsave(
  filename = output_file,
  plot = p,
  width = 14,
  height = 10,
  dpi = 300
)

cat("Done!\n")
