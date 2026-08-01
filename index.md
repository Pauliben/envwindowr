# envwindowr

Package documentation updated July 2026.

`envwindowr` discovers environmental time windows during which
summarized daily weather variables are associated with phenotypic traits
across independent environments or environment-years.

## Installation

``` r

# install.packages("remotes")
remotes::install_github("Pauliben/envwindowr")
```

## Help

Every exported function has an R help page:

``` r

help(package = "envwindowr")
?scan_env_windows
?query_weather_data
?write_envwindow_templates
vignette("real-data-workflow", package = "envwindowr")
```

## Input files

### 1. Phenotypes

One row per environment-genotype observation. Trait columns must be
numeric. Repeated observations are allowed.

| environment_id | genotype_id | weight | brix |  tta | firmness | size |
|----------------|-------------|-------:|-----:|-----:|---------:|-----:|
| 2018_Waldo     | G001        |   2.51 | 11.2 | 0.71 |      185 | 16.2 |
| 2018_Waldo     | G002        |   2.43 | 10.8 | 0.76 |      176 | 15.8 |

The analysis averages all selected phenotype rows within each
environment before correlation. To study one genotype, filter the
phenotype table first.

### 2. Environments

One row per environment. `altitude_m` is optional.

| environment_id |  latitude |  longitude | season_start | season_end | altitude_m |
|----------------|----------:|-----------:|--------------|------------|-----------:|
| 2018_Waldo     | 29.795286 | -82.129853 | 2017-06-01   | 2018-05-31 |         30 |
| 2019_Waldo     | 29.795286 | -82.129853 | 2018-06-01   | 2019-05-31 |         30 |

Use ISO dates (`YYYY-MM-DD`) in CSV files. The package also accepts
common US date strings such as `6/1/2017`.

### 3. Daily weather

One row per environment and date. Additional columns are numeric weather
variables.

| environment_id | date       | temperature | precipitation | solar_radiation |
|----------------|------------|------------:|--------------:|----------------:|
| 2018_Waldo     | 2017-06-01 |        25.1 |           0.0 |            20.3 |

Create templates with:

``` r

library(envwindowr)
write_envwindow_templates("my_envwindowr_data")
```

## Obtain weather in either of two ways

### Option A: provide your own weather file

``` r

phenotypes <- read.csv("phenotypes.csv")
environments <- read.csv("environments.csv")
weather <- read.csv("weather.csv")
```

### Option B: query historical weather

[`query_weather_data()`](https://pauliben.github.io/envwindowr/reference/query_weather_data.md)
uses the latitude, longitude, season start, and season end for every
environment. It downloads historical daily weather from Open-Meteo.

``` r

weather <- query_weather_data(
  environments,
  weather_vars = c(
    "temperature",
    "temperature_min",
    "temperature_max",
    "precipitation",
    "solar_radiation"
  )
)

write.csv(weather, "weather.csv", row.names = FALSE)
```

Saving queried weather is recommended so that the exact same file can be
used for later analyses.

## Window size and step size

`window_sizes` defines the length of each candidate period. For example,
`window_sizes = 28` summarizes weather in consecutive 28-day windows.

`step` defines how many days the window moves before the next test. With
a 28-day window and `step = 7`, the package tests:

- days 0-27;
- days 7-34;
- days 14-41; and
- subsequent starts every seven days.

A smaller step gives finer temporal resolution but generates more tests
and requires more computation. A larger step is faster but gives a
coarser search. Multiple window sizes can be tested together, for
example `window_sizes = c(14, 28, 42)`.

## Real-data analysis

``` r

library(envwindowr)

phenotypes <- read.csv("phenotypes.csv")
environments <- read.csv("environments.csv")
weather <- read.csv("weather.csv")

fit <- scan_env_windows(
  weather = weather,
  traits = phenotypes,
  periods = environments,
  weather_vars = c("temperature", "precipitation", "solar_radiation"),
  trait_vars = c("weight", "brix", "tta", "firmness", "size"),
  window_sizes = c(14, 28, 42),
  step = 7,
  summaries = c(
    temperature = "mean",
    precipitation = "sum",
    solar_radiation = "sum"
  ),
  min_pairs = 10,
  min_coverage = 0.80
)

fit
rank_env_windows(fit, n = 10)
diagnose_env_scan(fit)
plot_window_heatmap(fit, "temperature", "weight")
plot_top_windows(fit, "temperature", "weight")
plot_window_profile(fit, "temperature", "weight", window_days = 28)
```

## Function guide

- [`write_envwindow_templates()`](https://pauliben.github.io/envwindowr/reference/write_envwindow_templates.md):
  write example CSV input structures.
- [`query_weather_data()`](https://pauliben.github.io/envwindowr/reference/query_weather_data.md):
  download historical daily weather for environments.
- [`validate_env_inputs()`](https://pauliben.github.io/envwindowr/reference/validate_env_inputs.md):
  check and normalize the three input tables.
- [`make_env_windows()`](https://pauliben.github.io/envwindowr/reference/make_env_windows.md):
  inspect candidate windows before analysis.
- [`summarize_window_weather()`](https://pauliben.github.io/envwindowr/reference/summarize_window_weather.md):
  summarize one window; normally used internally.
- [`scan_env_windows()`](https://pauliben.github.io/envwindowr/reference/scan_env_windows.md):
  run the complete environmental-window scan.
- [`rank_env_windows()`](https://pauliben.github.io/envwindowr/reference/rank_env_windows.md):
  rank the strongest successful associations.
- [`diagnose_env_scan()`](https://pauliben.github.io/envwindowr/reference/diagnose_env_scan.md):
  identify small sample size, coverage, or variance issues.
- [`plot_window_heatmap()`](https://pauliben.github.io/envwindowr/reference/plot_window_heatmap.md):
  display correlations by window start and end.
- [`plot_top_windows()`](https://pauliben.github.io/envwindowr/reference/plot_top_windows.md):
  display the strongest windows as bars.
- [`plot_window_profile()`](https://pauliben.github.io/envwindowr/reference/plot_window_profile.md):
  inspect one window size across the season.
- [`plot_best_window_scatter()`](https://pauliben.github.io/envwindowr/reference/plot_best_window_scatter.md):
  plot one selected weather-trait relationship.
- [`simulate_env_window_data()`](https://pauliben.github.io/envwindowr/reference/simulate_env_window_data.md):
  create a reproducible practice dataset.

## Interpretation

The independent sample size is the number of environments, not the
number of plants or genotypes. Selected windows are exploratory
associations. Validate important windows biologically and, whenever
possible, in independent data.
