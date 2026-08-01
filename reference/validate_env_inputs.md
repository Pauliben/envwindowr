# Validate weather, phenotype, and environment inputs

Checks the three tables used by \[scan_env_windows()\], normalizes
dates, and calculates a day offset for every weather observation
relative to the start of its environment-specific season.

## Usage

``` r
validate_env_inputs(
  weather,
  traits,
  periods,
  environment_col = "environment_id",
  date_col = "date",
  period_start_col = "start_date",
  period_end_col = "end_date",
  weather_vars,
  trait_vars
)
```

## Arguments

- weather:

  Daily weather data with one row per environment and date.

- traits:

  Phenotype data with an environment identifier and numeric trait
  columns. A \`genotype_id\` column and other metadata columns are
  allowed.

- periods:

  Environment table with one row per environment and season start/end
  dates. Latitude, longitude, and altitude columns are allowed but are
  not required for validation unless weather will be queried.

- environment_col:

  Environment identifier shared by all inputs.

- date_col:

  Date column in \`weather\`.

- period_start_col:

  Start-date column in \`periods\`. When the default \`start_date\` is
  absent, \`season_start\` is detected automatically.

- period_end_col:

  End-date column in \`periods\`. When the default \`end_date\` is
  absent, \`season_end\` is detected automatically.

- weather_vars:

  Numeric weather columns to validate.

- trait_vars:

  Numeric phenotype columns to validate.

## Value

A list containing validated copies of \`weather\`, \`traits\`, and
\`periods\`, plus the resolved start- and end-column names. The weather
table includes an internal \`.day_offset\` column.

## Details

The function rejects duplicate environment-date weather records because
each daily value must be unique before a window summary is calculated.
If raw weather contains multiple observations per day, aggregate those
records first.

Dates may be \`Date\` objects or character strings in \`YYYY-MM-DD\`,
\`MM/DD/YYYY\`, or \`MM/DD/YY\` format. ISO \`YYYY-MM-DD\` is
recommended for CSV files because it is unambiguous.

## Examples

``` r
dat <- simulate_env_window_data(n_environments = 8, n_days = 90)
checked <- validate_env_inputs(
  weather = dat$weather,
  traits = dat$traits,
  periods = dat$periods,
  weather_vars = c("temperature", "rainfall"),
  trait_vars = c("yield", "quality")
)
names(checked)
#> [1] "weather"          "traits"           "periods"          "period_start_col"
#> [5] "period_end_col"  
head(checked$weather$.day_offset)
#> [1] 0 1 2 3 4 5
```
