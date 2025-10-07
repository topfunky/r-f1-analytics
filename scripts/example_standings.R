#!/usr/bin/env Rscript
# Example script: Plot driver championship standings progression
# Demonstrates how to create season-long analysis visualizations

# Load required packages
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
})

# Configuration
SEASON <- 2024
CACHE_DIR <- "data/cache"
OUTPUT_DIR <- "plots"

# Create directories
dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

# Main execution
main <- function() {
  cat("\n")
  cat("===========================================\n")
  cat("F1 Championship Standings Progression\n")
  cat("===========================================\n")
  cat(sprintf("Season: %d\n", SEASON))
  cat("\n")

  tryCatch(
    {
      cat("Step 1: Generating example standings data...\n")

      # Create example standings data
      # In a real implementation, this would come from f1dataR
      set.seed(123)
      races <- 1:22
      drivers <- c("VER", "HAM", "LEC", "PER", "NOR", "SAI", "RUS", "ALO")

      # Simulate championship progression
      standings_data <- expand.grid(
        race = races,
        driver = drivers
      ) %>%
        arrange(driver, race) %>%
        group_by(driver) %>%
        mutate(
          # Simulate points accumulation
          race_points = case_when(
            driver == "VER" ~
              sample(
                c(25, 18, 15),
                size = n(),
                replace = TRUE,
                prob = c(0.6, 0.3, 0.1)
              ),
            driver == "HAM" ~
              sample(
                c(25, 18, 15, 12, 10),
                size = n(),
                replace = TRUE,
                prob = c(0.1, 0.3, 0.3, 0.2, 0.1)
              ),
            driver == "LEC" ~
              sample(
                c(25, 18, 15, 12, 10),
                size = n(),
                replace = TRUE,
                prob = c(0.15, 0.25, 0.3, 0.2, 0.1)
              ),
            TRUE ~
              sample(
                c(15, 12, 10, 8, 6, 4, 2, 1, 0),
                size = n(),
                replace = TRUE
              )
          ),
          total_points = cumsum(race_points)
        ) %>%
        ungroup()

      # Get top 5 drivers by final points
      top_drivers <- standings_data %>%
        filter(race == max(race)) %>%
        arrange(desc(total_points)) %>%
        head(5) %>%
        pull(driver)

      plot_data <- standings_data %>%
        filter(driver %in% top_drivers)

      cat("Step 2: Creating visualization...\n")

      # Create plot
      p <- ggplot(
        plot_data,
        aes(x = race, y = total_points, color = driver, group = driver)
      ) +
        geom_line(linewidth = 1.5, alpha = 0.8) +
        geom_point(size = 2.5, alpha = 0.7) +
        scale_x_continuous(breaks = seq(0, 22, by = 2)) +
        scale_color_brewer(palette = "Set1") +
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
          title = sprintf(
            "%d F1 Season - Championship Standings Progression",
            SEASON
          ),
          subtitle = "Top 5 drivers by cumulative points",
          x = "Race Number",
          y = "Total Championship Points",
          color = "Driver",
          caption = "Data: f1dataR | Ergast API | Example visualization"
        )

      cat("Step 3: Saving plot...\n")
      output_file <- file.path(
        OUTPUT_DIR,
        sprintf("standings_progression_%d.png", SEASON)
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

      # Also create a final standings table visualization
      cat("Step 4: Creating final standings table...\n")

      final_standings <- standings_data %>%
        filter(race == max(race), driver %in% top_drivers) %>%
        arrange(desc(total_points)) %>%
        mutate(position = row_number()) %>%
        select(position, driver, total_points)

      # Print to console
      cat("\nFinal Standings (Top 5):\n")
      print(final_standings, row.names = FALSE)

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
