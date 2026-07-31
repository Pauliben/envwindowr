# Summarize daily weather for one candidate window

Summarize daily weather for one candidate window

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

  Validated weather table containing \`.day_offset\`.

- window:

  A one-row window table.

- weather_vars:

  Weather variables.

- summaries:

  Named character vector/list mapping variables to statistics, or one
  statistic recycled to all variables.

- environment_col:

  Environment identifier column.

## Value

One row per environment and weather variable in long format.
