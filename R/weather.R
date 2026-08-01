.open_meteo_daily_variables <- c(
  temperature = "temperature_2m_mean",
  temperature_min = "temperature_2m_min",
  temperature_max = "temperature_2m_max",
  precipitation = "precipitation_sum",
  rain = "rain_sum",
  snowfall = "snowfall_sum",
  precipitation_hours = "precipitation_hours",
  relative_humidity = "relative_humidity_2m_mean",
  relative_humidity_min = "relative_humidity_2m_min",
  relative_humidity_max = "relative_humidity_2m_max",
  solar_radiation = "shortwave_radiation_sum",
  evapotranspiration = "et0_fao_evapotranspiration",
  wind_speed = "wind_speed_10m_max",
  wind_gusts = "wind_gusts_10m_max"
)

#' Query daily historical weather for each environment
#'
#' @description
#' Downloads daily historical weather from the Open-Meteo Archive API using the
#' latitude, longitude, and season dates in an environment table. No API key is
#' required. The returned data can be supplied directly to
#' [scan_env_windows()].
#'
#' @param environments A data frame with one row per environment.
#' @param weather_vars Character vector of weather variables to download. See
#'   Details for supported friendly names. A named vector can map custom output
#'   names to Open-Meteo daily variable names.
#' @param environment_col Name of the environment identifier column.
#' @param latitude_col,longitude_col Names of coordinate columns in decimal
#'   degrees.
#' @param season_start_col,season_end_col Names of season date columns.
#' @param altitude_col Optional elevation column in meters. If present, it is
#'   passed to the API; missing values are ignored.
#' @param timezone Time-zone setting passed to Open-Meteo. The default, `"auto"`,
#'   resolves the local time zone from coordinates.
#' @param model Optional Open-Meteo historical model name, such as
#'   `"era5_land"`. Leave `NULL` to use the provider's default best-match data.
#' @param pause_seconds Optional pause between environment requests.
#' @param quiet Suppress progress messages.
#'
#' @details
#' Supported friendly names are `temperature`, `temperature_min`,
#' `temperature_max`, `precipitation`, `rain`, `snowfall`,
#' `precipitation_hours`, `relative_humidity`, `relative_humidity_min`,
#' `relative_humidity_max`, `solar_radiation`, `evapotranspiration`, `wind_speed`,
#' and `wind_gusts`.
#'
#' You can also request an Open-Meteo daily field directly, or use a named
#' vector to control the output name, for example
#' `c(tmean = "temperature_2m_mean", rain_mm = "precipitation_sum")`.
#'
#' The function makes one web request per environment. For reproducible work,
#' save the returned table to CSV and use the saved file in later analyses.
#' Open-Meteo data use is subject to the provider's terms and attribution
#' requirements.
#'
#' @return A tibble with `environment_id`, `date`, and one numeric column for
#'   each requested weather variable.
#'
#' @examples
#' environments <- data.frame(
#'   environment_id = "2019_Waldo",
#'   latitude = 29.795286,
#'   longitude = -82.129853,
#'   season_start = "2018-06-01",
#'   season_end = "2019-05-31",
#'   altitude_m = 30
#' )
#' \dontrun{
#' weather <- query_weather_data(
#'   environments,
#'   weather_vars = c("temperature", "precipitation", "solar_radiation")
#' )
#' utils::write.csv(weather, "weather.csv", row.names = FALSE)
#' }
#' @export
query_weather_data <- function(environments,
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
                               quiet = FALSE) {
  if (!is.data.frame(environments)) .abort("`environments` must be a data frame.")
  .assert_columns(environments,
                  c(environment_col, latitude_col, longitude_col,
                    season_start_col, season_end_col),
                  "Environment data")
  if (anyDuplicated(environments[[environment_col]]))
    .abort("Each environment must occur once in `environments`.")
  if (!is.numeric(environments[[latitude_col]]) || !is.numeric(environments[[longitude_col]]))
    .abort("Latitude and longitude columns must be numeric.")
  if (any(!is.finite(environments[[latitude_col]]) |
          environments[[latitude_col]] < -90 | environments[[latitude_col]] > 90))
    .abort("Latitude values must be between -90 and 90.")
  if (any(!is.finite(environments[[longitude_col]]) |
          environments[[longitude_col]] < -180 | environments[[longitude_col]] > 180))
    .abort("Longitude values must be between -180 and 180.")
  if (!is.character(weather_vars) || !length(weather_vars) || any(!nzchar(weather_vars)))
    .abort("`weather_vars` must contain at least one weather variable name.")
  if (!is.null(model) && (!is.character(model) || length(model) != 1L || !nzchar(model)))
    .abort("`model` must be NULL or one nonempty Open-Meteo model name.")
  if (!is.numeric(pause_seconds) || length(pause_seconds) != 1L ||
      !is.finite(pause_seconds) || pause_seconds < 0)
    .abort("`pause_seconds` must be one nonnegative number.")

  starts <- .as_date_strict(environments[[season_start_col]], "Season start column")
  ends <- .as_date_strict(environments[[season_end_col]], "Season end column")
  if (any(ends < starts)) .abort("Every season end must be on or after its season start.")

  output_names <- names(weather_vars)
  if (is.null(output_names)) output_names <- rep("", length(weather_vars))
  api_vars <- unname(weather_vars)
  friendly <- api_vars %in% names(.open_meteo_daily_variables)
  api_vars[friendly] <- unname(.open_meteo_daily_variables[api_vars[friendly]])
  output_names[!nzchar(output_names)] <- unname(weather_vars[!nzchar(output_names)])
  output_names[!nzchar(output_names)] <- api_vars[!nzchar(output_names)]
  if (anyDuplicated(output_names)) .abort("Requested weather output names must be unique.")

  env_ids <- as.character(environments[[environment_col]])
  results <- vector("list", nrow(environments))
  for (i in seq_len(nrow(environments))) {
    if (!quiet) message("Downloading weather for ", env_ids[i], " (", i, "/", nrow(environments), ")...")
    params <- c(
      latitude = format(environments[[latitude_col]][i], scientific = FALSE, trim = TRUE),
      longitude = format(environments[[longitude_col]][i], scientific = FALSE, trim = TRUE),
      start_date = format(starts[i], "%Y-%m-%d"),
      end_date = format(ends[i], "%Y-%m-%d"),
      daily = paste(unique(api_vars), collapse = ","),
      timezone = timezone
    )
    if (!is.null(model)) params <- c(params, models = model)
    if (altitude_col %in% names(environments)) {
      elevation <- suppressWarnings(as.numeric(environments[[altitude_col]][i]))
      if (is.finite(elevation)) params <- c(params, elevation = format(elevation, scientific = FALSE, trim = TRUE))
    }
    query <- paste0(names(params), "=", vapply(params, utils::URLencode, character(1), reserved = TRUE),
                    collapse = "&")
    url <- paste0("https://archive-api.open-meteo.com/v1/archive?", query)
    response <- tryCatch(jsonlite::fromJSON(url, simplifyVector = TRUE), error = identity)
    if (inherits(response, "error"))
      .abort("Weather query failed for environment '", env_ids[i], "': ", conditionMessage(response))
    if (isTRUE(response$error))
      .abort("Weather query failed for environment '", env_ids[i], "': ", response$reason %||% "unknown API error")
    if (is.null(response$daily) || is.null(response$daily$time))
      .abort("Weather query returned no daily data for environment '", env_ids[i], "'.")

    daily <- response$daily
    one <- tibble::tibble(date = .as_date_strict(daily$time, "Weather API dates"))
    one[[environment_col]] <- env_ids[i]
    one <- one[, c(environment_col, "date"), drop = FALSE]
    for (j in seq_along(api_vars)) {
      if (is.null(daily[[api_vars[j]]]))
        .abort("Weather API response did not contain requested variable '", api_vars[j], "'.")
      one[[output_names[j]]] <- as.numeric(daily[[api_vars[j]]])
    }
    results[[i]] <- one
    if (pause_seconds > 0 && i < nrow(environments)) Sys.sleep(pause_seconds)
  }
  dplyr::bind_rows(results)
}
