.get_correlations <- function(x) if (inherits(x, "env_window_scan")) x$correlations else x

#' Plot a correlation heatmap across window starts and ends
#'
#' @description
#' Displays correlation coefficients for all candidate start and end offsets for
#' one weather-variable/trait combination.
#'
#' @param x An `env_window_scan` object or correlation-results data frame.
#' @param weather_var Weather variable name exactly as supplied to
#'   [scan_env_windows()].
#' @param trait Trait name exactly as supplied to [scan_env_windows()].
#' @param show_significance Mark windows whose adjusted p-value is at or below
#'   `alpha` with an X.
#' @param alpha Adjusted-p threshold used when `show_significance = TRUE`.
#'
#' @return A `ggplot` object that can be further customized with ggplot2.
#'
#' @examples
#' dat <- simulate_env_window_data(n_environments = 16, n_days = 100,
#'                                 signal_start = 30, signal_end = 55)
#' fit <- scan_env_windows(
#'   dat$weather, dat$traits, dat$periods,
#'   weather_vars = "temperature", trait_vars = "yield",
#'   window_sizes = c(14, 28), step = 7, min_pairs = 8, quiet = TRUE
#' )
#' plot_window_heatmap(fit, "temperature", "yield")
#' @export
plot_window_heatmap <- function(x, weather_var, trait, show_significance = TRUE, alpha = 0.05) {
  dat <- .get_correlations(x) |>
    dplyr::filter(.data$environmental_variable == .env$weather_var,
                  .data$trait == .env$trait)
  if (!nrow(dat)) .abort("No results found for weather variable '", weather_var, "' and trait '", trait, "'.")
  p <- ggplot2::ggplot(dat, ggplot2::aes(.data$start_offset, .data$end_offset, fill = .data$correlation)) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_gradient2(limits = c(-1, 1), midpoint = 0, na.value = "grey90") +
    ggplot2::coord_equal(expand = FALSE) +
    ggplot2::labs(title = paste(weather_var, "vs", trait), x = "Window start (day offset)",
                  y = "Window end (day offset)", fill = "Correlation") +
    ggplot2::theme_minimal() + ggplot2::theme(panel.grid = ggplot2::element_blank())
  if (show_significance) {
    sig <- dat |> dplyr::filter(.data$status == "ok", .data$p_adjusted <= alpha)
    if (nrow(sig)) p <- p + ggplot2::geom_point(data = sig, shape = 4, size = 1.4)
  }
  p
}

#' Plot top-ranked environmental windows
#'
#' @description
#' Creates a horizontal bar plot of the strongest absolute correlations selected
#' by [rank_env_windows()].
#'
#' @param x An `env_window_scan` object or correlation-results data frame.
#' @param weather_var Optional weather-variable filter.
#' @param trait Optional phenotype-trait filter.
#' @param n Number of top windows retained per combination before filtering.
#'
#' @return A faceted `ggplot` object.
#'
#' @examples
#' dat <- simulate_env_window_data(n_environments = 16, n_days = 100,
#'                                 signal_start = 30, signal_end = 55)
#' fit <- scan_env_windows(
#'   dat$weather, dat$traits, dat$periods,
#'   "temperature", "yield", window_sizes = c(14, 28),
#'   step = 7, min_pairs = 8, quiet = TRUE
#' )
#' plot_top_windows(fit, weather_var = "temperature", trait = "yield", n = 8)
#' @export
plot_top_windows <- function(x, weather_var = NULL, trait = NULL, n = 15L) {
  dat <- rank_env_windows(x, n = n)
  if (!is.null(weather_var)) dat <- dat |> dplyr::filter(.data$environmental_variable == .env$weather_var)
  if (!is.null(trait)) dat <- dat |> dplyr::filter(.data$trait == .env$trait)
  if (!nrow(dat)) .abort("No windows remain after filtering.")
  dat <- dat |> dplyr::mutate(window_label = paste0(.data$start_offset, "-", .data$end_offset, " d"))
  ggplot2::ggplot(dat, ggplot2::aes(stats::reorder(.data$window_label, .data$absolute_correlation),
                                    .data$absolute_correlation, fill = .data$correlation > 0)) +
    ggplot2::geom_col(show.legend = FALSE) + ggplot2::coord_flip() +
    ggplot2::facet_grid(.data$trait ~ .data$environmental_variable, scales = "free_y") +
    ggplot2::labs(x = "Window", y = "Absolute correlation") + ggplot2::theme_minimal()
}

