# Using envwindowr with phenotype, environment, and weather data

``` r

library(envwindowr)
```

## Overview

A complete analysis uses three tables:

1.  a phenotype table containing environments, genotypes, and traits;
2.  an environment table containing coordinates and season dates; and
3.  a daily weather table supplied by the user or downloaded by the
    package.

The environment or environment-year is the independent unit. Phenotype
records within an environment are averaged before correlations are
calculated.

## Create input templates

``` r

write_envwindow_templates("my_project/data")
```

This creates `phenotypes_template.csv`, `environments_template.csv`, and
`weather_template.csv`.

## Phenotype table

Required identifier columns are `environment_id` and `genotype_id`. Add
any numeric traits needed for analysis.

``` text
environment_id,genotype_id,weight,brix,tta,firmness,size
2018_Waldo,G001,2.51,11.2,0.71,185,16.2
2018_Waldo,G002,2.43,10.8,0.76,176,15.8
```

Repeated genotype observations are allowed. The current analysis
averages all selected records within each environment. To study one
genotype, filter before running the scan:

``` r

phenotype_G001 <- subset(phenotypes, genotype_id == "G001")
```

## Environment table

The table contains one row per environment. `altitude_m` is optional but
can be used by the weather query.

``` text
environment_id,latitude,longitude,season_start,season_end,altitude_m
2018_Waldo,29.795286,-82.129853,2017-06-01,2018-05-31,30
2019_Waldo,29.795286,-82.129853,2018-06-01,2019-05-31,30
```

## Weather option 1: provide daily data

``` text
environment_id,date,temperature,precipitation,solar_radiation
2018_Waldo,2017-06-01,25.1,0.0,20.3
2018_Waldo,2017-06-02,25.8,4.2,17.8
```

There must be only one row for each environment-date combination. If
several sensors or stations provide values for one day, aggregate them
first.

``` r

phenotypes <- read.csv("phenotypes.csv")
environments <- read.csv("environments.csv")
weather <- read.csv("weather.csv")
```

## Weather option 2: query historical data

``` r

weather <- query_weather_data(
  environments,
  weather_vars = c(
    "temperature",
    "temperature_min",
    "temperature_max",
    "precipitation",
    "solar_radiation",
    "evapotranspiration"
  )
)
write.csv(weather, "weather.csv", row.names = FALSE)
```

The query uses Open-Meteo historical daily data and requires internet
access. Saving the result is recommended for reproducibility.

## Choose the window and step sizes

The window size is the number of consecutive days summarized for one
test. For example, a 28-day window may represent approximately four
weeks of temperature exposure.

The step size is the number of days between candidate starts. With
`window_sizes = 28` and `step = 7`, the windows are:

``` text
0-27, 7-34, 14-41, 21-48, ...
```

A smaller step provides a more detailed search but increases the number
of correlations and multiple-testing burden. A larger step is faster but
less precise in time. Testing multiple window sizes can identify whether
a trait is associated with a short event or a longer cumulative period.

You can inspect the candidate design before running the scan:

``` r

make_env_windows(
  environments,
  window_sizes = c(14, 28, 42),
  step = 7
)
```

## Run the scan

``` r

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
  method = "pearson",
  min_pairs = 10,
  p_adjust = "BH",
  min_coverage = 0.80
)
```

Use `mean` for average temperature and `sum` for cumulative rainfall or
solar radiation when those summaries match the biological question.

## Review and visualize results

``` r

fit
ranked <- rank_env_windows(fit, n = 10)
diagnose_env_scan(fit)

plot_window_heatmap(fit, "temperature", "weight")
plot_top_windows(fit, "temperature", "weight")
plot_window_profile(fit, "temperature", "weight", window_days = 28)

best <- ranked[1, ]
plot_best_window_scatter(
  weather, phenotypes, environments,
  weather_var = best$environmental_variable,
  trait = best$trait,
  start_offset = best$start_offset,
  end_offset = best$end_offset,
  summary = "mean"
)
```

## Function help

Run `?function_name` for arguments, details, values, and examples.
Useful pages include:

``` r

?write_envwindow_templates
?query_weather_data
?validate_env_inputs
?make_env_windows
?scan_env_windows
?rank_env_windows
?diagnose_env_scan
?plot_window_heatmap
```
