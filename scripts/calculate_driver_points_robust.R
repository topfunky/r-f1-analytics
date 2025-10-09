#!/usr/bin/env Rscript
# Calculate individual driver points using post-2010 scoring system (Robust Version)
# Generates CSV files with race-by-race and cumulative points for each driver
# Handles rate limiting and can resume from partial runs

# Load required packages
suppressPackageStartupMessages({
  library(f1dataR)
  library(dplyr)
  library(tidyr)
  library(readr)
})

# Configuration
START_YEAR <- 2020
END_YEAR <- 2022
CACHE_DIR <- "data/cache"
OUTPUT_DIR <- "plots"
MAX_RETRIES <- 3
RETRY_DELAY <- 2

# Post-2010 scoring system: 1st=25, 2nd=18, 3rd=15, 4th=12, 5th=10, 6th=8, 7th=6, 8th=4, 9th=2, 10th=1
SCORING_SYSTEM <- c(
  "1" = 25, "2" = 18, "3" = 15, "4" = 12, "5" = 10,
  "6" = 8, "7" = 6, "8" = 4, "9" = 2, "10" = 1
)

# Create directories
dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

# Function to fetch race results with retry logic
fetch_race_results_with_retry <- function(season, round, max_retries = MAX_RETRIES) {
  cache_file <- file.path(CACHE_DIR, sprintf("race_results_%s_%s.rds", as.character(season), as.character(round)))
  
  # Check cache first
  if (file.exists(cache_file)) {
    return(readRDS(cache_file))
  }
  
  # Try to fetch with retries
  for (attempt in 1:max_retries) {
    tryCatch({
      results <- load_results(season = season, round = round)
      
      # Check if we got valid data
      if (is.null(results) || !is.data.frame(results) || nrow(results) == 0) {
        if (attempt == max_retries) {
          return(NULL)
        }
        next
      }
      
      # Process and standardize the data
      processed_results <- results %>%
        mutate(
          season = as.integer(season),
          round = as.integer(round),
          position = as.integer(position),
          points = as.numeric(points),
          driver_id = as.character(driver_id),
          constructor_id = as.character(constructor_id)
        ) %>%
        select(season, round, driver_id, constructor_id, position, points, status)
      
      # Save to cache
      saveRDS(processed_results, cache_file)
      return(processed_results)
      
    }, error = function(e) {
      if (attempt == max_retries) {
        cat(sprintf("  Failed to fetch race %d after %d attempts: %s\n", round, max_retries, e$message))
        return(NULL)
      }
      cat(sprintf("  Attempt %d failed for race %d, retrying in %d seconds...\n", attempt, round, RETRY_DELAY))
      Sys.sleep(RETRY_DELAY)
    })
  }
  
  return(NULL)
}

# Function to get all races for a season with retry logic
get_season_races_with_retry <- function(season, max_retries = MAX_RETRIES) {
  cache_file <- file.path(CACHE_DIR, sprintf("season_races_%s.rds", as.character(season)))
  
  # Check cache first
  if (file.exists(cache_file)) {
    return(readRDS(cache_file))
  }
  
  # Try to fetch with retries
  for (attempt in 1:max_retries) {
    tryCatch({
      schedule <- load_schedule(season = season)
      
      if (is.null(schedule) || !is.data.frame(schedule) || nrow(schedule) == 0) {
        if (attempt == max_retries) {
          return(NULL)
        }
        next
      }
      
      # Get unique rounds
      races <- schedule %>%
        select(round) %>%
        distinct() %>%
        mutate(round = as.integer(round)) %>%
        arrange(round) %>%
        pull(round)
      
      # Save to cache
      saveRDS(races, cache_file)
      return(races)
      
    }, error = function(e) {
      if (attempt == max_retries) {
        cat(sprintf("  Failed to fetch schedule for season %d after %d attempts: %s\n", season, max_retries, e$message))
        return(NULL)
      }
      cat(sprintf("  Attempt %d failed for season %d schedule, retrying in %d seconds...\n", attempt, season, RETRY_DELAY))
      Sys.sleep(RETRY_DELAY)
    })
  }
  
  return(NULL)
}

# Function to get driver names with retry logic
get_driver_names_with_retry <- function(season, max_retries = MAX_RETRIES) {
  cache_file <- file.path(CACHE_DIR, sprintf("drivers_%s.rds", as.character(season)))
  
  # Check cache first
  if (file.exists(cache_file)) {
    return(readRDS(cache_file))
  }
  
  # Try to fetch with retries
  for (attempt in 1:max_retries) {
    tryCatch({
      drivers <- load_drivers(season = season)
      
      if (is.null(drivers) || !is.data.frame(drivers) || nrow(drivers) == 0) {
        if (attempt == max_retries) {
          return(NULL)
        }
        next
      }
      
      # Process driver data
      driver_names <- drivers %>%
        mutate(driver_name = paste(given_name, family_name)) %>%
        select(driver_id, driver_name) %>%
        distinct()
      
      # Save to cache
      saveRDS(driver_names, cache_file)
      return(driver_names)
      
    }, error = function(e) {
      if (attempt == max_retries) {
        cat(sprintf("  Failed to fetch drivers for season %d after %d attempts: %s\n", season, max_retries, e$message))
        return(NULL)
      }
      cat(sprintf("  Attempt %d failed for season %d drivers, retrying in %d seconds...\n", attempt, season, RETRY_DELAY))
      Sys.sleep(RETRY_DELAY)
    })
  }
  
  return(NULL)
}

