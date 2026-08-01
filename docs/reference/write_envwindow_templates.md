# Write example input files for a real-data analysis

Creates CSV files that show the column structure expected by
\`envwindowr\`. The phenotype file contains one row per
environment-genotype observation, the environment file contains location
and season metadata, and the optional weather file shows the required
daily-weather structure.

## Usage

``` r
write_envwindow_templates(
  path = ".",
  overwrite = FALSE,
  include_weather = TRUE,
  example_rows = TRUE
)
```

## Arguments

- path:

  Directory where the files will be written.

- overwrite:

  Logical. Overwrite existing files with the same names?

- include_weather:

  Logical. Also write \`weather_template.csv\`?

- example_rows:

  Logical. Include example rows. When \`FALSE\`, only column headers are
  written.

## Value

Invisibly returns a named character vector containing the paths of the
files that were written.

## Details

The phenotype file always includes \`environment_id\` and
\`genotype_id\`. Replace the example trait columns with any numeric
traits relevant to your study. The environment file requires
\`environment_id\`, \`latitude\`, \`longitude\`, \`season_start\`, and
\`season_end\`; \`altitude_m\` is optional.

The weather file must contain one row per environment and date, with
numeric weather variables in additional columns. You may provide this
file yourself or create it from the environment table with
\[query_weather_data()\].

## Examples

``` r
out <- file.path(tempdir(), "envwindowr-inputs")
write_envwindow_templates(out, overwrite = TRUE)
list.files(out)
#> [1] "environments_template.csv" "phenotypes_template.csv"  
#> [3] "weather_template.csv"     
```
