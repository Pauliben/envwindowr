#' Write example input files for a real-data analysis
#'
#' @description
#' Creates CSV files that show the column structure expected by `envwindowr`.
#' The phenotype file contains one row per environment-genotype observation,
#' the environment file contains location and season metadata, and the optional
#' weather file shows the required daily-weather structure.
#'
#' @param path Directory where the files will be written.
#' @param overwrite Logical. Overwrite existing files with the same names?
#' @param include_weather Logical. Also write `weather_template.csv`?
#' @param example_rows Logical. Include example rows. When `FALSE`, only column
#'   headers are written.
#'
#' @details
#' The phenotype file always includes `environment_id` and `genotype_id`.
#' Replace the example trait columns with any numeric traits relevant to your
#' study. The environment file requires `environment_id`, `latitude`,
#' `longitude`, `season_start`, and `season_end`; `altitude_m` is optional.
#'
#' The weather file must contain one row per environment and date, with numeric
#' weather variables in additional columns. You may provide this file yourself
#' or create it from the environment table with [query_weather_data()].
#'
#' @return Invisibly returns a named character vector containing the paths of
#'   the files that were written.
#'
#' @examples
#' out <- file.path(tempdir(), "envwindowr-inputs")
#' write_envwindow_templates(out, overwrite = TRUE)
#' list.files(out)
#' @export
write_envwindow_templates <- function(path = ".", overwrite = FALSE,
                                      include_weather = TRUE,
                                      example_rows = TRUE) {
  if (!is.character(path) || length(path) != 1L || !nzchar(path))
    .abort("`path` must be one nonempty directory path.")
  if (!dir.exists(path) && !dir.create(path, recursive = TRUE))
    .abort("Could not create directory: ", path)

  if (isTRUE(example_rows)) {
    phenotypes <- data.frame(
      environment_id = c("2018_Waldo", "2018_Waldo", "2019_Waldo", "2019_Waldo",
                         "2018_Citra", "2018_Citra"),
      genotype_id = c("G001", "G002", "G001", "G002", "G001", "G002"),
      weight = c(2.51, 2.43, 2.65, 2.39, 2.34, 2.29),
      brix = c(11.2, 10.8, 11.5, 10.6, 10.9, 10.4),
      tta = c(0.71, 0.76, 0.68, 0.79, 0.74, 0.82),
      firmness = c(185, 176, 190, 172, 181, 169),
      size = c(16.2, 15.8, 16.7, 15.5, 15.9, 15.1),
      stringsAsFactors = FALSE
    )
    environments <- data.frame(
      environment_id = c("2018_Waldo", "2019_Waldo", "2018_Citra"),
      latitude = c(29.795286, 29.795286, 29.410918),
      longitude = c(-82.129853, -82.129853, -82.143678),
      season_start = c("2017-06-01", "2018-06-01", "2017-06-01"),
      season_end = c("2018-05-31", "2019-05-31", "2018-05-31"),
      altitude_m = c(30, 30, 30),
      stringsAsFactors = FALSE
    )
    weather <- data.frame(
      environment_id = rep("2018_Waldo", 3),
      date = c("2017-06-01", "2017-06-02", "2017-06-03"),
      temperature = c(25.1, 25.8, 26.0),
      precipitation = c(0.0, 4.2, 0.7),
      solar_radiation = c(20.3, 17.8, 21.1),
      stringsAsFactors = FALSE
    )
  } else {
    phenotypes <- data.frame(environment_id = character(), genotype_id = character(),
                             trait_1 = numeric(), trait_2 = numeric())
    environments <- data.frame(environment_id = character(), latitude = numeric(),
                               longitude = numeric(), season_start = character(),
                               season_end = character(), altitude_m = numeric())
    weather <- data.frame(environment_id = character(), date = character(),
                          temperature = numeric(), precipitation = numeric())
  }

  files <- c(
    phenotypes = file.path(path, "phenotypes_template.csv"),
    environments = file.path(path, "environments_template.csv")
  )
  if (isTRUE(include_weather)) files <- c(files, weather = file.path(path, "weather_template.csv"))

  existing <- files[file.exists(files)]
  if (length(existing) && !isTRUE(overwrite)) {
    .abort("File(s) already exist: ", paste(basename(existing), collapse = ", "),
           ". Set `overwrite = TRUE` to replace them.")
  }

  utils::write.csv(phenotypes, files[["phenotypes"]], row.names = FALSE, na = "")
  utils::write.csv(environments, files[["environments"]], row.names = FALSE, na = "")
  if (isTRUE(include_weather))
    utils::write.csv(weather, files[["weather"]], row.names = FALSE, na = "")
  invisible(files)
}
