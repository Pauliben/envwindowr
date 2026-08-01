#' Rank the strongest environmental windows
#'
#' @description
#' Orders successful weather-window associations by the absolute value of their
#' correlation, separately for every weather-variable and trait combination.
#'
#' @param x An `env_window_scan` object or its `correlations` data frame.
#' @param n Number of windows retained per weather-variable/trait combination.
#' @param significant_only Keep only windows with adjusted p-values at or below
#'   `alpha`.
#' @param alpha Adjusted-p significance threshold.
#' @param min_pairs Optional additional minimum number of environments.
#'
#' @return A ranked tibble. `rank = 1` is the strongest retained association
#'   within a weather-variable/trait combination.
#'
#' @examples
#' dat <- simulate_env_window_data(n_environments = 16, n_days = 100,
#'                                 signal_start = 30, signal_end = 55)
#' fit <- scan_env_windows(
#'   dat$weather, dat$traits, dat$periods,
#'   weather_vars = "temperature", trait_vars = "yield",
#'   window_sizes = c(14, 28), step = 7, min_pairs = 8, quiet = TRUE
#' )
#' rank_env_windows(fit, n = 5)
#' rank_env_windows(fit, n = 5, significant_only = TRUE, alpha = 0.10)
#' @export
rank_env_windows <- function(x, n = 10L, significant_only = FALSE,
                             alpha = 0.05, min_pairs = NULL) {
  dat <- if (inherits(x, "env_window_scan")) x$correlations else x
  .assert_columns(dat, c("environmental_variable", "trait", "absolute_correlation",
                         "p_adjusted", "n_pairs", "status"), "Correlation results")
  dat <- dat |>
    dplyr::filter(.data$status == "ok")
  if (significant_only) dat <- dat |> dplyr::filter(.data$p_adjusted <= alpha)
  if (!is.null(min_pairs)) dat <- dat |> dplyr::filter(.data$n_pairs >= min_pairs)
  dat |>
    dplyr::group_by(.data$environmental_variable, .data$trait) |>
    dplyr::arrange(dplyr::desc(.data$absolute_correlation), .data$p_adjusted, .by_group = TRUE) |>
    dplyr::slice_head(n = as.integer(n)) |>
    dplyr::mutate(rank = dplyr::row_number(), .before = 1) |>
    dplyr::ungroup()
}

#' Diagnose scan quality and common failure modes
#'
#' @description
#' Summarizes result-status codes and flags design features that can make
#' environmental-window associations unstable or difficult to interpret.
#'
#' @param x An `env_window_scan` object returned by [scan_env_windows()].
#'
#' @details
#' The diagnostic is a screening aid, not a substitute for biological
#' validation, independent datasets, or an analysis that accounts for the
#' experimental design. Environmental windows selected from a small number of
#' environments can be highly unstable even when correlations are large.
#'
#' @return A list with the number of environments and windows, status counts,
#'   and plain-language warnings.
#'
#' @examples
#' dat <- simulate_env_window_data(n_environments = 12, n_days = 90)
#' fit <- scan_env_windows(
#'   dat$weather, dat$traits, dat$periods,
#'   weather_vars = "temperature", trait_vars = "yield",
#'   window_sizes = 21, step = 7, min_pairs = 5, quiet = TRUE
#' )
#' diagnose_env_scan(fit)
#' @export
diagnose_env_scan <- function(x) {
  if (!inherits(x, "env_window_scan")) .abort("`x` must be an env_window_scan object.")
  status_counts <- x$correlations |> dplyr::count(.data$status, sort = TRUE)
  n_env <- nrow(x$periods)
  warnings <- character()
  if (n_env < 5L) warnings <- c(warnings, "Fewer than five independent environments: correlations are highly unstable.")
  else if (n_env < 15L) warnings <- c(warnings, "Fewer than 15 independent environments: interpret selected windows cautiously.")
  if (any(x$correlations$mean_coverage < x$settings$min_coverage, na.rm = TRUE))
    warnings <- c(warnings, "Some windows have weather coverage below the requested threshold.")
  if (any(x$correlations$status == "zero_environmental_variance"))
    warnings <- c(warnings, "At least one weather-window summary is constant across environments.")
  if (any(x$correlations$status == "zero_trait_variance"))
    warnings <- c(warnings, "At least one trait is constant across environments.")
  if (!length(warnings)) warnings <- "No structural problems detected by the built-in checks."
  list(n_environments = n_env, n_windows = nrow(x$windows),
       status_counts = status_counts, warnings = warnings)
}
