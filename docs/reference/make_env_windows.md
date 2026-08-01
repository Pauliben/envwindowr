# Create candidate environmental windows

Builds the sequence of candidate time windows evaluated by
\[scan_env_windows()\]. This function is useful for inspecting the
analysis design before running all weather-trait correlations.

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

  Environment table with season start and end dates.

- window_sizes:

  Integer window lengths in days. Use multiple values to compare
  different temporal scales.

- step:

  Number of days between consecutive candidate starts.

- start_offset:

  First candidate start relative to each environment's season start. Day
  0 is the start date.

- end_offset:

  Last allowed day offset. Defaults to the final day of the shortest
  environment season.

- period_start_col, period_end_col:

  Season date column names. The \`season_start\`/\`season_end\` names
  are detected automatically when the defaults are absent.

## Value

A tibble containing \`window_id\`, \`start_offset\`, \`end_offset\`, and
\`window_days\`.

## Details

A window size of 28 and a step of 7 produce overlapping windows: days
0-27, 7-34, 14-41, and so forth. Reducing \`step\` increases temporal
resolution and the number of statistical tests. Increasing \`step\`
reduces computation but produces a coarser search.

## Examples

``` r
periods <- data.frame(
  environment_id = c("2018_Waldo", "2019_Waldo"),
  season_start = c("2017-06-01", "2018-06-01"),
  season_end = c("2018-05-31", "2019-05-31")
)
make_env_windows(periods, window_sizes = c(14, 28), step = 7)
#> # A tibble: 100 × 4
#>    window_id start_offset end_offset window_days
#>        <int>        <int>      <int>       <int>
#>  1         1            0         13          14
#>  2         2            7         20          14
#>  3         3           14         27          14
#>  4         4           21         34          14
#>  5         5           28         41          14
#>  6         6           35         48          14
#>  7         7           42         55          14
#>  8         8           49         62          14
#>  9         9           56         69          14
#> 10        10           63         76          14
#> # ℹ 90 more rows
```
