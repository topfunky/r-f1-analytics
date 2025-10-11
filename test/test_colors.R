#!/usr/bin/env Rscript
# Test script for color utility functions
# Verifies that driver and team colors are working correctly

# Load required packages
suppressPackageStartupMessages({
  library(f1dataR)
  library(ggplot2)
  library(dplyr)
  library(gghighcontrast)
})

# Load color utility functions
source("scripts/color_utils.R")

# Configuration
OUTPUT_DIR <- "plots"

# Create output directory
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

# Main test function
main <- function() {
  cat("\n")
  cat("===========================================================\n")
  cat("Testing F1 Color Utility Functions\n")
  cat("===========================================================\n")
  cat("\n")

  # Test 1: Get driver colors
  cat("Test 1: Getting driver color mapping...\n")
  driver_colors <- get_driver_color_map(season = "current")
  cat(sprintf("✓ Found %d driver colors\n", length(driver_colors)))

  if (length(driver_colors) > 0) {
    cat("Sample driver colors:\n")
    sample_drivers <- head(driver_colors, 5)
    for (i in 1:length(sample_drivers)) {
      cat(sprintf("  %s: %s\n", names(sample_drivers)[i], sample_drivers[i]))
    }
  }

  # Test 2: Get team colors
  cat("\nTest 2: Getting team color mapping...\n")
  team_colors <- get_team_color_map(season = "current")
  cat(sprintf("✓ Found %d team colors\n", length(team_colors)))

  if (length(team_colors) > 0) {
    cat("Sample team colors:\n")
    sample_teams <- head(team_colors, 5)
    for (i in 1:length(sample_teams)) {
      cat(sprintf("  %s: %s\n", names(sample_teams)[i], sample_teams[i]))
    }
  }

  # Test 3: Test individual team color lookup
  cat("\nTest 3: Testing individual team color lookup...\n")
  test_teams <- c("Red Bull", "Ferrari", "Mercedes", "McLaren", "Aston Martin")

  for (team in test_teams) {
    color <- get_team_color(team, season = "current")
    cat(sprintf("  %s: %s\n", team, color))
  }

  # Test 4: Create a test visualization
  cat("\nTest 4: Creating test visualization...\n")

  # Create sample data
  sample_data <- data.frame(
    driver = c("VER", "LEC", "HAM", "NOR", "ALO"),
    team = c("Red Bull", "Ferrari", "Mercedes", "McLaren", "Aston Martin"),
    points = c(25, 18, 15, 12, 10),
    stringsAsFactors = FALSE
  )

  # Create driver points plot
  p1 <- sample_data %>%
    ggplot(aes(x = reorder(driver, points), y = points)) +
    geom_col(aes(fill = driver), alpha = 0.8) +
    coord_flip() +
    labs(
      title = "Test: Driver Colors",
      subtitle = "Sample driver points with official colors",
      x = "Driver",
      y = "Points",
      fill = "Driver"
    ) +
    theme_high_contrast() +
    theme(legend.position = "bottom")

  # Apply driver colors
  p1 <- apply_driver_colors(p1, season = "current", driver_col = "driver")

  # Save driver plot
  ggsave(
    file.path(OUTPUT_DIR, "test_driver_colors.png"),
    p1,
    width = 10,
    height = 6,
    dpi = 300
  )
  cat("✓ Driver colors test plot saved\n")

  # Create team points plot
  p2 <- sample_data %>%
    ggplot(aes(x = reorder(team, points), y = points)) +
    geom_col(aes(fill = team), alpha = 0.8) +
    coord_flip() +
    labs(
      title = "Test: Team Colors",
      subtitle = "Sample team points with official colors",
      x = "Team",
      y = "Points",
      fill = "Team"
    ) +
    theme_high_contrast() +
    theme(legend.position = "bottom")

  # Apply team colors
  p2 <- apply_team_colors(p2, season = "current", team_col = "team")

  # Save team plot
  ggsave(
    file.path(OUTPUT_DIR, "test_team_colors.png"),
    p2,
    width = 10,
    height = 6,
    dpi = 300
  )
  cat("✓ Team colors test plot saved\n")

  # Test 5: Test error handling
  cat("\nTest 5: Testing error handling...\n")

  # Test with invalid driver (should return default)
  driver_colors <- get_driver_color_map()
  invalid_driver_color <- driver_colors["INVALID"]
  if (is.na(invalid_driver_color)) {
    cat("Invalid driver color: Not found (as expected)\n")
  } else {
    cat(sprintf("Invalid driver color: %s\n", invalid_driver_color))
  }

  # Test with invalid team
  invalid_team_color <- get_team_color("Invalid Team")
  cat(sprintf("Invalid team color: %s\n", invalid_team_color))

  cat("\n")
  cat("===========================================================\n")
  cat("Color function tests complete!\n")
  cat("===========================================================\n")
  cat("\n")
  cat("Generated test plots:\n")
  cat("  - test_driver_colors.png\n")
  cat("  - test_team_colors.png\n")
  cat("\n")
}

# Run main function
main()
