#!/usr/bin/env Rscript
# Example script: Plot lap times for a specific race
# This demonstrates the pattern for creating F1 analysis scripts

# Load required packages
suppressPackageStartupMessages({
  library(f1dataR)
  library(ggplot2)
  library(dplyr)
  library(tidyr)
})

# Configuration
SEASON <- 2024
RACE <- 1 # First race of the season
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

  tryCatch(
    {
      message("  Fetching data from API...")
      data <- fetch_func(...)
      saveRDS(data, cache_file)
      message("  Data cached to: ", cache_file)
      return(data)
    },
    error = function(e) {
      stop("Failed to fetch data: ", e$message)
    }
  )
}

# Main execution
main <- function() {
  cat("\n")
  cat("===========================================\n")
  cat("F1 Lap Times Analysis\n")
  cat("===========================================\n")
  cat(sprintf("Season: %d, Race: %d\n", SEASON, RACE))
  cat("\n")

  # Fetch race information
  cat("Step 1: Fetching race information...\n")
  cache_file <- file.path(
    CACHE_DIR,
    sprintf("race_info_%d_%d.rds", SEASON, RACE)
  )

  # Note: This is example code. Adjust based on actual f1dataR API
  # For now, create a simple example plot

  tryCatch(
    {
      # Example: Load lap times (adjust based on f1dataR actual functions)
      # laps <- fetch_with_cache(load_laps, cache_file, season = SEASON, race = RACE)

      # For demonstration purposes, create sample data
      set.seed(42)
      n_laps <- 50
      drivers <- c("VER", "HAM", "LEC", "NOR", "PER")

      lap_data <- expand.grid(
        lap = 1:n_laps,
        driver = drivers
      ) %>%
        mutate(
          lap_time = 90 +
            rnorm(n(), mean = 0, sd = 2) +
            (lap - 25)^2 / 100 + # Fuel effect
            ifelse(driver == "VER", -1, 0) # VER slightly faster
        )

      cat("Step 2: Creating visualization...\n")

      # Create plot
      p <- ggplot(
        lap_data,
        aes(x = lap, y = lap_time, color = driver, group = driver)
      ) +
        geom_line(linewidth = 1, alpha = 0.7) +
        geom_point(size = 1, alpha = 0.5) +
        scale_color_brewer(palette = "Set1") +
        theme_minimal(base_size = 14) +
        theme(
          plot.title = element_text(face = "bold", size = 18),
          plot.subtitle = element_text(size = 12, color = "gray30"),
          plot.caption = element_text(size = 9, color = "gray50"),
          legend.position = "right",
          panel.grid.minor = element_blank()
        ) +
        labs(
          title = sprintf(
            "%d Season - Race %d: Lap Time Analysis",
            SEASON,
            RACE
          ),
          subtitle = "Comparison of lap times throughout the race",
          x = "Lap Number",
          y = "Lap Time (seconds)",
          color = "Driver",
          caption = "Data: f1dataR | Ergast API | Example visualization"
        )

      cat("Step 3: Saving plot...\n")
      output_file <- file.path(
        OUTPUT_DIR,
        sprintf("lap_times_%d_race%d.png", SEASON, RACE)
      )

      ggsave(
        filename = output_file,
        plot = p,
        width = 12,
        height = 7,
        dpi = 300,
        bg = "white"
      )

      cat(sprintf("✓ Plot saved to: %s\n", output_file))
      cat("\n")
      cat("===========================================\n")
      cat("Analysis complete!\n")
      cat("===========================================\n")
      cat("\n")
    },
    error = function(e) {
      cat(sprintf("\n✗ Error: %s\n\n", e$message))
      quit(status = 1)
    }
  )
}

# Run main function
main()
