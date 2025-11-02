#!/usr/bin/env Rscript
# Export F1 Race Results Data to CSV
# Export race results data from f1dataR API to CSV for examination

# Load required packages
suppressPackageStartupMessages({
  library(f1dataR)
  library(dplyr)
  library(readr)
  library(tidyr)
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
  cat("F1 Race Results Data Export\n")
  cat("==========================================================\n")
  cat(sprintf("Season: %d\n", SEASON))
  cat("\n")
  
  # Step 1: Fetch race schedule for 2022
  cat("Step 1: Fetching race schedule...\n")
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
    race_results <- race_results |>
      mutate(
        round = round_num,
        race_name = race_name
      )
    
    all_results <- bind_rows(all_results, race_results)
  }
  
  cat(sprintf("  Successfully fetched results for %d races\n", num_races))
  
  # Export to CSV
  output_csv <- file.path(OUTPUT_DIR, "f1_race_results_data.csv")
  write_csv(all_results, output_csv)
  cat(sprintf("\n✓ Race results data exported to: %s\n", output_csv))
  
  # Print summary
  cat("\n==========================================================\n")
  cat("Race Results Data Summary:\n")
  cat("==========================================================\n")
  
  # Basic stats
  cat(sprintf("Total records: %d\n", nrow(all_results)))
  cat(sprintf("Unique drivers: %d\n", n_distinct(all_results$driver_id)))
  cat(sprintf("Unique races: %d\n", n_distinct(all_results$round)))
  
  # Missing values analysis
  cat("\nMissing values analysis:\n")
  missing_summary <- all_results |>
    summarise_all(~ sum(is.na(.))) |>
    pivot_longer(everything(), names_to = "column", values_to = "missing_count") |>
    mutate(missing_percentage = round(missing_count / nrow(all_results) * 100, 2)) |>
    arrange(desc(missing_count))
  
  print(missing_summary, row.names = FALSE)
  
  # Gap column analysis (this is where NA values likely come from)
  cat("\nGap column analysis:\n")
  gap_analysis <- all_results |>
    group_by(round, race_name) |>
    summarise(
      total_drivers = n(),
      drivers_with_gap = sum(!is.na(gap)),
      drivers_without_gap = sum(is.na(gap)),
      gap_missing_pct = round(sum(is.na(gap)) / n() * 100, 2),
      .groups = "drop"
    ) |>
    arrange(desc(gap_missing_pct))
  
  print(gap_analysis, row.names = FALSE)
  
  # Sample of gap values
  cat("\nSample gap values:\n")
  gap_samples <- all_results |>
    select(round, race_name, position, driver_id, gap) |>
    filter(!is.na(gap)) |>
    head(20)
  
  print(gap_samples, row.names = FALSE)
  
  # Sample of missing gap values
  cat("\nSample missing gap values:\n")
  missing_gap_samples <- all_results |>
    select(round, race_name, position, driver_id, gap, status) |>
    filter(is.na(gap)) |>
    head(20)
  
  print(missing_gap_samples, row.names = FALSE)
  
  cat("\n==========================================================\n")
  cat("Export complete!\n")
  cat("==========================================================\n")
}

# Run main function
main()