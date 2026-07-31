# Rank the strongest environmental windows

Rank the strongest environmental windows

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

  An \`env_window_scan\` object or correlations data frame.

- n:

  Number of windows retained per weather-variable/trait combination.

- significant_only:

  Keep only adjusted p-values at or below \`alpha\`.

- alpha:

  Significance threshold.

- min_pairs:

  Optional additional minimum pair filter.

## Value

Ranked tibble.
