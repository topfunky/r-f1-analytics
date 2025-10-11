#!/usr/bin/env Rscript
# Example: Advanced patchwork layouts with custom arrangements
# This script shows how to use patchwork operators for complex layouts

# Load required packages
library(ggplot2)
library(patchwork)

# Source plotting functions
source("R/plot_functions.R")

# Configuration
season <- 2024
driver <- "NOR"
output_file <- sprintf("plots/patchwork_advanced_%s_%d.png", driver, season)

cat(sprintf(
  "Creating advanced patchwork layout for %s - Season %d\n",
  driver,
  season
))

# Create individual plots for different circuits
cat("Loading telemetry data for selected races...\n")

p1 <- plot_track_gears(
  season = season,
  round = 1,
  driver = driver,
  add_labels = FALSE
) +
  ggplot2::labs(title = "R1: Bahrain")

p2 <- plot_track_gears(
  season = season,
  round = 3,
  driver = driver,
  add_labels = FALSE
) +
  ggplot2::labs(title = "R3: Australia")

p3 <- plot_track_gears(
  season = season,
  round = 5,
  driver = driver,
  add_labels = FALSE
) +
  ggplot2::labs(title = "R5: China")

p4 <- plot_track_gears(
  season = season,
  round = 7,
  driver = driver,
  add_labels = FALSE
) +
  ggplot2::labs(title = "R7: Canada")

p5 <- plot_track_gears(
  season = season,
  round = 9,
  driver = driver,
  add_labels = FALSE
) +
  ggplot2::labs(title = "R9: Spain")

# Create complex layout using patchwork operators
# Top row: 3 plots
# Bottom row: 2 plots centered
layout <- "
AAB
CDE
CDE
"

combined <- p1 +
  p2 +
  p3 +
  p4 +
  p5 +
  patchwork::plot_layout(design = layout) +
  patchwork::plot_annotation(
    title = sprintf("%s - Custom Track Layout Selection", driver),
    subtitle = sprintf("Selected races from %d season", season),
    caption = "Data: f1dataR | Ergast API\nLayout: patchwork",
    theme = ggplot2::theme(
      plot.title = ggplot2::element_text(size = 18, face = "bold"),
      plot.subtitle = ggplot2::element_text(size = 13),
      plot.caption = ggplot2::element_text(size = 9, hjust = 0)
    )
  )

# Save plot
cat(sprintf("Saving plot to: %s\n", output_file))
ggsave(
  filename = output_file,
  plot = combined,
  width = 16,
  height = 10,
  dpi = 300
)

cat("Done!\n")
