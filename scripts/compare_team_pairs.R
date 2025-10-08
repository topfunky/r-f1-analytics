#!/usr/bin/env Rscript
# Compare 2025 McLaren drivers with all historical team pairs since 1970
# Uses combined driver championship points for comparison

# Load required packages
suppressPackageStartupMessages({
  library(f1dataR)
  library(dplyr)
  library(tidyr)
})

# Configuration
START_YEAR <- 2003
END_YEAR <- 2025
CACHE_DIR <- "data/cache"
OUTPUT_DIR <- "plots"

# Create directories
dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

# Function to fetch driver standings for a season with caching
fetch_season_standings <- function(season) {
  cache_file <- file.path(CACHE_DIR, sprintf("standings_%d.rds", season))

  # Check cache first
  if (file.exists(cache_file)) {
    return(readRDS(cache_file))
  }

  # Fetch from f1dataR package
  # Load driver standings for the season
  # load_standings returns data with: season, round, driver_id, driver, constructor_id, constructor, position, points, wins
  standings <- load_standings(season = season)

  # Check if we got valid data
  if (is.null(standings) || !is.data.frame(standings) || nrow(standings) == 0) {
    return(NULL)
  }

  # Get only the final standings (last round) for the season
  # Check if round column exists, otherwise assume we already have final standings
  if ("round" %in% colnames(standings)) {
    final_standings <- standings %>%
      filter(round == max(round))
  } else {
    final_standings <- standings
  }

  # Standardize column names
  # f1dataR uses lowercase column names: driver, constructor, points, etc.
  # Need to handle both constructor and constructor_id columns
  result <- final_standings
  
  # Add season column if it doesn't exist
  if (!"season" %in% colnames(result)) {
    result$season <- season
  }
  
  # Rename constructor_id to team if constructor doesn't exist
  if ("constructor" %in% colnames(result)) {
    result$team <- result$constructor
  } else if ("constructor_id" %in% colnames(result)) {
    result$team <- result$constructor_id
  } else {
    stop(sprintf("No constructor column found in standings for season %d", season))
  }
  
  # Rename driver_id to driver if driver doesn't exist
  if (!"driver" %in% colnames(result)) {
    if ("driver_id" %in% colnames(result)) {
      result$driver <- result$driver_id
    } else {
      stop(sprintf("No driver column found in standings for season %d", season))
    }
  }
  
  result <- result %>%
    mutate(
      season = as.integer(season),
      points = as.numeric(points)
    ) %>%
    select(season, driver, team, points)

  # Save to cache
  saveRDS(result, cache_file)
  return(result)
}

