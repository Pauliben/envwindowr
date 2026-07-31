# Create candidate environmental windows

Create candidate environmental windows

## Usage

``` r
make_env_windows(
  periods,
  window_sizes = 28L,
  step = 7L,
  start_offset = 0L,
  end_offset = NULL,
  period_start_col = "start_date",
  period_end_col = "end_date"
)
```

## Arguments

- periods:

  Valid period table.

- window_sizes:

  Integer window lengths in days. Use multiple values to compare sizes.

- step:

  Number of days between candidate starts.

- start_offset:

  First candidate start relative to each environment's period start.

- end_offset:

  Last allowed day offset. Defaults to the shortest environment period.

## Value

A tibble of candidate windows.
