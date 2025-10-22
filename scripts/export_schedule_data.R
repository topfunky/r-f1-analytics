#!/usr/bin/env Rscript
# Export F1 Schedule Data to CSV
# Export schedule data from f1dataR API to CSV for examination

# Load required packages
suppressPackageStartupMessages({
  library(f1dataR)
  library(dplyr)
  library(tidyr)
  library(readr)
})

# Configuration
SEASONS <- c(2022, 2023, 2024)  # Multiple seasons for comparison
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
  cat("F1 Schedule Data Export\n")
  cat("==========================================================\n")
  
  all_schedules <- data.frame()
  
  for (season in SEASONS) {
    cat(sprintf("\nProcessing season %d...\n", season))
    
    # Fetch schedule data
    cache_file <- file.path(CACHE_DIR, sprintf("schedule_%d.rds", season))
    schedule <- fetch_with_cache(load_schedule, cache_file, season = season)
    
    # Add season column
    schedule <- schedule %>%
      mutate(season = season) %>%
      select(season, everything())
    
    all_schedules <- bind_rows(all_schedules, schedule)
    
    cat(sprintf("  Found %d races in %d season\n", nrow(schedule), season))
  }
  
  # Export to CSV
  output_csv <- file.path(OUTPUT_DIR, "f1_schedule_data.csv")
  write_csv(all_schedules, output_csv)
  cat(sprintf("\n✓ Schedule data exported to: %s\n", output_csv))
  
  # Print summary
  cat("\n==========================================================\n")
  cat("Schedule Data Summary:\n")
  cat("==========================================================\n")
  
  summary_stats <- all_schedules %>%
    group_by(season) %>%
    summarise(
      total_races = n(),
      races_with_dates = sum(!is.na(date)),
      races_with_times = sum(!is.na(time)),
      races_with_rounds = sum(!is.na(round)),
      .groups = "drop"
    )
  
  print(summary_stats, row.names = FALSE)
  
  # Show sample data
  cat("\nSample data (first 10 rows):\n")
  print(head(all_schedules, 10))
  
  # Check for missing values
  cat("\nMissing values analysis:\n")
  missing_summary <- all_schedules %>%
    summarise_all(~ sum(is.na(.))) %>%
    pivot_longer(everything(), names_to = "column", values_to = "missing_count") %>%
    mutate(missing_percentage = round(missing_count / nrow(all_schedules) * 100, 2)) %>%
    arrange(desc(missing_count))
  
  print(missing_summary, row.names = FALSE)
  
  cat("\n==========================================================\n")
  cat("Export complete!\n")
  cat("==========================================================\n")
}

# Run main function
main()