# Main execution
main <- function() {
  cat("\n")
  cat("===========================================================\n")
  cat("F1 Team Pair Championship Analysis (1970-2025)\n")
  cat("===========================================================\n")
  cat(sprintf("Analyzing seasons: %d - %d\n", START_YEAR, END_YEAR))
  cat("\n")

  cat("Step 1: Fetching driver standings data...\n")

  # Fetch all seasons
  all_standings <- list()
  for (year in START_YEAR:END_YEAR) {
    cat(sprintf("  Fetching season %d...\r", year))
    standings <- fetch_season_standings(year)
    if (!is.null(standings)) {
      all_standings[[as.character(year)]] <- standings
    }
    # Small delay to be nice to the API
    Sys.sleep(0.1)
  }
  cat("\n")

  cat(sprintf(
    "✓ Successfully fetched data for %d seasons\n",
    length(all_standings)
  ))

  # Check if we have any data at all
  if (length(all_standings) == 0) {
    stop(
      "No data could be fetched for any season. Please check your internet connection and API availability."
    )
  }

  cat("Step 2: Processing team pairs...\n")

  # Combine all standings into one dataframe
  combined_standings <- bind_rows(all_standings)

  # The data already has the correct column names from our fetch function
  # We need: season, driver, team, points

  # Ensure season is integer and points is numeric
  final_standings <- combined_standings %>%
    mutate(
      season = as.integer(season),
      points = as.numeric(points)
    ) %>%
    select(season, driver, team, points) %>%
    # Remove any NA values
    filter(!is.na(driver), !is.na(team), !is.na(points))

  # Find teams with exactly 2 drivers (team pairs)
  team_pairs <- final_standings %>%
    group_by(season, team) %>%
    filter(n() == 2) %>%
    summarise(
      driver1 = first(driver),
      driver2 = last(driver),
      driver1_points = first(points),
      driver2_points = last(points),
      difference = driver1_points - driver2_points,
      combined_points = sum(points, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(combined_points))

  cat(sprintf(
    "✓ Found %d team pairs across all seasons\n",
    nrow(team_pairs)
  ))

  cat("Step 3: Identifying 2025 McLaren drivers...\n")

  # Find McLaren in 2025
  mclaren_2025 <- team_pairs %>%
    filter(season == 2025, grepl("mclaren", tolower(team)))

  if (nrow(mclaren_2025) == 0) {
    cat("⚠ Warning: No McLaren team pair found for 2025 season\n")
    cat(
      "   This may be because the season hasn't started or data is incomplete.\n"
    )
    mclaren_points <- NA
    mclaren_drivers <- "Not found"
  } else {
    mclaren_points <- mclaren_2025$combined_points[1]
    mclaren_drivers <- sprintf(
      "%s & %s",
      mclaren_2025$driver1[1],
      mclaren_2025$driver2[1]
    )
    cat(sprintf("✓ 2025 McLaren drivers: %s\n", mclaren_drivers))
    cat(sprintf("  Combined points: %.0f\n", mclaren_points))
  }

  cat("\nStep 4: Generating comparison table...\n")

  # Create formatted output table
  output_table <- team_pairs %>%
    mutate(
      rank = row_number(),
      drivers = sprintf("%s & %s", driver1, driver2),
      is_mclaren_2025 = (season == 2025 & grepl("mclaren", tolower(team)))
    ) %>%
    select(
      rank,
      season,
      team,
      driver1,
      driver2,
      driver1_points,
      driver2_points,
      difference,
      combined_points,
      is_mclaren_2025
    )

  # Print full table
  cat("\n")
  cat("===========================================================\n")
  cat("COMPLETE RANKING: ALL TEAM PAIRS BY COMBINED POINTS\n")
  cat("===========================================================\n")
  cat("\n")

  # Format and print table
  print(
    output_table %>%
      mutate(
        highlight = ifelse(is_mclaren_2025, " *** McLaren 2025 ***", "")
      ) %>%
      select(-is_mclaren_2025),
    n = Inf
  )

  # Summary statistics
  cat("\n")
  cat("===========================================================\n")
  cat("SUMMARY STATISTICS\n")
  cat("===========================================================\n")
  cat(sprintf("Total team pairs analyzed: %d\n", nrow(team_pairs)))
  cat(sprintf(
    "Seasons covered: %d - %d\n",
    min(team_pairs$season),
    max(team_pairs$season)
  ))
  cat(sprintf(
    "Highest combined points: %.0f\n",
    max(team_pairs$combined_points)
  ))
  cat(sprintf(
    "Lowest combined points: %.0f\n",
    min(team_pairs$combined_points)
  ))
  cat(sprintf(
    "Average combined points: %.1f\n",
    mean(team_pairs$combined_points)
  ))

  if (!is.na(mclaren_points)) {
    mclaren_rank <- which(output_table$is_mclaren_2025)[1]
    percentile <- (1 - (mclaren_rank / nrow(output_table))) * 100
    cat("\n")
    cat(sprintf(
      "2025 McLaren ranking: %d out of %d (%.1f percentile)\n",
      mclaren_rank,
      nrow(output_table),
      percentile
    ))
  }

  # Save results to CSV
  cat("\nStep 5: Saving results...\n")
  output_file <- file.path(OUTPUT_DIR, "team_pairs_comparison.csv")
  write.csv(
    output_table %>% select(-is_mclaren_2025),
    output_file,
    row.names = FALSE
  )
  cat(sprintf("✓ Results saved to: %s\n", output_file))

  cat("\n")
  cat("===========================================================\n")
  cat("Analysis complete!\n")
  cat("===========================================================\n")
  cat("\n")
}

# Run main function
main()
