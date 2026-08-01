# Plot correlation by window start for one window size

Shows how the correlation changes as a fixed-length window moves through
the season. This is useful for checking whether a selected response
period is broad and stable or driven by one isolated start date.

## Usage

``` r
plot_window_profile(x, weather_var, trait, window_days)
```

## Arguments

- x:

  An \`env_window_scan\` object or correlation-results data frame.

- weather_var:

  Weather variable name.

- trait:

  Trait name.

- window_days:

  Window length in days. It must have been included in \`window_sizes\`
  during the scan.

## Value

A \`ggplot\` object.

## Examples

``` r
dat <- simulate_env_window_data(n_environments = 16, n_days = 100,
                                signal_start = 30, signal_end = 55)
fit <- scan_env_windows(
  dat$weather, dat$traits, dat$periods,
  "temperature", "yield", window_sizes = 28,
  step = 7, min_pairs = 8, quiet = TRUE
)
plot_window_profile(fit, "temperature", "yield", window_days = 28)
```
