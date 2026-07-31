# Scatter plot for one selected environmental window

Scatter plot for one selected environmental window

## Usage

``` r
plot_best_window_scatter(
  weather,
  traits,
  periods,
  weather_var,
  trait,
  start_offset,
  end_offset,
  summary = "mean",
  environment_col = "environment_id",
  date_col = "date",
  period_start_col = "start_date",
  period_end_col = "end_date"
)
```

## Arguments

- weather:

  Daily weather data.

- traits:

  Trait data.

- periods:

  Period table.

- weather_var:

  Weather variable.

- trait:

  Trait variable.

- start_offset, end_offset:

  Selected offsets.

- summary:

  Summary statistic.

- environment_col, date_col, period_start_col, period_end_col:

  Column names.

## Value

A ggplot object.
