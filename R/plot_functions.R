# F1 Track and Gears Plotting Functions

#' Plot track and gears for a single race
#'
#' @param season Integer, the F1 season year
#' @param round Integer, the race round number
#' @param driver String, three-letter driver code (e.g., "VER", "LEC")
#' @param session String, session type (default: "R" for race)
#' @param color String, what to color by (default: "gear")
#' @param add_labels Boolean, whether to add title/subtitle/caption (default: TRUE)
#' @return A ggplot object
plot_track_gears <- function(
  season,
  round,
  driver,
  session = "R",
  color = "gear",
  add_labels = TRUE
) {
  # Load required packages
  if (!require("f1dataR", quietly = TRUE)) {
    stop("Package 'f1dataR' is required but not installed")
  }
  if (!require("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required but not installed")
  }
  if (!require("dplyr", quietly = TRUE)) {
    stop("Package 'dplyr' is required but not installed")
  }

  # Get race information
  schedule <- f1dataR::load_schedule(season = season)

  if (is.null(schedule) || !is.data.frame(schedule) || nrow(schedule) == 0) {
    stop(sprintf("No schedule found for season %d", season))
  }

  race_info <- schedule |>
    filter(round == !!round)

  if (nrow(race_info) == 0) {
    stop(sprintf(
      "No race information found for season %d, round %d",
      season,
      round
    ))
  }

  race_name <- race_info$race_name[1]
  circuit_name <- race_info$circuit_name[1]

  # Create the plot using f1dataR's plot_fastest function
  p <- f1dataR::plot_fastest(
    season = season,
    round = round,
    driver = driver,
    session = session,
    color = color
  )

  # Add labels if requested
  if (add_labels) {
    p <- p +
      labs(
        title = sprintf("%s - Track and Gears Analysis", circuit_name),
        subtitle = sprintf(
          "%s (%s) - %s",
          race_name,
          driver,
          format(Sys.Date(), "%Y-%m-%d")
        ),
        caption = "Data: f1dataR | Ergast API"
      )
  }

  return(p)
}


#' Plot track and gears for all races in a season
#'
#' @param season Integer, the F1 season year
#' @param driver String, three-letter driver code (e.g., "VER", "LEC")
#' @param session String, session type (default: "R" for race)
#' @param color String, what to color by (default: "gear")
#' @return A ggplot object with faceted plots
plot_all_tracks_season <- function(
  season,
  driver,
  session = "R",
  color = "gear"
) {
  # Load required packages
  if (!require("f1dataR", quietly = TRUE)) {
    stop("Package 'f1dataR' is required but not installed")
  }
  if (!require("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required but not installed")
  }
  if (!require("dplyr", quietly = TRUE)) {
    stop("Package 'dplyr' is required but not installed")
  }
  if (!require("gghighcontrast", quietly = TRUE)) {
    stop("Package 'gghighcontrast' is required but not installed")
  }

  # Get schedule for the season
  schedule <- f1dataR::load_schedule(season = season)

  if (is.null(schedule) || !is.data.frame(schedule) || nrow(schedule) == 0) {
    stop(sprintf("No schedule found for season %d", season))
  }

  cat(sprintf(
    "Loading telemetry data for %d races in %d season...\n",
    nrow(schedule),
    season
  ))

  # Collect telemetry data for all rounds
  all_data <- list()

  for (i in 1:nrow(schedule)) {
    round_num <- schedule$round[i]
    circuit_name <- schedule$circuit_name[i]
    race_name <- schedule$race_name[i]

    cat(sprintf("  Loading Round %s: %s... ", round_num, circuit_name))

    # Load telemetry for this race
    # Allow errors to propagate naturally so they can be detected and fixed
    telemetry <- f1dataR::load_driver_telemetry(
      season = season,
      round = round_num,
      driver = driver,
      session = session,
      laps = "fastest"
    )

    if (!is.null(telemetry) && nrow(telemetry) > 0) {
      # Rename n_gear to gear for consistency
      if ("n_gear" %in% names(telemetry)) {
        telemetry$gear <- telemetry$n_gear
      }

      # Add race identification columns
      telemetry$round <- round_num
      telemetry$circuit_name <- circuit_name
      telemetry$race_name <- race_name
      telemetry$race_label <- sprintf("R%s: %s", round_num, circuit_name)

      all_data[[length(all_data) + 1]] <- telemetry
      cat("OK\n")
    } else {
      cat("No data\n")
    }
  }

  if (length(all_data) == 0) {
    stop(sprintf(
      "No telemetry data found for driver %s in season %d",
      driver,
      season
    ))
  }

  # Combine all data
  combined_data <- bind_rows(all_data)

  cat(sprintf("Creating faceted plot for %d races...\n", length(all_data)))

  # Create the faceted plot
  p <- ggplot(combined_data, aes(x = x, y = y, color = .data[[color]])) +
    geom_path(linewidth = 0.8) +
    facet_wrap(~race_label) +
    coord_fixed(ratio = 0.25) +
    labs(
      title = sprintf("%s - All Tracks (%d Season)", driver, season),
      subtitle = sprintf(
        "Track Maps with Gear Usage - %s",
        format(Sys.Date(), "%Y-%m-%d")
      ),
      caption = "Data: f1dataR | Ergast API",
      color = tools::toTitleCase(color)
    )

  # Apply high contrast theme
  p <- p +
    gghighcontrast::theme_high_contrast() +
    theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      strip.text = element_text(face = "bold", size = 9)
    )

  # Add color scale for gears if applicable
  if (color == "gear") {
    p <- p + scale_color_viridis_c(option = "plasma")
  }

  return(p)
}
