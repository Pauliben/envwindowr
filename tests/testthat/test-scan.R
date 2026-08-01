test_that("simulation scan returns usable results", {
  d <- simulate_env_window_data(n_environments = 16, n_days = 120, signal_start = 40, signal_end = 70)
  fit <- scan_env_windows(d$weather, d$traits, d$periods,
                          weather_vars = "temperature", trait_vars = "yield",
                          window_sizes = c(21, 35), step = 7, min_pairs = 8, quiet = TRUE)
  expect_s3_class(fit, "env_window_scan")
  expect_true(any(fit$correlations$status == "ok"))
  expect_true(all(c("correlation", "p_adjusted", "mean_coverage") %in% names(fit$correlations)))
})

test_that("duplicate weather dates are rejected", {
  d <- simulate_env_window_data(
    n_environments = 8, n_days = 60,
    signal_start = 20, signal_end = 40
  )
  d$weather <- rbind(d$weather, d$weather[1, ])
  expect_error(scan_env_windows(d$weather, d$traits, d$periods,
                                "temperature", "yield", 14, min_pairs = 5, quiet = TRUE),
               "duplicate environment-date")
})

test_that("plot filtering uses function arguments", {
  d <- simulate_env_window_data(n_environments = 12, n_days = 90)
  fit <- scan_env_windows(d$weather, d$traits, d$periods,
                          c("temperature", "rainfall"), c("yield", "quality"),
                          window_sizes = 14, min_pairs = 5, quiet = TRUE)
  p <- plot_window_heatmap(fit, "temperature", "yield")
  expect_s3_class(p, "ggplot")
})
