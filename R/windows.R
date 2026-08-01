#' Create candidate environmental windows
#'
#' @description
#' Builds the sequence of candidate time windows evaluated by
#' [scan_env_windows()]. This function is useful for inspecting the analysis
#' design before running all weather-trait correlations.
#'
#' @param periods Environment table with season start and end dates.
#' @param window_sizes Integer window lengths in days. Use multiple values to
#'   compare different temporal scales.
#' @param step Number of days between consecutive candidate starts.
#' @param start_offset First candidate start relative to each environment's
#'   season start. Day 0 is the start date.
#' @param end_offset Last allowed day offset. Defaults to the final day of the
#'   shortest environment season.
#' @param period_start_col,period_end_col Season date column names. The
#'   `season_start`/`season_end` names are detected automatically when the
#'   defaults are absent.
#'
#' @details
#' A window size of 28 and a step of 7 produce overlapping windows: days 0-27,
#' 7-34, 14-41, and so forth. Reducing `step` increases temporal resolution and
#' the number of statistical tests. Increasing `step` reduces computation but
#' produces a coarser search.
#'
#' @return A tibble containing `window_id`, `start_offset`, `end_offset`, and
#'   `window_days`.
#'
#' @examples
#' periods <- data.frame(
#'   environment_id = c("2018_Waldo", "2019_Waldo"),
#'   season_start = c("2017-06-01", "2018-06-01"),
#'   season_end = c("2018-05-31", "2019-05-31")
#' )
#' make_env_windows(periods, window_sizes = c(14, 28), step = 7)
#' @export
make_env_windows <- function(periods, window_sizes = 28L, step = 7L,
                             start_offset = 0L, end_offset = NULL,
                             period_start_col = "start_date",
                             period_end_col = "end_date") {
  resolved <- .resolve_period_columns(periods, period_start_col, period_end_col)
  period_start_col <- resolved$start
  period_end_col <- resolved$end
  .assert_columns(periods, c(period_start_col, period_end_col), "Period data")
  window_sizes <- unique(as.integer(window_sizes)); step <- as.integer(step)
  start_offset <- as.integer(start_offset)
  if (anyNA(window_sizes) || any(window_sizes < 1L)) .abort("`window_sizes` must contain positive integers.")
  if (is.na(step) || step < 1L) .abort("`step` must be a positive integer.")
  starts <- .as_date_strict(periods[[period_start_col]], "Period start column")
  ends <- .as_date_strict(periods[[period_end_col]], "Period end column")
  lengths <- as.integer(ends - starts) + 1L
  common_days <- min(lengths)
  end_offset <- as.integer(end_offset %||% (common_days - 1L))
  if (start_offset < 0L || end_offset < start_offset) .abort("Invalid start/end offsets.")
  pieces <- lapply(window_sizes, function(size) {
    last_start <- end_offset - size + 1L
    if (last_start < start_offset) return(NULL)
    starts <- seq.int(start_offset, last_start, by = step)
    if (!length(starts)) return(NULL)
    tibble::tibble(start_offset = starts, end_offset = starts + size - 1L, window_days = size)
  })
  out <- dplyr::bind_rows(pieces) |>
    dplyr::filter(.data$end_offset <= end_offset) |>
    dplyr::arrange(.data$window_days, .data$start_offset) |>
    dplyr::mutate(window_id = dplyr::row_number(), .before = 1)
  if (!nrow(out)) .abort("No candidate windows fit the requested period and window sizes.")
  out
}

#' Summarize daily weather for one candidate window
#'
#' @description
#' Calculates environment-level weather summaries for one candidate window.
#' This is a lower-level function used internally by [scan_env_windows()].
#'
#' @param weather Validated weather table containing the internal `.day_offset`
#'   column created by [validate_env_inputs()].
#' @param window A one-row window table, usually one row from
#'   [make_env_windows()].
#' @param weather_vars Character vector of weather variables.
#' @param summaries Named character vector/list mapping variables to statistics,
#'   or one statistic recycled to all variables. Supported values are `mean`,
#'   `sum`, `min`, `max`, `median`, and `sd`; a function may also be supplied.
#' @param environment_col Environment identifier column.
#'
#' @return One row per environment and weather variable in long format, with
#'   `environmental_value` and `n_weather_days` columns.
#'
#' @examples
#' dat <- simulate_env_window_data(n_environments = 6, n_days = 60,
#'                                 signal_start = 15, signal_end = 30)
#' checked <- validate_env_inputs(
#'   dat$weather, dat$traits, dat$periods,
#'   weather_vars = c("temperature", "rainfall"),
#'   trait_vars = "yield"
#' )
#' windows <- make_env_windows(checked$periods, window_sizes = 14, step = 7)
#' summarize_window_weather(
#'   checked$weather,
#'   windows[1, ],
#'   weather_vars = c("temperature", "rainfall"),
#'   summaries = c(temperature = "mean", rainfall = "sum")
#' )
#' @export
summarize_window_weather <- function(weather, window, weather_vars,
                                     summaries = "mean",
                                     environment_col = "environment_id") {
  if (length(summaries) == 1L && is.null(names(summaries))) summaries <- rep(summaries, length(weather_vars))
  if (is.null(names(summaries))) names(summaries) <- weather_vars
  missing_specs <- setdiff(weather_vars, names(summaries))
  if (length(missing_specs)) .abort("Missing summary statistic for: ", paste(missing_specs, collapse = ", "), ".")
  selected <- weather |>
    dplyr::filter(.data$.day_offset >= window$start_offset,
                  .data$.day_offset <= window$end_offset)
  dplyr::bind_rows(lapply(weather_vars, function(variable) {
    selected |>
      dplyr::group_by(.data[[environment_col]]) |>
      dplyr::summarise(environmental_value = .safe_stat(.data[[variable]], summaries[[variable]]),
                       n_weather_days = sum(is.finite(.data[[variable]])), .groups = "drop") |>
      dplyr::mutate(environmental_variable = variable, .before = 2)
  }))
}
