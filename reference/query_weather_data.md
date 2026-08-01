# Query daily historical weather for each environment

Downloads daily historical weather from the Open-Meteo Archive API using
the latitude, longitude, and season dates in an environment table. No
API key is required. The returned data can be supplied directly to
\[scan_env_windows()\].

## Usage

``` r
query_weather_data(
  environments,
  weather_vars = c("temperature", "precipitation"),
  environment_col = "environment_id",
  latitude_col = "latitude",
  longitude_col = "longitude",
  season_start_col = "season_start",
  season_end_col = "season_end",
  altitude_col = "altitude_m",
  timezone = "auto",
  model = NULL,
  pause_seconds = 0,
  quiet = FALSE
)
```

## Arguments

- environments:

  A data frame with one row per environment.

- weather_vars:

  Character vector of weather variables to download. See Details for
  supported friendly names. A named vector can map custom output names
  to Open-Meteo daily variable names.

- environment_col:

  Name of the environment identifier column.

- latitude_col, longitude_col:

  Names of coordinate columns in decimal degrees.

- season_start_col, season_end_col:

  Names of season date columns.

- altitude_col:

  Optional elevation column in meters. If present, it is passed to the
  API; missing values are ignored.

- timezone:

  Time-zone setting passed to Open-Meteo. The default, \`"auto"\`,
  resolves the local time zone from coordinates.

- model:

  Optional Open-Meteo historical model name, such as \`"era5_land"\`.
  Leave \`NULL\` to use the provider's default best-match data.

- pause_seconds:

  Optional pause between environment requests.

- quiet:

  Suppress progress messages.

## Value

A tibble with \`environment_id\`, \`date\`, and one numeric column for
each requested weather variable.

## Details

Supported friendly names are \`temperature\`, \`temperature_min\`,
\`temperature_max\`, \`precipitation\`, \`rain\`, \`snowfall\`,
\`precipitation_hours\`, \`relative_humidity\`,
\`relative_humidity_min\`, \`relative_humidity_max\`,
\`solar_radiation\`, \`evapotranspiration\`, \`wind_speed\`, and
\`wind_gusts\`.

You can also request an Open-Meteo daily field directly, or use a named
vector to control the output name, for example \`c(tmean =
"temperature_2m_mean", rain_mm = "precipitation_sum")\`.

The function makes one web request per environment. For reproducible
work, save the returned table to CSV and use the saved file in later
analyses. Open-Meteo data use is subject to the provider's terms and
attribution requirements.

## Examples

``` r
environments <- data.frame(
  environment_id = "2019_Waldo",
  latitude = 29.795286,
  longitude = -82.129853,
  season_start = "2018-06-01",
  season_end = "2019-05-31",
  altitude_m = 30
)
if (FALSE) { # \dontrun{
weather <- query_weather_data(
  environments,
  weather_vars = c("temperature", "precipitation", "solar_radiation")
)
utils::write.csv(weather, "weather.csv", row.names = FALSE)
} # }
```
