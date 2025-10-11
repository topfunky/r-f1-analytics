#!/usr/bin/env Rscript
# Plot track and gears in use for driver VER in 2022 race 10
# Uses the plot_fastest function from f1dataR package

# Load required packages
suppressPackageStartupMessages({
  library(f1dataR)
  library(ggplot2)
  library(dplyr)
  library(gghighcontrast)
})

# Configuration
SEASON <- 2022
ROUND <- 10
DRIVER <- "VER"
OUTPUT_DIR <- "plots"

# Create directories
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

# Function to get race information
get_race_info <- function(season, round) {
  # Load schedule for the season and filter for the specific round
  # Note: f1dataR handles caching automatically via .Rprofile configuration
  schedule <- load_schedule(season = season)

  if (is.null(schedule) || !is.data.frame(schedule) || nrow(schedule) == 0) {
    stop(sprintf("No schedule found for season %d", season))
  }

  race_info <- schedule %>%
    filter(round == round)

  if (nrow(race_info) == 0) {
    stop(sprintf(
      "No race information found for season %d, round %d",
      season,
      round
    ))
  }

  return(race_info)
}

# Main execution
main <- function() {
  cat("\n")
  cat("===========================================================\n")
  cat("F1 Track and Gears Analysis - VER 2022 Race 10\n")
  cat("===========================================================\n")
  cat(sprintf("Season: %d, Round: %d, Driver: %s\n", SEASON, ROUND, DRIVER))
  cat("\n")

  # Get race information
  cat("Step 1: Loading race information...\n")
  race_info <- get_race_info(SEASON, ROUND)
  race_name <- race_info$race_name[1]
  circuit_name <- race_info$circuit_name[1]

  cat(sprintf("✓ Race: %s at %s\n", race_name, circuit_name))

  cat("Step 2: Creating track and gears plot...\n")

  # Use plot_fastest function from f1dataR
  # This function creates a track map with gear usage visualization
  p <- plot_fastest(
    season = SEASON,
    round = ROUND,
    driver = DRIVER,
    session = "R", # Race session
    color = "gear" # Show gear usage
  )

  # Add custom styling
  p <- p +
    labs(
      title = sprintf("%s - Track and Gears Analysis", circuit_name),
      subtitle = sprintf(
        "%s (%s) - %s",
        race_name,
        DRIVER,
        format(Sys.Date(), "%Y-%m-%d")
      ),
      caption = "Data: f1dataR | Ergast API"
    ) +
    theme_high_contrast()

  # Save the plot
  plot_file <- file.path(
    OUTPUT_DIR,
    sprintf(
      "ver_track_gears_%d_race_%d_%s.png",
      SEASON,
      ROUND,
      tolower(gsub(" ", "_", circuit_name))
    )
  )

  ggsave(
    plot_file,
    p,
    width = 12,
    height = 8,
    dpi = 300
  )

  cat(sprintf("✓ Plot saved to: %s\n", plot_file))

  cat("\n")
  cat("===========================================================\n")
  cat("Analysis complete!\n")
  cat("===========================================================\n")
  cat("\n")
}

# Run main function
main()
