# Changelog

## envwindowr 0.2.0

- Added
  [`query_weather_data()`](https://pauliben.github.io/envwindowr/reference/query_weather_data.md)
  to retrieve historical daily weather from the Open-Meteo Archive API
  using environment coordinates and season dates.
- Added
  [`write_envwindow_templates()`](https://pauliben.github.io/envwindowr/reference/write_envwindow_templates.md)
  to create phenotype, environment, and weather CSV templates.
- Added support for `season_start` and `season_end` environment columns
  without requiring explicit column-name arguments.
- Expanded help pages, examples, README instructions, and a real-data
  vignette.
- Updated simulated phenotypes to include `genotype_id` and environment
  metadata to include coordinates and optional altitude.
- Added explicit guidance on window size, step size, and the environment
  as the independent analysis unit.

## envwindowr 0.1.0

- Initial release.
