# Scan environmental windows for trait associations

Tests a sequence of candidate time windows to identify periods in which
summarized daily weather is associated with phenotypic traits across
environments. This is the main analysis function in \`envwindowr\`.

## Usage

``` r
scan_env_windows(
  weather,
  traits,
  periods,
  weather_vars,
  trait_vars,
  window_sizes = 28L,
  step = 7L,
  summaries = "mean",
  method = "pearson",
  min_pairs = 5L,
  p_adjust = "BH",
  environment_col = "environment_id",
  date_col = "date",
  period_start_col = "start_date",
  period_end_col = "end_date",
  start_offset = 0L,
  end_offset = NULL,
  min_coverage = 0.8,
  quiet = FALSE
)

# S3 method for class 'env_window_scan'
print(x, ...)
```

## Arguments

- weather:

  Daily weather data with one row per environment and date. Required
  columns are the environment identifier, a date column, and the numeric
  columns named in \`weather_vars\`.

- traits:

  Phenotype data. A typical table contains \`environment_id\`,
  \`genotype_id\`, and one or more numeric trait columns. All phenotype
  rows within an environment are averaged before correlation. To analyze
  one genotype separately, filter \`traits\` to that genotype before
  calling this function.

- periods:

  Environment metadata with one row per environment and season start/end
  dates. Additional columns such as latitude, longitude, and altitude
  are allowed. The default date names are \`start_date\` and
  \`end_date\`; \`season_start\` and \`season_end\` are detected
  automatically.

- weather_vars:

  Character vector naming numeric weather columns to scan.

- trait_vars:

  Character vector naming numeric phenotype columns.

- window_sizes:

  Candidate window lengths, in days. One value performs a fixed-size
  scan; multiple values compare several temporal scales.

- step:

  Number of days between consecutive candidate window starts.

- summaries:

  One summary statistic recycled to all weather variables, or a named
  character vector/list mapping variables to statistics. Supported
  character values are \`mean\`, \`sum\`, \`min\`, \`max\`, \`median\`,
  and \`sd\`.

- method:

  Correlation method: \`pearson\`, \`spearman\`, or \`kendall\`.

- min_pairs:

  Minimum number of independent environments required for a correlation
  test.

- p_adjust:

  Multiple-testing adjustment method passed to \[stats::p.adjust()\].

- environment_col, date_col, period_start_col, period_end_col:

  Input column names.

- start_offset:

  First candidate day relative to each season start. Day 0 is the
  season-start date.

- end_offset:

  Last day allowed in a candidate window. By default, the shortest
  season among environments determines the scan boundary.

- min_coverage:

  Minimum proportion of expected daily observations needed for an
  environment-window summary to be retained.

- quiet:

  Suppress progress messages.

- x:

  An \`env_window_scan\` object.

- ...:

  Additional arguments, currently ignored.

## Value

An object of class \`env_window_scan\` containing:

\* \`correlations\`: test results for every weather-trait-window
combination; \* \`windows\`: candidate window definitions; \*
\`periods\`: validated environment metadata; \* \`trait_means\`:
environment-level phenotype means; and \* \`settings\`: analysis
settings.

\`x\`, invisibly.

## Details

\*\*Window size\*\* is the number of consecutive days summarized for
each test. For example, \`window_sizes = 28\` calculates one weather
summary for every 28-day candidate period. \`window_sizes = c(14, 28,
42)\` evaluates short, medium, and long periods.

\*\*Step size\*\* is controlled by \`step\` and determines how far the
window moves between tests. With a 28-day window and \`step = 7\`, the
first windows are days 0-27, 7-34, 14-41, and so on. A smaller step
provides finer temporal resolution but creates more tests and takes
longer. A larger step is faster but may miss narrow response periods.

The independent unit is the environment or environment-year. Genotypes
and replicates within an environment do not increase the number of
independent weather observations. Consequently, the default analysis
averages the selected trait across all rows within each environment.

## Examples

``` r
dat <- simulate_env_window_data(
  n_environments = 18,
  n_days = 120,
  signal_start = 35,
  signal_end = 60
)

fit <- scan_env_windows(
  weather = dat$weather,
  traits = dat$traits,
  periods = dat$periods,
  weather_vars = c("temperature", "rainfall"),
  trait_vars = c("yield", "quality"),
  window_sizes = c(14, 28),
  step = 7,
  summaries = c(temperature = "mean", rainfall = "sum"),
  min_pairs = 8,
  quiet = TRUE
)
fit
#> Environmental-window scan
#>   Windows: 30 
#>   Environments: 18 
#>   Weather variables: temperature, rainfall 
#>   Traits: yield, quality 
#>   Window size(s): 14, 28 days
#>   Step: 7 days
#>   Successful tests: 120 of 120 
rank_env_windows(fit, n = 3)
#> # A tibble: 12 × 17
#>     rank window_id start_offset end_offset window_days environmental_variable
#>    <int>     <int>        <int>      <int>       <int> <chr>                 
#>  1     1        13           84         97          14 rainfall              
#>  2     2        16          105        118          14 rainfall              
#>  3     3        27           70         97          28 rainfall              
#>  4     1        13           84         97          14 rainfall              
#>  5     2        27           70         97          28 rainfall              
#>  6     3        28           77        104          28 rainfall              
#>  7     1         3           14         27          14 temperature           
#>  8     2        16          105        118          14 temperature           
#>  9     3        19           14         41          28 temperature           
#> 10     1         5           28         41          14 temperature           
#> 11     2        21           28         55          28 temperature           
#> 12     3        19           14         41          28 temperature           
#> # ℹ 11 more variables: trait <chr>, mean_coverage <dbl>,
#> #   min_coverage_observed <dbl>, correlation <dbl>, p_value <dbl>,
#> #   n_pairs <int>, environmental_sd <dbl>, trait_sd <dbl>, status <chr>,
#> #   p_adjusted <dbl>, absolute_correlation <dbl>
```