#' Plot correlation by window start for one window size
#'
#' @description
#' Shows how the correlation changes as a fixed-length window moves through the
#' season. This is useful for checking whether a selected response period is
#' broad and stable or driven by one isolated start date.
#'
#' @param x An `env_window_scan` object or correlation-results data frame.
#' @param weather_var Weather variable name.
#' @param trait Trait name.
#' @param window_days Window length in days. It must have been included in
#'   `window_sizes` during the scan.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' dat <- simulate_env_window_data(n_environments = 16, n_days = 100,
#'                                 signal_start = 30, signal_end = 55)
#' fit <- scan_env_windows(
#'   dat$weather, dat$traits, dat$periods,
#'   "temperature", "yield", window_sizes = 28,
#'   step = 7, min_pairs = 8, quiet = TRUE
#' )
#' plot_window_profile(fit, "temperature", "yield", window_days = 28)
#' @export
plot_window_profile <- function(x, weather_var, trait, window_days) {
  dat <- .get_correlations(x) |>
    dplyr::filter(.data$environmental_variable == .env$weather_var,
                  .data$trait == .env$trait, .data$window_days == .env$window_days)
  if (!nrow(dat)) .abort("No matching profile results.")
  ggplot2::ggplot(dat, ggplot2::aes(.data$start_offset, .data$correlation)) +
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.3) + ggplot2::geom_line() + ggplot2::geom_point() +
    ggplot2::coord_cartesian(ylim = c(-1, 1)) +
    ggplot2::labs(title = paste(weather_var, "vs", trait), subtitle = paste(window_days, "day windows"),
                  x = "Window start (day offset)", y = "Correlation") + ggplot2::theme_minimal()
}

#' Plot phenotype against weather for a selected window
#'
#' @description
#' Recalculates one selected environmental-window summary and plots it against
#' an environment-level trait mean. A fitted linear regression is added as a
#' visual aid.
#'
#' @param weather Daily weather data.
#' @param traits Phenotype data. Rows are averaged within environment.
#' @param periods Environment metadata with season start and end dates.
#' @param weather_var One numeric weather variable.
#' @param trait One numeric phenotype trait.
#' @param start_offset,end_offset Selected window offsets relative to season
#'   start.
#' @param summary Summary statistic for the weather variable.
#' @param environment_col,date_col,period_start_col,period_end_col Input column
#'   names.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' dat <- simulate_env_window_data(n_environments = 16, n_days = 100,
#'                                 signal_start = 30, signal_end = 55)
#' plot_best_window_scatter(
#'   dat$weather, dat$traits, dat$periods,
#'   weather_var = "temperature", trait = "yield",
#'   start_offset = 28, end_offset = 55
#' )
#' @export
plot_best_window_scatter <- function(weather, traits, periods, weather_var, trait,
                                     start_offset, end_offset, summary = "mean",
                                     environment_col = "environment_id", date_col = "date",
                                     period_start_col = "start_date", period_end_col = "end_date") {
  checked <- validate_env_inputs(weather, traits, periods, environment_col, date_col,
                                 period_start_col, period_end_col, weather_var, trait)
  w <- tibble::tibble(start_offset = as.integer(start_offset), end_offset = as.integer(end_offset),
                      window_days = as.integer(end_offset - start_offset + 1L))
  env <- summarize_window_weather(checked$weather, w, weather_var,
                                  stats::setNames(summary, weather_var), environment_col)
  tr <- checked$traits |>
    dplyr::group_by(.data[[environment_col]]) |>
    dplyr::summarise(trait_value = .mean_na(.data[[trait]]), .groups = "drop")
  dat <- dplyr::left_join(env, tr, by = environment_col)
  ggplot2::ggplot(dat, ggplot2::aes(.data$environmental_value, .data$trait_value)) +
    ggplot2::geom_point() + ggplot2::geom_smooth(method = "lm", se = TRUE) +
    ggplot2::labs(title = paste(weather_var, "vs", trait),
                  subtitle = paste0("Days ", start_offset, "-", end_offset),
                  x = paste(summary, weather_var), y = trait) + ggplot2::theme_minimal()
}
