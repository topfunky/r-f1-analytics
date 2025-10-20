# F1 Track and Gears Plotting Functions

# Helper Functions --------------------------------------------------------

#' Check if required packages are installed
#'
#' @param packages Character vector of package names to check
#' @return NULL (stops execution if packages are missing)
check_required_packages <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, quietly = TRUE, character.only = TRUE)) {
      stop(sprintf("Package '%s' is required but not installed", pkg))
    }
  }
}

#' Get race information from schedule
#'
#' @param season Integer, the F1 season year
#' @param round Integer, the race round number (optional)
#' @return Data frame with race information
get_race_info <- function(season, round = NULL) {
  schedule <- f1dataR::load_schedule(season = season)

  if (is.null(schedule) || !is.data.frame(schedule) || nrow(schedule) == 0) {
    stop(sprintf("No schedule found for season %d", season))
  }

  if (!is.null(round)) {
    schedule <- schedule |>
      dplyr::filter(round == !!round)

    if (nrow(schedule) == 0) {
      stop(sprintf(
        "No race information found for season %d, round %d",
        season,
        round
      ))
    }
  }

  return(schedule)
}

#' Load telemetry data for a single race
#'
#' @param season Integer, the F1 season year
#' @param round Integer, the race round number
#' @param driver String, three-letter driver code
#' @param session String, session type
#' @return Data frame with telemetry data or NULL if unavailable
load_race_telemetry <- function(season, round, driver, session) {
  telemetry <- f1dataR::load_driver_telemetry(
    season = season,
    round = round,
    driver = driver,
    session = session,
    laps = "fastest"
  )

  if (is.null(telemetry) || nrow(telemetry) == 0) {
    return(NULL)
  }

  # Rename n_gear to gear for consistency
  if ("n_gear" %in% names(telemetry)) {
    telemetry$gear <- telemetry$n_gear
  }

  return(telemetry)
}

#' Add race identification columns to telemetry data
#'
#' @param telemetry Data frame with telemetry data
#' @param round Integer, race round number
#' @param circuit_name String, circuit name
#' @param race_name String, race name
#' @return Data frame with additional identification columns
add_race_identifiers <- function(telemetry, round, circuit_name, race_name) {
  telemetry$round <- round
  telemetry$circuit_name <- circuit_name
  telemetry$race_name <- race_name
  telemetry$race_label <- sprintf("R%s: %s", round, circuit_name)
  return(telemetry)
}

#' Apply high contrast theme to plot
#'
#' @param p ggplot object
#' @return ggplot object with theme applied
add_high_contrast_theme <- function(p) {
  p +
    gghighcontrast::theme_high_contrast() +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold", size = 9)
    )
}

