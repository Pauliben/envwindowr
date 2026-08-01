# Plot a correlation heatmap across window starts and ends

Displays correlation coefficients for all candidate start and end
offsets for one weather-variable/trait combination.

## Usage

``` r
plot_window_heatmap(
  x,
  weather_var,
  trait,
  show_significance = TRUE,
  alpha = 0.05
)
```

## Arguments

- x:

  An \`env_window_scan\` object or correlation-results data frame.

- weather_var:

  Weather variable name exactly as supplied to \[scan_env_windows()\].

- trait:

  Trait name exactly as supplied to \[scan_env_windows()\].

- show_significance:

  Mark windows whose adjusted p-value is at or below \`alpha\` with an
  X.

- alpha:

  Adjusted-p threshold used when \`show_significance = TRUE\`.

## Value

A \`ggplot\` object that can be further customized with ggplot2.

## Examples

``` r
dat <- simulate_env_window_data(n_environments = 16, n_days = 100,
                                signal_start = 30, signal_end = 55)
fit <- scan_env_windows(
  dat$weather, dat$traits, dat$periods,
  weather_vars = "temperature", trait_vars = "yield",
  window_sizes = c(14, 28), step = 7, min_pairs = 8, quiet = TRUE
)
plot_window_heatmap(fit, "temperature", "yield")
```
