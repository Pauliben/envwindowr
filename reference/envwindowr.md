# Environmental Window Discovery for Trait Associations

Tools for scanning candidate environmental periods, summarizing daily
weather, correlating those summaries with traits across independent
environments, diagnosing failures, ranking windows, and visualizing
results.

## Details

The primary entry point is
[`scan_env_windows()`](https://rdrr.io/pkg/envwindowr/man/envwindowr.html).
See the package README and vignette for complete argument descriptions
and examples. Source functions include roxygen comments; run
`devtools::document()` after cloning to regenerate full per-function
help pages.

## Examples

``` r
dat <- simulate_env_window_data(n_environments = 12, n_days = 90)
fit <- scan_env_windows(
  dat$weather, dat$traits, dat$periods,
  weather_vars = "temperature",
  trait_vars = "yield",
  window_sizes = 21,
  step = 7,
  min_pairs = 5,
  quiet = TRUE
)
rank_env_windows(fit, n = 3)
#> # A tibble: 3 × 17
#>    rank window_id start_offset end_offset window_days environmental_variable
#>   <int>     <int>        <int>      <int>       <int> <chr>                 
#> 1     1        10           63         83          21 temperature           
#> 2     2         3           14         34          21 temperature           
#> 3     3         9           56         76          21 temperature           
#> # ℹ 11 more variables: trait <chr>, mean_coverage <dbl>,
#> #   min_coverage_observed <dbl>, correlation <dbl>, p_value <dbl>,
#> #   n_pairs <int>, environmental_sd <dbl>, trait_sd <dbl>, status <chr>,
#> #   p_adjusted <dbl>, absolute_correlation <dbl>
```
