# Plot top-ranked environmental windows

Creates a horizontal bar plot of the strongest absolute correlations
selected by \[rank_env_windows()\].

## Usage

``` r
plot_top_windows(x, weather_var = NULL, trait = NULL, n = 15L)
```

## Arguments

- x:

  An \`env_window_scan\` object or correlation-results data frame.

- weather_var:

  Optional weather-variable filter.

- trait:

  Optional phenotype-trait filter.

- n:

  Number of top windows retained per combination before filtering.

## Value

A faceted \`ggplot\` object.

## Examples

``` r
dat <- simulate_env_window_data(n_environments = 16, n_days = 100,
                                signal_start = 30, signal_end = 55)
fit <- scan_env_windows(
  dat$weather, dat$traits, dat$periods,
  "temperature", "yield", window_sizes = c(14, 28),
  step = 7, min_pairs = 8, quiet = TRUE
)
plot_top_windows(fit, weather_var = "temperature", trait = "yield", n = 8)
```
