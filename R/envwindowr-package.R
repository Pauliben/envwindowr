#' envwindowr: Environmental Window Discovery for Trait Associations
#'
#' @description
#' `envwindowr` identifies time periods during which summarized daily weather is
#' associated with phenotypic traits across independent environments or
#' environment-years. It supports user-supplied weather, historical weather
#' queries from coordinates and season dates, flexible window and step sizes,
#' multiple weather summaries, diagnostics, ranking, and plots.
#'
#' @section Recommended input tables:
#' **Phenotypes:** one row per observation, with `environment_id`,
#' `genotype_id`, and numeric trait columns.
#'
#' **Environments:** one row per environment, with `environment_id`,
#' `latitude`, `longitude`, `season_start`, `season_end`, and optional
#' `altitude_m`.
#'
#' **Weather:** one row per environment and date, with `environment_id`, `date`,
#' and numeric daily weather columns.
#'
#' @section Main workflow:
#' 1. Create example file structures with [write_envwindow_templates()].
#' 2. Read phenotype and environment CSV files.
#' 3. Supply a daily weather CSV or download weather with
#'    [query_weather_data()].
#' 4. Run [scan_env_windows()] with selected `window_sizes` and `step`.
#' 5. Inspect [rank_env_windows()] and [diagnose_env_scan()].
#' 6. Visualize results with the package plotting functions.
#'
#' See `vignette("real-data-workflow", package = "envwindowr")` for a complete
#' example.
#'
#' @keywords internal
"_PACKAGE"
