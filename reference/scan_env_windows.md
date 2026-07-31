# Scan environmental windows for trait associations

Scan environmental windows for trait associations

## Usage

``` r
scan_env_windows(
  weather,
  traits,
  periods,
  weather_vars,
  trait_vars,
  window_sizes = 28L,
  step = 7L,
  summaries = "mean",
  method = "pearson",
  min_pairs = 5L,
  p_adjust = "BH",
  environment_col = "environment_id",
  date_col = "date",
  period_start_col = "start_date",
  period_end_col = "end_date",
  start_offset = 0L,
  end_offset = NULL,
  min_coverage = 0.8,
  quiet = FALSE
)
```

## Arguments

- weather:

  Daily weather data with one row per environment and date.

- traits:

  Trait observations. Replicates are averaged by environment before
  correlation.

- periods:

  One row per environment with start and end dates.

- weather_vars:

  Numeric weather variables to scan.

- trait_vars:

  Numeric traits to analyze.

- window_sizes:

  Candidate window lengths in days.

- step:

  Days between candidate starts.

- summaries:

  One summary statistic or a named vector/list by weather variable.

- method:

  Correlation method: \`pearson\`, \`spearman\`, or \`kendall\`.

- min_pairs:

  Minimum independent environments required.

- p_adjust:

  Multiple-testing adjustment method.

- environment_col, date_col, period_start_col, period_end_col:

  Input column names.

- start_offset, end_offset:

  Optional scan bounds relative to each period start.

- min_coverage:

  Minimum proportion of expected daily values required per
  environment-window.

- quiet:

  Suppress progress messages.

## Value

An object of class \`env_window_scan\`.
