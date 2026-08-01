#' Validate weather, phenotype, and environment inputs
#'
#' @description
#' Checks the three tables used by [scan_env_windows()], normalizes dates, and
#' calculates a day offset for every weather observation relative to the start
#' of its environment-specific season.
#'
#' @param weather Daily weather data with one row per environment and date.
#' @param traits Phenotype data with an environment identifier and numeric trait
#'   columns. A `genotype_id` column and other metadata columns are allowed.
#' @param periods Environment table with one row per environment and season
#'   start/end dates. Latitude, longitude, and altitude columns are allowed but
#'   are not required for validation unless weather will be queried.
#' @param environment_col Environment identifier shared by all inputs.
#' @param date_col Date column in `weather`.
#' @param period_start_col Start-date column in `periods`. When the default
#'   `start_date` is absent, `season_start` is detected automatically.
#' @param period_end_col End-date column in `periods`. When the default
#'   `end_date` is absent, `season_end` is detected automatically.
#' @param weather_vars Numeric weather columns to validate.
#' @param trait_vars Numeric phenotype columns to validate.
#'
#' @details
#' The function rejects duplicate environment-date weather records because each
#' daily value must be unique before a window summary is calculated. If raw
#' weather contains multiple observations per day, aggregate those records first.
#'
#' Dates may be `Date` objects or character strings in `YYYY-MM-DD`,
#' `MM/DD/YYYY`, or `MM/DD/YY` format. ISO `YYYY-MM-DD` is recommended for CSV
#' files because it is unambiguous.
#'
#' @return A list containing validated copies of `weather`, `traits`, and
#'   `periods`, plus the resolved start- and end-column names. The weather table
#'   includes an internal `.day_offset` column.
#'
#' @examples
#' dat <- simulate_env_window_data(n_environments = 8, n_days = 90)
#' checked <- validate_env_inputs(
#'   weather = dat$weather,
#'   traits = dat$traits,
#'   periods = dat$periods,
#'   weather_vars = c("temperature", "rainfall"),
#'   trait_vars = c("yield", "quality")
#' )
#' names(checked)
#' head(checked$weather$.day_offset)
#' @export
validate_env_inputs <- function(weather, traits, periods,
                                environment_col = "environment_id",
                                date_col = "date",
                                period_start_col = "start_date",
                                period_end_col = "end_date",
                                weather_vars,
                                trait_vars) {
  if (!is.data.frame(weather) || !is.data.frame(traits) || !is.data.frame(periods))
    .abort("`weather`, `traits`, and `periods` must be data frames.")
  resolved <- .resolve_period_columns(periods, period_start_col, period_end_col)
  period_start_col <- resolved$start
  period_end_col <- resolved$end
  .assert_columns(weather, c(environment_col, date_col, weather_vars), "Weather data")
  .assert_columns(traits, c(environment_col, trait_vars), "Trait data")
  .assert_columns(periods, c(environment_col, period_start_col, period_end_col), "Period data")
  if (!length(weather_vars) || !length(trait_vars)) .abort("Specify at least one weather variable and one trait.")
  if (anyDuplicated(periods[[environment_col]])) .abort("Each environment must occur once in `periods`.")
  bad_w <- weather_vars[!vapply(weather[weather_vars], is.numeric, logical(1))]
  bad_t <- trait_vars[!vapply(traits[trait_vars], is.numeric, logical(1))]
  if (length(bad_w)) .abort("Weather variables must be numeric: ", paste(bad_w, collapse = ", "), ".")
  if (length(bad_t)) .abort("Trait variables must be numeric: ", paste(bad_t, collapse = ", "), ".")
  weather[[date_col]] <- .as_date_strict(weather[[date_col]], "Weather date column")
  periods[[period_start_col]] <- .as_date_strict(periods[[period_start_col]], "Period start column")
  periods[[period_end_col]] <- .as_date_strict(periods[[period_end_col]], "Period end column")
  if (any(periods[[period_end_col]] < periods[[period_start_col]]))
    .abort("Every period end date must be on or after its start date.")
  weather[[environment_col]] <- as.character(weather[[environment_col]])
  traits[[environment_col]] <- as.character(traits[[environment_col]])
  periods[[environment_col]] <- as.character(periods[[environment_col]])
  p_env <- unique(periods[[environment_col]])
  missing_weather <- setdiff(p_env, unique(weather[[environment_col]]))
  missing_traits <- setdiff(p_env, unique(traits[[environment_col]]))
  if (length(missing_weather)) .abort("No weather rows for environment(s): ", paste(missing_weather, collapse = ", "), ".")
  if (length(missing_traits)) .abort("No trait rows for environment(s): ", paste(missing_traits, collapse = ", "), ".")
  duplicate_days <- weather |>
    dplyr::count(.data[[environment_col]], .data[[date_col]], name = "n") |>
    dplyr::filter(.data$n > 1L)
  if (nrow(duplicate_days)) .abort("Weather has duplicate environment-date rows. Aggregate them before scanning.")
  weather <- weather |>
    dplyr::inner_join(periods[, c(environment_col, period_start_col, period_end_col)], by = environment_col) |>
    dplyr::mutate(.day_offset = as.integer(.data[[date_col]] - .data[[period_start_col]])) |>
    dplyr::filter(.data[[date_col]] >= .data[[period_start_col]],
                  .data[[date_col]] <= .data[[period_end_col]])
  list(weather = weather, traits = traits, periods = periods,
       period_start_col = period_start_col, period_end_col = period_end_col)
}