# Main Plotting Functions -------------------------------------------------

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
  check_required_packages(c("f1dataR", "ggplot2", "dplyr"))

  race_info <- get_race_info(season = season, round = round)
  race_name <- race_info$race_name[1]
  circuit_name <- race_info$circuit_name[1]

  p <- f1dataR::plot_fastest(
    season = season,
    round = round,
    driver = driver,
    session = session,
    color = color
  )

  if (add_labels) {
    p <- p +
      ggplot2::labs(
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


#' Collect telemetry data for all races in a season
#'
#' @param schedule Data frame with race schedule
#' @param season Integer, the F1 season year
#' @param driver String, three-letter driver code
#' @param session String, session type
#' @return Data frame with combined telemetry data
collect_season_telemetry <- function(schedule, season, driver, session) {
  cat(sprintf(
    "Loading telemetry data for %d races in %d season...\n",
    nrow(schedule),
    season
  ))

  combined_data <- schedule |>
    purrr::pmap_dfr(function(round, circuit_name, race_name, ...) {
      current_round <- as.numeric(round)
      cat(sprintf("  Loading Round %s: %s... ", current_round, circuit_name))

      telemetry <- load_race_telemetry(season, current_round, driver, session)

      if (!is.null(telemetry)) {
        telemetry <- add_race_identifiers(
          telemetry,
          current_round,
          circuit_name,
          race_name
        )
        cat("OK\n")
        return(telemetry)
      } else {
        cat("No data\n")
        return(NULL)
      }
    })

  if (is.null(combined_data) || nrow(combined_data) == 0) {
    stop(sprintf(
      "No telemetry data found for driver %s in season %d",
      driver,
      season
    ))
  }

  return(combined_data)
}

#' Prepare telemetry data for faceted plotting
#'
#' @param combined_data Data frame with combined telemetry
#' @return Data frame with ordered factors for faceting
prepare_facet_data <- function(combined_data) {
  combined_data$race_label <- factor(
    combined_data$race_label,
    levels = unique(combined_data$race_label[order(combined_data$round)])
  )
  return(combined_data)
}

#' Create base faceted track plot
#'
#' @param combined_data Data frame with telemetry data
#' @param color String, what to color by
#' @return ggplot object
create_faceted_plot <- function(combined_data, color) {
  ggplot2::ggplot(
    combined_data,
    ggplot2::aes(x = x, y = y, color = .data[[color]])
  ) +
    ggplot2::geom_path(linewidth = 0.8) +
    ggplot2::facet_wrap(~circuit_name) +
    ggplot2::coord_fixed()
}

#' Add labels to season plot
#'
#' @param p ggplot object
#' @param driver String, driver code
#' @param season Integer, season year
#' @param color String, color variable name
#' @return ggplot object with labels
add_season_labels <- function(p, driver, season, color) {
  p +
    ggplot2::labs(
      title = sprintf("%s - All Tracks (%d Season)", driver, season),
      subtitle = sprintf(
        "Track Maps with Gear Usage - %s",
        format(Sys.Date(), "%Y-%m-%d")
      ),
      caption = "Data: f1dataR | Ergast API",
      color = tools::toTitleCase(color)
    )
}

#' Plot track and gears for multiple races using patchwork
#'
#' @param season Integer, the F1 season year
#' @param rounds Integer vector, race round numbers to include
#' @param driver String, three-letter driver code (e.g., "VER", "LEC")
#' @param session String, session type (default: "R" for race)
#' @param color String, what to color by (default: "gear")
#' @param ncol Integer, number of columns for layout (default: NULL, auto)
#' @param nrow Integer, number of rows for layout (default: NULL, auto)
#' @return A patchwork composition of plots
plot_tracks_patchwork <- function(
  season,
  rounds,
  driver,
  session = "R",
  color = "gear",
  ncol = NULL,
  nrow = NULL
) {
  check_required_packages(c(
    "f1dataR",
    "ggplot2",
    "dplyr",
    "patchwork"
  ))

  plots <- lapply(rounds, function(r) {
    plot_track_gears(
      season = season,
      round = r,
      driver = driver,
      session = session,
      color = color,
      add_labels = FALSE
    )
  })

  # Combine using patchwork
  combined <- patchwork::wrap_plots(plots, ncol = ncol, nrow = nrow)

  return(combined)
}

#' Create a patchwork layout with shared title and annotations
#'
#' @param season Integer, the F1 season year
#' @param rounds Integer vector, race round numbers to include
#' @param driver String, three-letter driver code
#' @param session String, session type (default: "R")
#' @param color String, what to color by (default: "gear")
#' @param title String, main title (optional)
#' @param subtitle String, subtitle (optional)
#' @param ncol Integer, number of columns (default: NULL)
#' @param nrow Integer, number of rows (default: NULL)
#' @return A patchwork composition with annotations
plot_tracks_annotated <- function(
  season,
  rounds,
  driver,
  session = "R",
  color = "gear",
  title = NULL,
  subtitle = NULL,
  ncol = NULL,
  nrow = NULL
) {
  check_required_packages(c("patchwork"))

  p <- plot_tracks_patchwork(
    season = season,
    rounds = rounds,
    driver = driver,
    session = session,
    color = color,
    ncol = ncol,
    nrow = nrow
  )

  # Add default title if not provided
  if (is.null(title)) {
    title <- sprintf("%s - Track Maps (%d Season)", driver, season)
  }

  if (is.null(subtitle)) {
    subtitle <- sprintf("Rounds: %s", paste(rounds, collapse = ", "))
  }

  p <- p +
    patchwork::plot_annotation(
      title = title,
      subtitle = subtitle,
      caption = "Data: f1dataR | Ergast API",
      theme = ggplot2::theme(
        plot.title = ggplot2::element_text(size = 16, face = "bold"),
        plot.subtitle = ggplot2::element_text(size = 12),
        plot.caption = ggplot2::element_text(size = 9, hjust = 0)
      )
    )

  return(p)
}

#' Compare two drivers side by side using patchwork
#'
#' @param season Integer, the F1 season year
#' @param round Integer, race round number
#' @param driver1 String, first driver code
#' @param driver2 String, second driver code
#' @param session String, session type (default: "R")
#' @param color String, what to color by (default: "gear")
#' @return A patchwork composition comparing two drivers
plot_driver_comparison <- function(
  season,
  round,
  driver1,
  driver2,
  session = "R",
  color = "gear"
) {
  check_required_packages(c("patchwork"))

  p1 <- plot_track_gears(
    season = season,
    round = round,
    driver = driver1,
    session = session,
    color = color,
    add_labels = FALSE
  ) +
    ggplot2::labs(title = driver1)

  p2 <- plot_track_gears(
    season = season,
    round = round,
    driver = driver2,
    session = session,
    color = color,
    add_labels = FALSE
  ) +
    ggplot2::labs(title = driver2)

  race_info <- get_race_info(season = season, round = round)
  race_name <- race_info$race_name[1]
  circuit_name <- race_info$circuit_name[1]

  combined <- p1 +
    p2 +
    patchwork::plot_annotation(
      title = sprintf("%s - Driver Comparison", circuit_name),
      subtitle = sprintf("%s - %s", race_name, format(Sys.Date(), "%Y-%m-%d")),
      caption = "Data: f1dataR | Ergast API"
    )

  return(combined)
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
  check_required_packages(c(
    "f1dataR",
    "ggplot2",
    "dplyr",
    "gghighcontrast",
    "purrr"
  ))

  schedule <- get_race_info(season = season)

  combined_data <- collect_season_telemetry(schedule, season, driver, session)
  combined_data <- prepare_facet_data(combined_data)

  cat(sprintf(
    "\nCreating faceted plot for %d races...\n",
    length(unique(combined_data$round))
  ))

  p <- create_faceted_plot(combined_data, color)
  p <- add_season_labels(p, driver, season, color)
  p <- add_high_contrast_theme(p)

  return(p)
}
