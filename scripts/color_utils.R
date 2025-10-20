#!/usr/bin/env Rscript
# Color utility functions for F1 analytics
# Provides consistent driver and team colors using official F1 colors

# Load required packages
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
})

# Official F1 team colors (as of 2024)
F1_TEAM_COLORS <- c(
  "Red Bull" = "#1E41A9",
  "Ferrari" = "#DC143C",
  "Mercedes" = "#00D2BE",
  "McLaren" = "#FF8700",
  "Aston Martin" = "#006F62",
  "Alpine" = "#0090FF",
  "Williams" = "#005AFF",
  "AlphaTauri" = "#2B4562",
  "Alfa Romeo" = "#900000",
  "Haas" = "#FFFFFF",
  "Red Bull Racing" = "#1E41A9",
  "Scuderia Ferrari" = "#DC143C",
  "Mercedes-AMG" = "#00D2BE",
  "McLaren F1 Team" = "#FF8700",
  "Aston Martin F1 Team" = "#006F62",
  "Alpine F1 Team" = "#0090FF",
  "Williams Racing" = "#005AFF",
  "Scuderia AlphaTauri" = "#2B4562",
  "Alfa Romeo F1 Team" = "#900000",
  "Haas F1 Team" = "#FFFFFF"
)

# Official F1 driver colors (as of 2024)
F1_DRIVER_COLORS <- c(
  "VER" = "#1E41A9", # Red Bull
  "PER" = "#1E41A9", # Red Bull
  "LEC" = "#DC143C", # Ferrari
  "SAI" = "#DC143C", # Ferrari
  "HAM" = "#00D2BE", # Mercedes
  "RUS" = "#00D2BE", # Mercedes
  "NOR" = "#FF8700", # McLaren
  "PIA" = "#FF8700", # McLaren
  "ALO" = "#006F62", # Aston Martin
  "STR" = "#006F62", # Aston Martin
  "GAS" = "#0090FF", # Alpine
  "OCO" = "#0090FF", # Alpine
  "ALB" = "#005AFF", # Williams
  "SAR" = "#005AFF", # Williams
  "TSU" = "#2B4562", # AlphaTauri
  "RIC" = "#2B4562", # AlphaTauri
  "BOT" = "#900000", # Alfa Romeo
  "ZHO" = "#900000", # Alfa Romeo
  "MAG" = "#FFFFFF", # Haas
  "HUL" = "#FFFFFF" # Haas
)

# Cache for color mappings to avoid repeated API calls
.driver_color_cache <- NULL
.team_color_cache <- NULL

#' Get driver color mapping for a given season
#' @param season The F1 season year (default: current)
#' @param round The race round (default: 1)
#' @return Named vector with driver abbreviations as names and hex colors as values
get_driver_color_map <- function(season = "current", round = 1) {
  # Return the hardcoded driver colors
  return(F1_DRIVER_COLORS)
}

#' Get team color for a given constructor
#' @param constructor_name The constructor/team name
#' @param season The F1 season year (default: current)
#' @param round The race round (default: 1)
#' @return Hex color code for the team
get_team_color <- function(constructor_name, season = "current", round = 1) {
  # Look up team color in hardcoded colors
  if (constructor_name %in% names(F1_TEAM_COLORS)) {
    return(F1_TEAM_COLORS[constructor_name])
  }

  # Try fuzzy matching for common variations
  constructor_lower <- tolower(constructor_name)

  if (grepl("red bull", constructor_lower)) {
    return(F1_TEAM_COLORS["Red Bull"])
  } else if (grepl("ferrari", constructor_lower)) {
    return(F1_TEAM_COLORS["Ferrari"])
  } else if (grepl("mercedes", constructor_lower)) {
    return(F1_TEAM_COLORS["Mercedes"])
  } else if (grepl("mclaren", constructor_lower)) {
    return(F1_TEAM_COLORS["McLaren"])
  } else if (grepl("aston martin", constructor_lower)) {
    return(F1_TEAM_COLORS["Aston Martin"])
  } else if (grepl("alpine", constructor_lower)) {
    return(F1_TEAM_COLORS["Alpine"])
  } else if (grepl("williams", constructor_lower)) {
    return(F1_TEAM_COLORS["Williams"])
  } else if (
    grepl("alpha", constructor_lower) || grepl("tauri", constructor_lower)
  ) {
    return(F1_TEAM_COLORS["AlphaTauri"])
  } else if (grepl("alfa romeo", constructor_lower)) {
    return(F1_TEAM_COLORS["Alfa Romeo"])
  } else if (grepl("haas", constructor_lower)) {
    return(F1_TEAM_COLORS["Haas"])
  }

  # Default gray color if no match found
  warning(sprintf(
    "No color found for constructor '%s', using default gray",
    constructor_name
  ))
  return("#808080")
}

#' Get team color mapping for a given season
#' @param season The F1 season year (default: current)
#' @param round The race round (default: 1)
#' @return Named vector with team names as names and hex colors as values
get_team_color_map <- function(season = "current", round = 1) {
  # Return the hardcoded team colors
  return(F1_TEAM_COLORS)
}

#' Apply driver colors to a ggplot
#' @param plot A ggplot object
#' @param season The F1 season year (default: current)
#' @param round The race round (default: 1)
#' @param driver_col The column name containing driver codes/names
#' @return Updated ggplot with driver colors
apply_driver_colors <- function(
  plot,
  season = "current",
  round = 1,
  driver_col = "driver"
) {
  driver_colors <- get_driver_color_map(season, round)

  if (length(driver_colors) > 0) {
    plot <- plot +
      scale_color_manual(values = driver_colors, na.value = "#808080")
  }

  return(plot)
}

#' Apply team colors to a ggplot
#' @param plot A ggplot object
#' @param season The F1 season year (default: current)
#' @param round The race round (default: 1)
#' @param team_col The column name containing team/constructor names
#' @return Updated ggplot with team colors
apply_team_colors <- function(
  plot,
  season = "current",
  round = 1,
  team_col = "constructor_name"
) {
  team_colors <- get_team_color_map(season, round)

  if (length(team_colors) > 0) {
    plot <- plot + scale_fill_manual(values = team_colors, na.value = "#808080")
  }

  return(plot)
}

#' Clear color caches
#' Useful for testing or when data changes
clear_color_caches <- function() {
  .driver_color_cache <<- NULL
  .team_color_cache <<- NULL
}

# Export functions for use in other scripts
if (interactive()) {
  cat("Color utility functions loaded successfully!\n")
  cat("Available functions:\n")
  cat("  - get_driver_color_map(season)\n")
  cat("  - get_team_color(constructor_name, season)\n")
  cat("  - get_team_color_map(season)\n")
  cat("  - apply_driver_colors(plot, season, driver_col)\n")
  cat("  - apply_team_colors(plot, season, team_col)\n")
  cat("  - clear_color_caches()\n")
}
