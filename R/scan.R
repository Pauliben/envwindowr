#' Scan environmental windows for trait associations
#'
#' @description
#' Tests a sequence of candidate time windows to identify periods in which
#' summarized daily weather is associated with phenotypic traits across
#' environments. This is the main analysis function in `envwindowr`.
#'
#' @param weather Daily weather data with one row per environment and date.
#'   Required columns are the environment identifier, a date column, and the
#'   numeric columns named in `weather_vars`.
#' @param traits Phenotype data. A typical table contains `environment_id`,
#'   `genotype_id`, and one or more numeric trait columns. All phenotype rows
#'   within an environment are averaged before correlation. To analyze one
#'   genotype separately, filter `traits` to that genotype before calling this
#'   function.
#' @param periods Environment metadata with one row per environment and season
#'   start/end dates. Additional columns such as latitude, longitude, and
#'   altitude are allowed. The default date names are `start_date` and
#'   `end_date`; `season_start` and `season_end` are detected automatically.
#' @param weather_vars Character vector naming numeric weather columns to scan.
#' @param trait_vars Character vector naming numeric phenotype columns.
#' @param window_sizes Candidate window lengths, in days. One value performs a
#'   fixed-size scan; multiple values compare several temporal scales.
#' @param step Number of days between consecutive candidate window starts.
#' @param summaries One summary statistic recycled to all weather variables, or
#'   a named character vector/list mapping variables to statistics. Supported
#'   character values are `mean`, `sum`, `min`, `max`, `median`, and `sd`.
#' @param method Correlation method: `pearson`, `spearman`, or `kendall`.
#' @param min_pairs Minimum number of independent environments required for a
#'   correlation test.
#' @param p_adjust Multiple-testing adjustment method passed to
#'   [stats::p.adjust()].
#' @param environment_col,date_col,period_start_col,period_end_col Input column
#'   names.
#' @param start_offset First candidate day relative to each season start. Day 0
#'   is the season-start date.
#' @param end_offset Last day allowed in a candidate window. By default, the
#'   shortest season among environments determines the scan boundary.
#' @param min_coverage Minimum proportion of expected daily observations needed
#'   for an environment-window summary to be retained.
#' @param quiet Suppress progress messages.
#'
#' @details
#' **Window size** is the number of consecutive days summarized for each test.
#' For example, `window_sizes = 28` calculates one weather summary for every
#' 28-day candidate period. `window_sizes = c(14, 28, 42)` evaluates short,
#' medium, and long periods.
#'
#' **Step size** is controlled by `step` and determines how far the window moves
#' between tests. With a 28-day window and `step = 7`, the first windows are days
#' 0-27, 7-34, 14-41, and so on. A smaller step provides finer temporal
#' resolution but creates more tests and takes longer. A larger step is faster
#' but may miss narrow response periods.
#'
#' The independent unit is the environment or environment-year. Genotypes and
#' replicates within an environment do not increase the number of independent
#' weather observations. Consequently, the default analysis averages the
#' selected trait across all rows within each environment.
#'
#' @return An object of class `env_window_scan` containing:
#' 
#' * `correlations`: test results for every weather-trait-window combination;
#' * `windows`: candidate window definitions;
#' * `periods`: validated environment metadata;
#' * `trait_means`: environment-level phenotype means; and
#' * `settings`: analysis settings.
#'
#' @examples
#' dat <- simulate_env_window_data(
#'   n_environments = 18,
#'   n_days = 120,
#'   signal_start = 35,
#'   signal_end = 60
#' )
#'
#' fit <- scan_env_windows(
#'   weather = dat$weather,
#'   traits = dat$traits,
#'   periods = dat$periods,
#'   weather_vars = c("temperature", "rainfall"),
#'   trait_vars = c("yield", "quality"),
#'   window_sizes = c(14, 28),
#'   step = 7,
#'   summaries = c(temperature = "mean", rainfall = "sum"),
#'   min_pairs = 8,
#'   quiet = TRUE
#' )
#' fit
#' rank_env_windows(fit, n = 3)
#'
#' @importFrom rlang .data .env
#' @export
scan_env_windows <- function(weather, traits, periods, weather_vars, trait_vars,
                             window_sizes = 28L, step = 7L,
                             summaries = "mean", method = "pearson",
                             min_pairs = 5L, p_adjust = "BH",
                             environment_col = "environment_id", date_col = "date",
                             period_start_col = "start_date", period_end_col = "end_date",
                             start_offset = 0L, end_offset = NULL,
                             min_coverage = 0.8, quiet = FALSE) {
  method <- match.arg(method, c("pearson", "spearman", "kendall"))
  if (!is.numeric(min_coverage) || length(min_coverage) != 1L || min_coverage < 0 || min_coverage > 1)
    .abort("`min_coverage` must be between 0 and 1.")
  checked <- validate_env_inputs(weather, traits, periods, environment_col, date_col,
                                 period_start_col, period_end_col, weather_vars, trait_vars)
  windows <- make_env_windows(checked$periods, window_sizes, step, start_offset, end_offset,
                              checked$period_start_col, checked$period_end_col)
  trait_means <- checked$traits |>
    dplyr::group_by(.data[[environment_col]]) |>
    dplyr::summarise(dplyr::across(dplyr::all_of(trait_vars), .mean_na), .groups = "drop")
  results <- vector("list", nrow(windows))
  for (i in seq_len(nrow(windows))) {
    if (!quiet && (i == 1L || i %% 25L == 0L || i == nrow(windows)))
      message("Analyzing window ", i, " of ", nrow(windows), "...")
    w <- windows[i, , drop = FALSE]
    env_long <- summarize_window_weather(checked$weather, w, weather_vars, summaries, environment_col)
    env_long <- env_long |>
      dplyr::mutate(coverage = .data$n_weather_days / w$window_days,
                    environmental_value = dplyr::if_else(.data$coverage >= min_coverage,
                                                         .data$environmental_value, NA_real_)) |>
      dplyr::left_join(trait_means, by = environment_col)
    combos <- tidyr::crossing(environmental_variable = weather_vars, trait = trait_vars)
    one <- lapply(seq_len(nrow(combos)), function(j) {
      ev <- combos$environmental_variable[j]; tr <- combos$trait[j]
      dat <- env_long[env_long$environmental_variable == ev, , drop = FALSE]
      .safe_cor(dat$environmental_value, dat[[tr]], method, as.integer(min_pairs)) |>
        dplyr::mutate(environmental_variable = ev, trait = tr,
                      mean_coverage = mean(dat$coverage, na.rm = TRUE),
                      min_coverage_observed = min(dat$coverage, na.rm = TRUE), .before = 1)
    })
    results[[i]] <- dplyr::bind_rows(one) |>
      dplyr::mutate(window_id = w$window_id, start_offset = w$start_offset,
                    end_offset = w$end_offset, window_days = w$window_days, .before = 1)
  }
  correlations <- dplyr::bind_rows(results) |>
    dplyr::group_by(.data$environmental_variable, .data$trait) |>
    dplyr::mutate(p_adjusted = stats::p.adjust(.data$p_value, method = p_adjust),
                  absolute_correlation = abs(.data$correlation)) |>
    dplyr::ungroup()
  structure(list(correlations = correlations, windows = windows,
                 periods = checked$periods, trait_means = trait_means,
                 settings = list(weather_vars = weather_vars, trait_vars = trait_vars,
                                 summaries = summaries, method = method, min_pairs = min_pairs,
                                 p_adjust = p_adjust, min_coverage = min_coverage,
                                 window_sizes = window_sizes, step = step,
                                 period_start_col = checked$period_start_col,
                                 period_end_col = checked$period_end_col,
                                 environment_col = environment_col)),
            class = "env_window_scan")
}

#' Print an environmental-window scan summary
#'
#' @param x An `env_window_scan` object.
#' @param ... Additional arguments, currently ignored.
#' @return `x`, invisibly.
#' @rdname scan_env_windows
#' @export
print.env_window_scan <- function(x, ...) {
  cat("Environmental-window scan\n")
  cat("  Windows:", nrow(x$windows), "\n")
  cat("  Environments:", nrow(x$periods), "\n")
  cat("  Weather variables:", paste(x$settings$weather_vars, collapse = ", "), "\n")
  cat("  Traits:", paste(x$settings$trait_vars, collapse = ", "), "\n")
  cat("  Window size(s):", paste(x$settings$window_sizes, collapse = ", "), "days\n")
  cat("  Step:", x$settings$step, "days\n")
  ok <- sum(x$correlations$status == "ok")
  cat("  Successful tests:", ok, "of", nrow(x$correlations), "\n")
  invisible(x)
}
