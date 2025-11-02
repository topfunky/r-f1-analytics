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

# Helper function: Parse race time from gap column
parse_race_time <- function(gap_value) {
  if (is.na(gap_value)) {
    return(NA)
  }
  
  # Check if it's the winner's time (format: "H:MM:SS.sss")
  if (grepl("^\\d+:\\d{2}:\\d{2}\\.\\d+$", gap_value)) {
    # Parse winner's total race time
    parts <- strsplit(gap_value, ":")[[1]]
    hours <- as.numeric(parts[1])
    minutes <- as.numeric(parts[2])
    seconds <- as.numeric(parts[3])
    return(hours * 3600 + minutes * 60 + seconds)
  }
  
  # Check if it's a gap time in seconds (format: "+SS.sss" or "SS.sss")
  if (grepl("^\\+?\\d+\\.\\d+$", gap_value)) {
    # This is a gap in seconds - we'll need the winner's time to calculate total
    return(NA)  # Will be calculated later
  }
  
  # Check if it's a gap time in minutes:seconds (format: "+M:SS.sss")
  if (grepl("^\\+\\d+:\\d{2}\\.\\d+$", gap_value)) {
    # This is a gap in minutes:seconds - we'll need the winner's time to calculate total
    return(NA)  # Will be calculated later
  }
  
  return(NA)
}

# Helper function: Convert gap to seconds (vectorized)
gap_to_seconds <- function(gap_values) {
  sapply(gap_values, function(gap_value) {
    if (is.na(gap_value)) {
      return(NA)
    }
    
    # Handle gaps in seconds format (+SS.sss)
    if (grepl("^\\+?\\d+\\.\\d+$", gap_value)) {
      return(as.numeric(gsub("\\+", "", gap_value)))
    }
    
    # Handle gaps in minutes:seconds format (+M:SS.sss)
    if (grepl("^\\+\\d+:\\d{2}\\.\\d+$", gap_value)) {
      gap_parts <- strsplit(gsub("\\+", "", gap_value), ":")[[1]]
      gap_minutes <- as.numeric(gap_parts[1])
      gap_seconds <- as.numeric(gap_parts[2])
      return(gap_minutes * 60 + gap_seconds)
    }
    
    return(NA)
  })
}

# Helper function: Calculate total race time for all drivers
calculate_race_times <- function(results_df) {
  # Find winner's total time
  winner_gap <- results_df[results_df$position == "1", ]$gap[1]
  winner_time_sec <- parse_race_time(winner_gap)
  
  if (is.na(winner_time_sec)) {
    return(results_df)
  }
  
  # Calculate total race time for each driver
  results_df <- results_df |>
    mutate(
      gap_seconds = case_when(
        position == "1" ~ 0,  # Winner has no gap
        TRUE ~ gap_to_seconds(gap)
      ),
      total_race_time_sec = case_when(
        !is.na(gap_seconds) ~ winner_time_sec + gap_seconds,
        TRUE ~ NA_real_
      )
    ) |>
    select(-gap_seconds)  # Remove the helper column
  
  return(results_df)
}

# Function: Fetch race schedule data
fetch_race_schedule <- function(season) {
  cat("Step 1: Fetching race schedule...\n")
  cache_file <- file.path(CACHE_DIR, sprintf("schedule_%d.rds", season))
  schedule <- fetch_with_cache(load_schedule, cache_file, season = season)
  
  num_races <- nrow(schedule)
  cat(sprintf("  Found %d races in %d season\n", num_races, season))
  
  return(schedule)
}

# Function: Fetch all race results
fetch_all_race_results <- function(schedule, season) {
  cat("\nStep 2: Fetching race results for all races...\n")
  all_results <- data.frame()
  num_races <- nrow(schedule)
  
  for (i in 1:num_races) {
    round_num <- as.numeric(schedule$round[i])
    race_name <- schedule$race_name[i]
    
    cat(sprintf("  [%d/%d] Fetching results for %s (Round %d)...\n", 
                i, num_races, race_name, round_num))
    
    cache_file <- file.path(
      CACHE_DIR, 
      sprintf("results_%d_round%d.rds", season, round_num)
    )
    
    race_results <- fetch_with_cache(
      load_results, 
      cache_file, 
      season = season, 
      round = round_num
    )
    
    # Add race metadata
    race_results <- race_results |>
      mutate(
        round = round_num,
        race_name = race_name
      )
    
    all_results <- bind_rows(all_results, race_results)
  }
  
  cat(sprintf("  Successfully fetched results for %d races\n", num_races))
  return(all_results)
}

# Function: Calculate race times and time differences
calculate_race_time_differences <- function(all_results) {
  cat("\nStep 3: Calculating race time differences...\n")
  
  # Calculate total race times for all drivers
  all_results_with_times <- all_results |>
    filter(position <= 20) |>  # Only classified finishers
    group_by(round) |>
    group_modify(~ calculate_race_times(.x)) |>
    ungroup()
  
  # Prepare race results with total race time in seconds
  race_times <- all_results_with_times |>
    select(round, race_name, driver_id, position, total_race_time_sec) |>
    filter(!is.na(total_race_time_sec)) |>
    rename(time_seconds = total_race_time_sec)
  
  # Find the winner of each race (position 1) to calculate time behind
  race_winners <- race_times |>
    filter(position == 1) |>
    select(round, winner_time = time_seconds)
  
  # Calculate time behind winner for each race
  race_times_behind <- race_times |>
    left_join(race_winners, by = "round") |>
    mutate(
      time_behind = time_seconds - winner_time
    ) |>
    select(round, race_name, driver_id, position, time_behind)
  
  return(race_times_behind)
}

