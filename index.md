# envwindowr

`envwindowr` discovers periods during which environmental variables are
associated with traits across independent environments or
environment-years.

## Installation

``` r

# install.packages("remotes")
remotes::install_github("USERNAME/envwindowr")
```

## Minimal workflow

``` r

library(envwindowr)

example <- simulate_env_window_data()

fit <- scan_env_windows(
  weather = example$weather,
  traits = example$traits,
  periods = example$periods,
  weather_vars = c("temperature", "rainfall"),
  trait_vars = c("yield", "quality"),
  window_sizes = c(14, 28, 42),
  step = 7,
  summaries = c(temperature = "mean", rainfall = "sum"),
  min_pairs = 10
)

fit
rank_env_windows(fit, n = 5)
diagnose_env_scan(fit)
plot_window_heatmap(fit, "temperature", "yield")
plot_top_windows(fit, "temperature", "yield")
plot_window_profile(fit, "temperature", "yield", window_days = 28)
```

## Required inputs

- `weather`: one row per environment and day; daily weather variables in
  numeric columns.
- `traits`: one or more rows per environment; replicate rows are
  averaged by environment.
- `periods`: one row per environment with `start_date` and `end_date`.

The environment/environment-year is the independent unit. Genotypes or
technical replicates within one environment do not increase the
independent sample size.

## Error handling and diagnostics

The package detects duplicate weather dates, missing environments,
invalid dates, nonnumeric variables, insufficient pairs, constant
variables, incomplete weather windows, and unknown plot selections.
Correlation outputs retain a `status` column instead of silently
dropping failed tests.

## Repository setup

Replace `USERNAME` and the maintainer fields in `DESCRIPTION`, then run:

``` r

install.packages(c("devtools", "roxygen2", "testthat", "pkgdown"))
devtools::document()
devtools::test()
devtools::check()
pkgdown::build_site()
```
