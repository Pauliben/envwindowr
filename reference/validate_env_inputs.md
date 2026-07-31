# Validate weather, trait, and period inputs

Validate weather, trait, and period inputs

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

  Daily weather data frame.

- traits:

  Trait data frame.

- periods:

  Environment-specific period data frame.

- environment_col:

  Environment identifier column shared by all inputs.

- date_col:

  Date column in \`weather\`.

- period_start_col:

  Start-date column in \`periods\`.

- period_end_col:

  End-date column in \`periods\`.

- weather_vars:

  Numeric weather columns.

- trait_vars:

  Numeric trait columns.

## Value

A validated list containing normalized copies of the three inputs.