# Function to get constructor names with retry logic
get_constructor_names_with_retry <- function(season, max_retries = MAX_RETRIES) {
  cache_file <- file.path(CACHE_DIR, sprintf("constructors_%s.rds", as.character(season)))
  
  # Check cache first
  if (file.exists(cache_file)) {
    return(readRDS(cache_file))
  }
  
  # Try to fetch with retries
  for (attempt in 1:max_retries) {
    tryCatch({
      constructors <- load_constructors()
      
      if (is.null(constructors) || !is.data.frame(constructors) || nrow(constructors) == 0) {
        if (attempt == max_retries) {
          return(NULL)
        }
        next
      }
      
      # Process constructor data
      constructor_names <- constructors %>%
        select(constructor_id, constructor_name = name) %>%
        distinct()
      
      # Save to cache
      saveRDS(constructor_names, cache_file)
      return(constructor_names)
      
    }, error = function(e) {
      if (attempt == max_retries) {
        cat(sprintf("  Failed to fetch constructors for season %d after %d attempts: %s\n", season, max_retries, e$message))
        return(NULL)
      }
      cat(sprintf("  Attempt %d failed for season %d constructors, retrying in %d seconds...\n", attempt, season, RETRY_DELAY))
      Sys.sleep(RETRY_DELAY)
    })
  }
  
  return(NULL)
}

# Function to apply post-2010 scoring system
apply_scoring_system <- function(position) {
  if (is.na(position) || position < 1 || position > 10) {
    return(0)
  }
  return(SCORING_SYSTEM[as.character(position)])
}

# Function to calculate driver points for a season
calculate_season_points <- function(season) {
  cat(sprintf("Processing season %d...\n", season))
  
  # Get all races for the season
  races <- get_season_races_with_retry(season)
  if (is.null(races) || length(races) == 0) {
    cat(sprintf("  No races found for season %d\n", season))
    return(NULL)
  }
  
  # Get driver and constructor names
  driver_names <- get_driver_names_with_retry(season)
  constructor_names <- get_constructor_names_with_retry(season)
  
  # Fetch all race results for the season
  all_race_results <- list()
  successful_races <- 0
  
  for (i in seq_along(races)) {
    round <- races[i]
    cat(sprintf("  Fetching race %d of %d...\r", i, length(races)))
    
    race_results <- fetch_race_results_with_retry(season, round)
    
    if (!is.null(race_results)) {
      all_race_results[[as.character(round)]] <- race_results
      successful_races <- successful_races + 1
    }
    
    # Add delay between requests to be nice to the API
    Sys.sleep(0.5)
  }
  cat("\n")
  
  if (length(all_race_results) == 0) {
    cat(sprintf("  No race results found for season %d\n", season))
    return(NULL)
  }
  
  cat(sprintf("  ✓ Successfully processed %d of %d races for season %d\n", successful_races, length(races), season))
  
  # Combine all race results
  combined_results <- bind_rows(all_race_results)
  
  # Apply post-2010 scoring system
  race_points <- combined_results %>%
    mutate(
      # Apply new scoring system based on position
      new_points = sapply(position, apply_scoring_system),
      # Keep original points for comparison
      original_points = points
    ) %>%
    # Add driver and constructor names
    left_join(driver_names, by = "driver_id") %>%
    left_join(constructor_names, by = "constructor_id") %>%
    # Handle missing names
    mutate(
      driver_name = ifelse(is.na(driver_name), driver_id, driver_name),
      constructor_name = ifelse(is.na(constructor_name), constructor_id, constructor_name)
    ) %>%
    select(
      season, round, driver_id, driver_name, constructor_id, constructor_name,
      position, original_points, new_points, status
    ) %>%
    arrange(round, position)
  
  return(race_points)
}

# Function to calculate cumulative points
calculate_cumulative_points <- function(race_points) {
  if (is.null(race_points) || nrow(race_points) == 0) {
    return(NULL)
  }
  
  cumulative_points <- race_points %>%
    group_by(season, driver_id, driver_name, constructor_id, constructor_name) %>%
    arrange(round) %>%
    mutate(
      cumulative_points = cumsum(new_points),
      cumulative_original_points = cumsum(original_points)
    ) %>%
    ungroup() %>%
    select(
      season, round, driver_id, driver_name, constructor_id, constructor_name,
      position, new_points, cumulative_points, original_points, cumulative_original_points
    ) %>%
    arrange(season, driver_id, round)
  
  return(cumulative_points)
}