# Function: Calculate cumulative time differences
calculate_cumulative_times <- function(race_times_behind) {
  cat("\nStep 4: Calculating cumulative time differences...\n")
  
  # Calculate cumulative time differences
  cumulative_times <- race_times_behind |>
    arrange(driver_id, round) |>
    group_by(driver_id) |>
    mutate(
      cumulative_time_behind = cumsum(time_behind)
    ) |>
    ungroup()
  
  # Find the driver with minimum cumulative time (fastest overall)
  final_cumulative <- cumulative_times |>
    filter(round == max(round)) |>
    arrange(cumulative_time_behind)
  
  fastest_driver_id <- final_cumulative$driver_id[1]
  fastest_driver_time <- final_cumulative$cumulative_time_behind[1]
  
  cat(sprintf("  Fastest overall driver: %s\n", fastest_driver_id))
  cat(sprintf("  Total cumulative time: %.2f seconds\n", fastest_driver_time))
  
  # Calculate distance from fastest driver
  cumulative_distance <- cumulative_times |>
    arrange(driver_id, round) |>
    left_join(
      cumulative_times |>
        filter(driver_id == fastest_driver_id) |>
        select(round, fastest_cumulative = cumulative_time_behind),
      by = "round"
    ) |>
    mutate(
      distance_from_fastest = cumulative_time_behind - fastest_cumulative
    ) |>
    select(round, race_name, driver_id, cumulative_time_behind, distance_from_fastest)
  
  return(list(
    cumulative_distance = cumulative_distance,
    fastest_driver_id = fastest_driver_id,
    fastest_driver_time = fastest_driver_time
  ))
}

# Function: Create and export distance table
create_distance_table <- function(cumulative_distance) {
  cat("\nStep 5: Creating cumulative distance table...\n")
  
  distance_table <- cumulative_distance |>
    select(round, race_name, driver_id, distance_from_fastest) |>
    pivot_wider(
      names_from = driver_id,
      values_from = distance_from_fastest,
      names_prefix = ""
    ) |>
    arrange(round)
  
  # Save table as CSV
  output_csv <- file.path(OUTPUT_DIR, "2022_cumulative_time_distance.csv")
  write.csv(distance_table, output_csv, row.names = FALSE)
  cat(sprintf("✓ Table saved to: %s\n", output_csv))
  
  # Print table preview
  cat("\nTable Preview (first 5 races):\n")
  print(head(distance_table, 5))
  
  return(list(
    table = distance_table,
    output_csv = output_csv
  ))
}

# Function: Create visualization
create_visualization <- function(cumulative_distance, fastest_driver_id) {
  cat("\nStep 6: Creating visualization...\n")
  
  # Get top drivers to plot (those with most races)
  top_drivers <- cumulative_distance |>
    group_by(driver_id) |>
    summarise(races = n(), final_distance = max(distance_from_fastest)) |>
    arrange(races, final_distance) |>
    filter(races >= 15) |>  # At least 15 races
    head(10) |>
    pull(driver_id)
  
  plot_data <- cumulative_distance |>
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
  return(output_plot)
}

# Function: Print summary statistics
print_summary_statistics <- function(cumulative_distance) {
  cat("\n==========================================================\n")
  cat("Final Cumulative Time Distance (Top 10 Regular Drivers):\n")
  cat("==========================================================\n")
  
  final_summary <- cumulative_distance |>
    filter(round == max(round)) |>
    arrange(distance_from_fastest) |>
    mutate(
      position = row_number(),
      distance_minutes = distance_from_fastest / 60
    ) |>
    select(position, driver_id, distance_from_fastest, distance_minutes) |>
    head(10)
  
  print(final_summary, row.names = FALSE)
}

# Function: Print analysis completion message
print_completion_message <- function(output_csv, output_plot) {
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

# Main execution function
main <- function() {
  cat("\n")
  cat("==========================================================\n")
  cat("F1 2022 Season - Cumulative Time Distance Analysis\n")
  cat("==========================================================\n")
  cat(sprintf("Season: %d\n", SEASON))
  cat("\n")
  
  # Step 1: Fetch race schedule
  schedule <- fetch_race_schedule(SEASON)
  
  # Step 2: Fetch all race results
  all_results <- fetch_all_race_results(schedule, SEASON)
  
  # Step 3: Calculate race time differences
  race_times_behind <- calculate_race_time_differences(all_results)
  
  # Step 4: Calculate cumulative times
  cumulative_data <- calculate_cumulative_times(race_times_behind)
  cumulative_distance <- cumulative_data$cumulative_distance
  fastest_driver_id <- cumulative_data$fastest_driver_id
  
  # Step 5: Create distance table
  table_data <- create_distance_table(cumulative_distance)
  output_csv <- table_data$output_csv
  
  # Step 6: Create visualization
  output_plot <- create_visualization(cumulative_distance, fastest_driver_id)
  
  # Step 7: Print summary statistics
  print_summary_statistics(cumulative_distance)
  
  # Step 8: Print completion message
  print_completion_message(output_csv, output_plot)
}

# Run main function
main()
