# Diagnose scan quality and common failure modes

Summarizes result-status codes and flags design features that can make
environmental-window associations unstable or difficult to interpret.

## Usage

``` r
diagnose_env_scan(x)
```

## Arguments

- x:

  An \`env_window_scan\` object returned by \[scan_env_windows()\].

## Value

A list with the number of environments and windows, status counts, and
plain-language warnings.

## Details

The diagnostic is a screening aid, not a substitute for biological
validation, independent datasets, or an analysis that accounts for the
experimental design. Environmental windows selected from a small number
of environments can be highly unstable even when correlations are large.

## Examples

``` r
dat <- simulate_env_window_data(n_environments = 12, n_days = 90)
fit <- scan_env_windows(
  dat$weather, dat$traits, dat$periods,
  weather_vars = "temperature", trait_vars = "yield",
  window_sizes = 21, step = 7, min_pairs = 5, quiet = TRUE
)
diagnose_env_scan(fit)
#> $n_environments
#> [1] 12
#> 
#> $n_windows
#> [1] 10
#> 
#> $status_counts
#> # A tibble: 1 × 2
#>   status     n
#>   <chr>  <int>
#> 1 ok        10
#> 
#> $warnings
#> [1] "Fewer than 15 independent environments: interpret selected windows cautiously."
#> 
```
