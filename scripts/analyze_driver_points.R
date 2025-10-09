#!/usr/bin/env Rscript
# Analyze the generated driver points data
# Shows summary statistics and key insights

# Load required packages
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(tidyr)
})

# Configuration
OUTPUT_DIR <- "plots"

# Read the data
race_points <- read_csv(file.path(OUTPUT_DIR, "driver_points_race_by_race.csv"))
cumulative_points <- read_csv(file.path(OUTPUT_DIR, "driver_points_cumulative.csv"))

# Main analysis function
main <- function() {
  cat("\n")
  cat("===========================================================\n")
  cat("F1 Driver Points Analysis (Post-2010 Scoring System)\n")
  cat("===========================================================\n")
  cat("\n")
  
  # Data overview
  cat("Data Overview:\n")
  cat(sprintf("  Seasons: %s\n", paste(unique(race_points$season), collapse = ", ")))
  cat(sprintf("  Total races: %d\n", nrow(race_points)))
  cat(sprintf("  Total drivers: %d\n", n_distinct(race_points$driver_id)))
  cat(sprintf("  Total race entries: %d\n", nrow(race_points)))
  cat("\n")
  
  # Season-by-season summary
  cat("Season Summary:\n")
  season_summary <- race_points %>%
    group_by(season) %>%
    summarise(
      races = n_distinct(round),
      drivers = n_distinct(driver_id),
      total_race_entries = n(),
      .groups = "drop"
    ) %>%
    arrange(season)
  
  print(season_summary)
  cat("\n")
  
  # Top drivers by total points (new scoring system)
  cat("Top 10 Drivers by Total Points (New Scoring System):\n")
  top_drivers <- cumulative_points %>%
    group_by(season, driver_id, driver_name, constructor_name) %>%
    summarise(
      total_new_points = max(cumulative_points),
      total_original_points = max(cumulative_original_points),
      races = n(),
      .groups = "drop"
    ) %>%
    group_by(season) %>%
    arrange(desc(total_new_points)) %>%
    slice_head(n = 10) %>%
    ungroup() %>%
    arrange(season, desc(total_new_points))
  
  for (season in unique(top_drivers$season)) {
    season_data <- top_drivers %>% filter(season == season)
    cat(sprintf("\n%d Season:\n", season))
    for (i in 1:nrow(season_data)) {
      cat(sprintf("  %2d. %-20s (%s) - %3.0f points (original: %3.0f)\n", 
                  i, season_data$driver_name[i], season_data$constructor_name[i], 
                  season_data$total_new_points[i], season_data$total_original_points[i]))
    }
  }
  
  # Points distribution analysis
  cat("\n")
  cat("Points Distribution Analysis:\n")
  
  # Race-by-race points distribution
  points_dist <- race_points %>%
    group_by(season) %>%
    summarise(
      avg_points_per_race = mean(new_points, na.rm = TRUE),
      median_points_per_race = median(new_points, na.rm = TRUE),
      max_points_per_race = max(new_points, na.rm = TRUE),
      drivers_scoring_points = sum(new_points > 0, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(season)
  
  print(points_dist)
  
  # Constructor analysis
  cat("\n")
  cat("Constructor Performance (Total Points):\n")
  constructor_performance <- cumulative_points %>%
    group_by(season, constructor_name) %>%
    summarise(
      total_points = sum(max(cumulative_points), na.rm = TRUE),
      drivers = n_distinct(driver_id),
      .groups = "drop"
    ) %>%
    group_by(season) %>%
    arrange(desc(total_points)) %>%
    slice_head(n = 5) %>%
    ungroup() %>%
    arrange(season, desc(total_points))
  
  for (season in unique(constructor_performance$season)) {
    season_data <- constructor_performance %>% filter(season == season)
    cat(sprintf("\n%d Season:\n", season))
    for (i in 1:nrow(season_data)) {
      cat(sprintf("  %d. %-20s - %3.0f points (%d drivers)\n", 
                  i, season_data$constructor_name[i], 
                  season_data$total_points[i], season_data$drivers[i]))
    }
  }
  
  # Comparison with original scoring system
  cat("\n")
  cat("Scoring System Comparison:\n")
  scoring_comparison <- cumulative_points %>%
    group_by(season, driver_id, driver_name) %>%
    summarise(
      new_total = max(cumulative_points, na.rm = TRUE),
      original_total = max(cumulative_original_points, na.rm = TRUE),
      difference = new_total - original_total,
      .groups = "drop"
    ) %>%
    filter(new_total > 0) %>%
    arrange(desc(abs(difference)))
  
  cat("Top 10 drivers with biggest point differences:\n")
  top_differences <- scoring_comparison %>%
    slice_head(n = 10) %>%
    arrange(desc(difference))
  
  for (i in 1:nrow(top_differences)) {
    cat(sprintf("  %2d. %-20s: %+3.0f points (new: %3.0f, original: %3.0f)\n", 
                i, top_differences$driver_name[i], 
                top_differences$difference[i],
                top_differences$new_total[i],
                top_differences$original_total[i]))
  }
  
  # Race wins analysis
  cat("\n")
  cat("Race Wins Analysis:\n")
  race_wins <- race_points %>%
    filter(position == 1) %>%
    group_by(season, driver_name, constructor_name) %>%
    summarise(
      wins = n(),
      total_points = sum(new_points, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    group_by(season) %>%
    arrange(desc(wins), desc(total_points)) %>%
    slice_head(n = 5) %>%
    ungroup() %>%
    arrange(season, desc(wins))
  
  for (season in unique(race_wins$season)) {
    season_data <- race_wins %>% filter(season == season)
    cat(sprintf("\n%d Season:\n", season))
    for (i in 1:nrow(season_data)) {
      cat(sprintf("  %d. %-20s (%s) - %d wins, %3.0f points\n", 
                  i, season_data$driver_name[i], season_data$constructor_name[i], 
                  season_data$wins[i], season_data$total_points[i]))
    }
  }
  
  # Podium analysis
  cat("\n")
  cat("Podium Analysis (Top 3 finishes):\n")
  podiums <- race_points %>%
    filter(position <= 3) %>%
    group_by(season, driver_name, constructor_name) %>%
    summarise(
      podiums = n(),
      wins = sum(position == 1),
      second = sum(position == 2),
      third = sum(position == 3),
      total_points = sum(new_points, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    group_by(season) %>%
    arrange(desc(podiums), desc(total_points)) %>%
    slice_head(n = 5) %>%
    ungroup() %>%
    arrange(season, desc(podiums))
  
  for (season in unique(podiums$season)) {
    season_data <- podiums %>% filter(season == season)
    cat(sprintf("\n%d Season:\n", season))
    for (i in 1:nrow(season_data)) {
      cat(sprintf("  %d. %-20s (%s) - %d podiums (%dW, %d2nd, %d3rd), %3.0f points\n", 
                  i, season_data$driver_name[i], season_data$constructor_name[i], 
                  season_data$podiums[i], season_data$wins[i], season_data$second[i], season_data$third[i],
                  season_data$total_points[i]))
    }
  }
  
  cat("\n")
  cat("===========================================================\n")
  cat("Analysis complete!\n")
  cat("===========================================================\n")
  cat("\n")
  
  # Save summary statistics
  summary_file <- file.path(OUTPUT_DIR, "driver_points_summary.txt")
  sink(summary_file)
  cat("F1 Driver Points Analysis Summary\n")
  cat("================================\n\n")
  cat(sprintf("Data generated on: %s\n", Sys.time()))
  cat(sprintf("Seasons analyzed: %s\n", paste(unique(race_points$season), collapse = ", ")))
  cat(sprintf("Total races: %d\n", nrow(race_points)))
  cat(sprintf("Total drivers: %d\n", n_distinct(race_points$driver_id)))
  cat(sprintf("Scoring system: 25, 18, 15, 12, 10, 8, 6, 4, 2, 1\n"))
  sink()
  
  cat(sprintf("Summary saved to: %s\n", summary_file))
}

# Run main function
main()