# Main execution function
main <- function() {
  cat("\n")
  cat("===========================================================\n")
  cat("F1 Driver Points Calculator (Post-2010 Scoring System)\n")
  cat("Robust Version with Rate Limiting\n")
  cat("===========================================================\n")
  cat(sprintf("Analyzing seasons: %d - %d\n", START_YEAR, END_YEAR))
  cat("Scoring system: 25, 18, 15, 12, 10, 8, 6, 4, 2, 1\n")
  cat(sprintf("Max retries per request: %d\n", MAX_RETRIES))
  cat(sprintf("Retry delay: %d seconds\n", RETRY_DELAY))
  cat("\n")
  
  # Process all seasons
  all_race_points <- list()
  all_cumulative_points <- list()
  successful_seasons <- 0
  
  for (season in START_YEAR:END_YEAR) {
    cat(sprintf("\nProcessing season %d...\n", season))
    
    # Calculate race points for this season
    season_race_points <- calculate_season_points(season)
    
    if (!is.null(season_race_points)) {
      all_race_points[[as.character(season)]] <- season_race_points
      
      # Calculate cumulative points
      season_cumulative_points <- calculate_cumulative_points(season_race_points)
      if (!is.null(season_cumulative_points)) {
        all_cumulative_points[[as.character(season)]] <- season_cumulative_points
      }
      
      successful_seasons <- successful_seasons + 1
    } else {
      cat(sprintf("  ✗ No data available for season %d\n", season))
    }
  }
  
  # Check if we have any data
  if (length(all_race_points) == 0) {
    stop("No data could be processed for any season. Please check your internet connection and API availability.")
  }
  
  cat("\n")
  cat("===========================================================\n")
  cat("Generating CSV outputs...\n")
  cat("===========================================================\n")
  
  # Combine all race points
  combined_race_points <- bind_rows(all_race_points)
  combined_cumulative_points <- bind_rows(all_cumulative_points)
  
  # Save race-by-race points
  race_points_file <- file.path(OUTPUT_DIR, "driver_points_race_by_race.csv")
  write_csv(combined_race_points, race_points_file)
  cat(sprintf("✓ Race-by-race points saved to: %s\n", race_points_file))
  
  # Save cumulative points
  cumulative_points_file <- file.path(OUTPUT_DIR, "driver_points_cumulative.csv")
  write_csv(combined_cumulative_points, cumulative_points_file)
  cat(sprintf("✓ Cumulative points saved to: %s\n", cumulative_points_file))
  
  # Generate summary statistics
  cat("\n")
  cat("===========================================================\n")
  cat("Summary Statistics\n")
  cat("===========================================================\n")
  
  # Season summary
  season_summary <- combined_race_points %>%
    group_by(season) %>%
    summarise(
      races = n_distinct(round),
      drivers = n_distinct(driver_id),
      .groups = "drop"
    ) %>%
    arrange(season)
  
  cat("Seasons processed:\n")
  print(season_summary)
  
  # Top drivers by total points (new scoring system)
  top_drivers <- combined_cumulative_points %>%
    group_by(season, driver_id, driver_name, constructor_name) %>%
    summarise(
      total_points = max(cumulative_points),
      total_original_points = max(cumulative_original_points),
      races = n(),
      .groups = "drop"
    ) %>%
    group_by(season) %>%
    arrange(desc(total_points)) %>%
    slice_head(n = 3) %>%
    ungroup() %>%
    arrange(season, desc(total_points))
  
  cat("\nTop 3 drivers by total points (new scoring system) per season:\n")
  for (season in unique(top_drivers$season)) {
    season_data <- top_drivers %>% filter(season == season)
    cat(sprintf("\n%d:\n", season))
    for (i in 1:nrow(season_data)) {
      cat(sprintf("  %d. %s (%s) - %.0f points\n", 
                  i, season_data$driver_name[i], season_data$constructor_name[i], 
                  season_data$total_points[i]))
    }
  }
  
  # Overall statistics
  total_races <- nrow(combined_race_points)
  total_drivers <- n_distinct(combined_race_points$driver_id)
  seasons_processed <- n_distinct(combined_race_points$season)
  
  cat(sprintf("\nOverall Statistics:\n"))
  cat(sprintf("  Seasons processed: %d of %d\n", successful_seasons, END_YEAR - START_YEAR + 1))
  cat(sprintf("  Total races: %d\n", total_races))
  cat(sprintf("  Total drivers: %d\n", total_drivers))
  cat(sprintf("  Total race entries: %d\n", total_races))
  
  cat("\n")
  cat("===========================================================\n")
  cat("Analysis complete!\n")
  cat("===========================================================\n")
  cat("\n")
}

# Run main function
main()