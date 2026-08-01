# Simulate example weather, phenotype, and environment data

Creates a reproducible multi-environment dataset with a known
temperature signal. The output follows the same structure recommended
for real data: phenotypes contain environment and genotype identifiers,
environments contain season dates and coordinates, and weather contains
one row per day.

## Usage

``` r
simulate_env_window_data(
  n_environments = 24L,
  n_days = 180L,
  n_genotypes = 8L,
  signal_start = 70L,
  signal_end = 105L,
  seed = 1L
)
```

## Arguments

- n_environments:

  Number of independent environments or environment-years.

- n_days:

  Number of weather days per environment.

- n_genotypes:

  Number of genotypes observed in every environment.

- signal_start, signal_end:

  True temperature-signal window offsets relative to season start. If
  \`signal_end\` extends beyond \`n_days\`, the signal is truncated at
  the final simulated day.

- seed:

  Random seed.

## Value

A list containing:

\* \`weather\`: daily temperature and rainfall; \* \`traits\` and
\`phenotypes\`: identical phenotype tables containing
\`environment_id\`, \`genotype_id\`, \`yield\`, and \`quality\`; \*
\`periods\` and \`environments\`: identical environment tables
containing season dates, coordinates, and altitude; and \* \`truth\`:
the simulated weather variable and signal window.

## Examples

``` r
dat <- simulate_env_window_data(
  n_environments = 12,
  n_days = 100,
  n_genotypes = 5,
  signal_start = 30,
  signal_end = 55
)
head(dat$phenotypes)
#> # A tibble: 6 × 4
#>   environment_id genotype_id yield quality
#>   <chr>          <chr>       <dbl>   <dbl>
#> 1 E01            G001        10.7     5.17
#> 2 E01            G002        11.9     4.37
#> 3 E01            G003         8.87    6.57
#> 4 E01            G004        11.8     4.65
#> 5 E01            G005        13.1     4.58
#> 6 E02            G001        10.3     3.61
head(dat$environments)
#> # A tibble: 6 × 8
#>   environment_id latitude longitude season_start season_end altitude_m
#>   <chr>             <dbl>     <dbl> <date>       <date>          <dbl>
#> 1 E01                27.1     -80.8 2022-10-13   2023-01-20       40.8
#> 2 E02                28.5     -81.8 2021-11-09   2022-02-16       69.6
#> 3 E03                30.5     -80.5 2020-05-08   2020-08-15       37.9
#> 4 E04                28.4     -81.1 2022-07-18   2022-10-25       23.4
#> 5 E05                28.9     -80.7 2021-04-15   2021-07-23       10.3
#> 6 E06                29.4     -81.3 2020-10-25   2021-02-01       12.5
#> # ℹ 2 more variables: start_date <date>, end_date <date>
head(dat$weather)
#> # A tibble: 6 × 4
#>   environment_id date       temperature rainfall
#>   <chr>          <date>           <dbl>    <dbl>
#> 1 E01            2022-10-13        20.3    3.35 
#> 2 E01            2022-10-14        20.0    0.110
#> 3 E01            2022-10-15        18.4    2.81 
#> 4 E01            2022-10-16        20.2    0.105
#> 5 E01            2022-10-17        20.6    0.987
#> 6 E01            2022-10-18        21.5    0.797
```
