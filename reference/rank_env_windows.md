# Rank the strongest environmental windows

Orders successful weather-window associations by the absolute value of
their correlation, separately for every weather-variable and trait
combination.

## Usage

``` r
rank_env_windows(
  x,
  n = 10L,
  significant_only = FALSE,
  alpha = 0.05,
  min_pairs = NULL
)
```

## Arguments

- x:

  An \`env_window_scan\` object or its \`correlations\` data frame.

- n:

  Number of windows retained per weather-variable/trait combination.

- significant_only:

  Keep only windows with adjusted p-values at or below \`alpha\`.

- alpha:

  Adjusted-p significance threshold.

- min_pairs:

  Optional additional minimum number of environments.

## Value

A ranked tibble. \`rank = 1\` is the strongest retained association
within a weather-variable/trait combination.

## Examples

``` r
dat <- simulate_env_window_data(n_environments = 16, n_days = 100,
                                signal_start = 30, signal_end = 55)
fit <- scan_env_windows(
  dat$weather, dat$traits, dat$periods,
  weather_vars = "temperature", trait_vars = "yield",
  window_sizes = c(14, 28), step = 7, min_pairs = 8, quiet = TRUE
)
rank_env_windows(fit, n = 5)
#> # A tibble: 5 × 17
#>    rank window_id start_offset end_offset window_days environmental_variable
#>   <int>     <int>        <int>      <int>       <int> <chr>                 
#> 1     1         7           42         55          14 temperature           
#> 2     2         6           35         48          14 temperature           
#> 3     3        18           28         55          28 temperature           
#> 4     4        19           35         62          28 temperature           
#> 5     5        20           42         69          28 temperature           
#> # ℹ 11 more variables: trait <chr>, mean_coverage <dbl>,
#> #   min_coverage_observed <dbl>, correlation <dbl>, p_value <dbl>,
#> #   n_pairs <int>, environmental_sd <dbl>, trait_sd <dbl>, status <chr>,
#> #   p_adjusted <dbl>, absolute_correlation <dbl>
rank_env_windows(fit, n = 5, significant_only = TRUE, alpha = 0.10)
#> # A tibble: 5 × 17
#>    rank window_id start_offset end_offset window_days environmental_variable
#>   <int>     <int>        <int>      <int>       <int> <chr>                 
#> 1     1         7           42         55          14 temperature           
#> 2     2         6           35         48          14 temperature           
#> 3     3        18           28         55          28 temperature           
#> 4     4        19           35         62          28 temperature           
#> 5     5        20           42         69          28 temperature           
#> # ℹ 11 more variables: trait <chr>, mean_coverage <dbl>,
#> #   min_coverage_observed <dbl>, correlation <dbl>, p_value <dbl>,
#> #   n_pairs <int>, environmental_sd <dbl>, trait_sd <dbl>, status <chr>,
#> #   p_adjusted <dbl>, absolute_correlation <dbl>
```
