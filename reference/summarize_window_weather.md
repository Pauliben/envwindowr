# Summarize daily weather for one candidate window

Calculates environment-level weather summaries for one candidate window.
This is a lower-level function used internally by
\[scan_env_windows()\].

## Usage

``` r
summarize_window_weather(
  weather,
  window,
  weather_vars,
  summaries = "mean",
  environment_col = "environment_id"
)
```

## Arguments

- weather:

  Validated weather table containing the internal \`.day_offset\` column
  created by \[validate_env_inputs()\].

- window:

  A one-row window table, usually one row from \[make_env_windows()\].

- weather_vars:

  Character vector of weather variables.

- summaries:

  Named character vector/list mapping variables to statistics, or one
  statistic recycled to all variables. Supported values are \`mean\`,
  \`sum\`, \`min\`, \`max\`, \`median\`, and \`sd\`; a function may also
  be supplied.

- environment_col:

  Environment identifier column.

## Value

One row per environment and weather variable in long format, with
\`environmental_value\` and \`n_weather_days\` columns.

## Examples

``` r
dat <- simulate_env_window_data(n_environments = 6, n_days = 60,
                                signal_start = 15, signal_end = 30)
checked <- validate_env_inputs(
  dat$weather, dat$traits, dat$periods,
  weather_vars = c("temperature", "rainfall"),
  trait_vars = "yield"
)
windows <- make_env_windows(checked$periods, window_sizes = 14, step = 7)
summarize_window_weather(
  checked$weather,
  windows[1, ],
  weather_vars = c("temperature", "rainfall"),
  summaries = c(temperature = "mean", rainfall = "sum")
)
#> # A tibble: 12 × 4
#>    environment_id environmental_variable environmental_value n_weather_days
#>    <chr>          <chr>                                <dbl>          <int>
#>  1 E01            temperature                           17.0             14
#>  2 E02            temperature                           18.9             14
#>  3 E03            temperature                           23.6             14
#>  4 E04            temperature                           21.3             14
#>  5 E05            temperature                           27.8             14
#>  6 E06            temperature                           22.0             14
#>  7 E01            rainfall                              32.7             14
#>  8 E02            rainfall                              42.5             14
#>  9 E03            rainfall                              60.7             14
#> 10 E04            rainfall                              44.5             14
#> 11 E05            rainfall                              56.1             14
#> 12 E06            rainfall                              39.9             14
```
