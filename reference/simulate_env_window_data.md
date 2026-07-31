# Simulate example weather and trait data with a known signal

Simulate example weather and trait data with a known signal

## Usage

``` r
simulate_env_window_data(
  n_environments = 24L,
  n_days = 180L,
  signal_start = 70L,
  signal_end = 105L,
  seed = 1L
)
```

## Arguments

- n_environments:

  Number of independent environments.

- n_days:

  Days per environment.

- signal_start, signal_end:

  True signal window offsets.

- seed:

  Random seed.

## Value

List with weather, traits, periods, and truth.
