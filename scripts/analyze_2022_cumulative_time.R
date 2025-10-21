#!/usr/bin/env Rscript
# Analysis: 2022 Season Cumulative Time Distance
# Calculate cumulative time difference between fastest overall driver and all other drivers
# across the 2022 F1 season

# Load required packages
suppressPackageStartupMessages({
  library(f1dataR)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(scales)
})

# Configuration
SEASON <- 2022
CACHE_DIR <- "data/cache"
OUTPUT_DIR <- "plots"

# Create directories if they don't exist
dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

# Helper function: Fetch data with caching
fetch_with_cache <- function(fetch_func, cache_file, ...) {
  if (file.exists(cache_file)) {
    message("  Using cached data from: ", cache_file)
    return(readRDS(cache_file))
  }
  
  message("  Fetching data from API...")
  data <- fetch_func(...)
  saveRDS(data, cache_file)
  message("  Data cached to: ", cache_file)
  return(data)
}

# Main execution
main <- function() {
  cat("\n")
  cat("==========================================================\n")
  cat("F1 2022 Season - Cumulative Time Distance Analysis\n")
  cat("==========================================================\n")
  cat(sprintf("Season: %d\n", SEASON))
  cat("\n")
  
  # Step 1: Fetch race schedule for 2022
  cat("Step 1: Fetching 2022 race schedule...\n")
  cache_file <- file.path(CACHE_DIR, sprintf("schedule_%d.rds", SEASON))
  schedule <- fetch_with_cache(load_schedule, cache_file, season = SEASON)
  
  num_races <- nrow(schedule)
  cat(sprintf("  Found %d races in %d season\n", num_races, SEASON))
  
  # Step 2: Fetch race results for all races
  cat("\nStep 2: Fetching race results for all races...\n")
  all_results <- data.frame()
  
  for (i in 1:num_races) {
    round_num <- as.numeric(schedule$round[i])
        race_name <- schedule$race_name[i]
        
        cat(sprintf("  [%d/%d] Fetching results for %s (Round %d)...\n", 
                    i, num_races, race_name, round_num))
        
    cache_file <- file.path(
      CACHE_DIR, 
      sprintf("results_%d_round%d.rds", SEASON, round_num)
    )
        
    race_results <- fetch_with_cache(
      load_results, 
      cache_file, 
      season = SEASON, 
      round = round_num
    )
    
    # Add race metadata
    race_results <- race_results %>%
      mutate(
        round = round_num,
        race_name = race_name
      )
    
    all_results <- bind_rows(all_results, race_results)
  }
  
  cat(sprintf("  Successfully fetched results for %d races\n", num_races))
  
  # Step 3: Calculate cumulative time differences
  cat("\nStep 3: Calculating cumulative time differences...\n")
  
  # Prepare race results with time in seconds
  race_times <- all_results %>%
    filter(position <= 20) %>%  # Only classified finishers
    select(round, race_name, driver_id, position, time_sec) %>%
    filter(!is.na(time_sec)) %>%
    rename(time_seconds = time_sec)
  
  # Find the winner of each race (position 1) to calculate time behind
  race_winners <- race_times %>%
    filter(position == 1) %>%
    select(round, winner_time = time_seconds)
  
  # Calculate time behind winner for each race
  race_times_behind <- race_times %>%
    left_join(race_winners, by = "round") %>%
    mutate(
      time_behind = time_seconds - winner_time
    ) %>%
    select(round, race_name, driver_id, position, time_behind)
  
  # Calculate cumulative time differences
  cumulative_times <- race_times_behind %>%
    arrange(driver_id, round) %>%
    group_by(driver_id) %>%
    mutate(
      cumulative_time_behind = cumsum(time_behind)
    ) %>%
    ungroup()
  
  # Find the driver with minimum cumulative time (fastest overall)
  final_cumulative <- cumulative_times %>%
    filter(round == max(round)) %>%
    arrange(cumulative_time_behind)
  
  fastest_driver_id <- final_cumulative$driver_id[1]
  fastest_driver_time <- final_cumulative$cumulative_time_behind[1]
  
  cat(sprintf("  Fastest overall driver: %s\n", fastest_driver_id))
  cat(sprintf("  Total cumulative time: %.2f seconds\n", fastest_driver_time))
  
  # Calculate distance from fastest driver
  cumulative_distance <- cumulative_times %>%
    arrange(driver_id, round) %>%
    left_join(
      cumulative_times %>%
        filter(driver_id == fastest_driver_id) %>%
        select(round, fastest_cumulative = cumulative_time_behind),
      by = "round"
    ) %>%
    mutate(
      distance_from_fastest = cumulative_time_behind - fastest_cumulative
    ) %>%
    select(round, race_name, driver_id, cumulative_time_behind, distance_from_fastest)
  
  # Step 4: Create wide format table
  cat("\nStep 4: Creating cumulative distance table...\n")
  
  distance_table <- cumulative_distance %>%
    select(round, race_name, driver_id, distance_from_fastest) %>%
    pivot_wider(
      names_from = driver_id,
      values_from = distance_from_fastest,
      names_prefix = ""
    ) %>%
    arrange(round)
  
  # Save table as CSV
  output_csv <- file.path(OUTPUT_DIR, "2022_cumulative_time_distance.csv")
  write.csv(distance_table, output_csv, row.names = FALSE)
  cat(sprintf("✓ Table saved to: %s\n", output_csv))
  
  # Print table preview
  cat("\nTable Preview (first 5 races):\n")
  print(head(distance_table, 5))
  
  # Step 5: Create visualization
  cat("\nStep 5: Creating visualization...\n")
  
  # Get top drivers to plot (those with most races)
  top_drivers <- cumulative_distance %>%
    group_by(driver_id) %>%
    summarise(races = n(), final_distance = max(distance_from_fastest)) %>%
    arrange(races, final_distance) %>%
    filter(races >= 15) %>%  # At least 15 races
    head(10) %>%
    pull(driver_id)
  
  plot_data <- cumulative_distance %>%
    filter(driver_id %in% top_drivers)
  
  # Create line plot
  p <- ggplot(
    plot_data,
    aes(x = round, y = distance_from_fastest, color = driver_id, group = driver_id)
  ) +
    geom_line(linewidth = 1.2, alpha = 0.8) +
    geom_point(size = 2, alpha = 0.6) +
    scale_x_continuous(breaks = seq(1, max(cumulative_distance$round), by = 2)) +
    scale_y_continuous(labels = scales::comma) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", size = 18),
      plot.subtitle = element_text(size = 12, color = "gray30"),
      plot.caption = element_text(size = 9, color = "gray50"),
      legend.position = "right",
      legend.title = element_text(face = "bold"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90")
    ) +
    labs(
      title = "F1 2022 Season - Cumulative Time Distance from Fastest Driver",
      subtitle = sprintf("All drivers compared to %s (fastest overall)", fastest_driver_id),
      x = "Race Number",
      y = "Cumulative Time Distance (seconds)",
      color = "Driver",
      caption = "Data: f1dataR | Ergast API"
    )
  
  output_plot <- file.path(OUTPUT_DIR, "2022_cumulative_time_distance.png")
  ggsave(
    filename = output_plot,
    plot = p,
    width = 14,
    height = 8,
    dpi = 300,
    bg = "white"
  )
  
  cat(sprintf("✓ Plot saved to: %s\n", output_plot))
  
  # Print summary statistics
  cat("\n==========================================================\n")
  cat("Final Cumulative Time Distance (Top 10 Regular Drivers):\n")
  cat("==========================================================\n")
  
  final_summary <- cumulative_distance %>%
    filter(round == max(round)) %>%
    arrange(distance_from_fastest) %>%
    mutate(
      position = row_number(),
      distance_minutes = distance_from_fastest / 60
    ) %>%
    select(position, driver_id, distance_from_fastest, distance_minutes) %>%
    head(10)
  
  print(final_summary, row.names = FALSE)
  
  cat("\n")
  cat("==========================================================\n")
  cat("Analysis complete!\n")
  cat("==========================================================\n")
  cat("\n")
  cat("Output files:\n")
  cat(sprintf("  - CSV table: %s\n", output_csv))
  cat(sprintf("  - Visualization: %s\n", output_plot))
  cat("\n")
}

# Run main function
main()
