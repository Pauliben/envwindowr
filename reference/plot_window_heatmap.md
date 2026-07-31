# Plot a correlation heatmap across window starts and ends

Plot a correlation heatmap across window starts and ends

## Usage

``` r
plot_window_heatmap(
  x,
  weather_var,
  trait,
  show_significance = TRUE,
  alpha = 0.05
)
```

## Arguments

- x:

  Scan object or correlation results.

- weather_var:

  Weather variable name.

- trait:

  Trait name.

- show_significance:

  Mark adjusted significant windows.

- alpha:

  Adjusted-p threshold.

## Value

A ggplot object.
