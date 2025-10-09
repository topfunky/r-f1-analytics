#!/usr/bin/env Rscript
# Create visualizations of the driver points data

# Load required packages
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(readr)
  library(scales)
  library(gghighcontrast)
})

# Configuration
OUTPUT_DIR <- "plots"

# Read the data
race_points <- read_csv(file.path(OUTPUT_DIR, "driver_points_race_by_race.csv"))
cumulative_points <- read_csv(file.path(
  OUTPUT_DIR,
  "driver_points_cumulative.csv"
))

# Main visualization function
main <- function() {
  cat("\n")
  cat("===========================================================\n")
  cat("F1 Driver Points Visualizations\n")
  cat("===========================================================\n")
  cat("\n")

  # 1. Championship standings comparison (new vs original scoring)
  cat("Creating championship standings comparison...\n")

  # Get final standings for each season
  final_standings <- cumulative_points %>%
    group_by(season, driver_id, driver_name, constructor_name) %>%
    summarise(
      new_points = max(cumulative_points, na.rm = TRUE),
      original_points = max(cumulative_original_points, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    group_by(season) %>%
    arrange(desc(new_points)) %>%
    mutate(rank = row_number()) %>%
    ungroup()

  # Plot 1: Championship standings comparison
  p1 <- final_standings %>%
    filter(rank <= 10) %>%
    ggplot(aes(x = rank, y = new_points)) +
    geom_col(aes(fill = constructor_name), alpha = 0.8) +
    geom_text(aes(label = driver_name), angle = 90, hjust = -0.1, size = 3) +
    facet_wrap(~season, scales = "free_y") +
    scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
    labs(
      title = "F1 Championship Standings (Post-2010 Scoring System)",
      subtitle = "Top 10 drivers by total points",
      x = "Championship Position",
      y = "Total Points",
      fill = "Constructor"
    ) +
    theme_high_contrast() +
    theme(
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      legend.position = "bottom"
    )

  ggsave(
    file.path(OUTPUT_DIR, "championship_standings.png"),
    p1,
    width = 12,
    height = 8,
    dpi = 300
  )
  cat("✓ Championship standings plot saved\n")

  # 2. Points progression over season
  cat("Creating points progression plot...\n")

  # Get top 5 drivers for each season
  top_drivers <- final_standings %>%
    group_by(season) %>%
    slice_head(n = 5) %>%
    pull(driver_id)

  p2 <- cumulative_points %>%
    filter(driver_id %in% top_drivers) %>%
    ggplot(aes(x = round, y = cumulative_points, color = driver_name)) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    facet_wrap(~season, scales = "free_x") +
    labs(
      title = "Championship Points Progression",
      subtitle = "Top 5 drivers by season",
      x = "Race Number",
      y = "Cumulative Points",
      color = "Driver"
    ) +
    theme_high_contrast() +
    theme(legend.position = "bottom")

  ggsave(
    file.path(OUTPUT_DIR, "points_progression.png"),
    p2,
    width = 12,
    height = 8,
    dpi = 300
  )
  cat("✓ Points progression plot saved\n")

  # 3. Constructor comparison
  cat("Creating constructor comparison plot...\n")

  constructor_totals <- final_standings %>%
    group_by(season, constructor_name) %>%
    summarise(
      total_points = sum(new_points, na.rm = TRUE),
      drivers = n(),
      .groups = "drop"
    ) %>%
    group_by(season) %>%
    arrange(desc(total_points)) %>%
    slice_head(n = 8) %>%
    ungroup()

  p3 <- constructor_totals %>%
    ggplot(aes(x = reorder(constructor_name, total_points), y = total_points)) +
    geom_col(aes(fill = as.factor(season)), position = "dodge", alpha = 0.8) +
    coord_flip() +
    facet_wrap(~season, scales = "free_y") +
    labs(
      title = "Constructor Championship Points",
      subtitle = "Total points by constructor",
      x = "Constructor",
      y = "Total Points",
      fill = "Season"
    ) +
    theme_high_contrast() +
    theme(legend.position = "bottom")

  ggsave(
    file.path(OUTPUT_DIR, "constructor_comparison.png"),
    p3,
    width = 12,
    height = 8,
    dpi = 300
  )
  cat("✓ Constructor comparison plot saved\n")

  # 4. Scoring system comparison
  cat("Creating scoring system comparison plot...\n")

  p4 <- final_standings %>%
    filter(rank <= 10) %>%
    ggplot(aes(x = original_points, y = new_points)) +
    geom_point(aes(color = constructor_name), size = 3, alpha = 0.8) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
    geom_text(aes(label = driver_name), hjust = -0.1, vjust = 0.5, size = 3) +
    facet_wrap(~season) +
    labs(
      title = "Scoring System Comparison",
      subtitle = "Original vs New Scoring System (Top 10 drivers)",
      x = "Original Points",
      y = "New Points (Post-2010 System)",
      color = "Constructor"
    ) +
    theme_high_contrast() +
    theme(legend.position = "bottom")

  ggsave(
    file.path(OUTPUT_DIR, "scoring_comparison.png"),
    p4,
    width = 12,
    height = 8,
    dpi = 300
  )
  cat("✓ Scoring system comparison plot saved\n")

  # 5. Race-by-race points distribution
  cat("Creating race points distribution plot...\n")

  p5 <- race_points %>%
    filter(new_points > 0) %>%
    ggplot(aes(x = as.factor(new_points))) +
    geom_bar(aes(fill = as.factor(season)), position = "dodge", alpha = 0.8) +
    facet_wrap(~season) +
    scale_x_discrete(
      labels = c(
        "1" = "1st",
        "2" = "2nd",
        "3" = "3rd",
        "4" = "4th",
        "5" = "5th",
        "6" = "6th",
        "7" = "7th",
        "8" = "8th",
        "9" = "9th",
        "10" = "10th"
      )
    ) +
    labs(
      title = "Race Points Distribution",
      subtitle = "Number of times each points value was awarded",
      x = "Points Awarded",
      y = "Count",
      fill = "Season"
    ) +
    theme_high_contrast() +
    theme(legend.position = "bottom")

  ggsave(
    file.path(OUTPUT_DIR, "points_distribution.png"),
    p5,
    width = 12,
    height = 8,
    dpi = 300
  )
  cat("✓ Race points distribution plot saved\n")

  cat("\n")
  cat("===========================================================\n")
  cat("Visualizations complete!\n")
  cat("===========================================================\n")
  cat("\n")
  cat("Generated plots:\n")
  cat("  - championship_standings.png\n")
  cat("  - points_progression.png\n")
  cat("  - constructor_comparison.png\n")
  cat("  - scoring_comparison.png\n")
  cat("  - points_distribution.png\n")
  cat("\n")
}

# Run main function
main()
