test_that("templates have the documented columns", {
  path <- file.path(tempdir(), paste0("envwindowr-", sample.int(1e6, 1)))
  files <- write_envwindow_templates(path, overwrite = TRUE)
  expect_true(all(file.exists(files)))

  phenotypes <- utils::read.csv(files[["phenotypes"]])
  environments <- utils::read.csv(files[["environments"]])
  weather <- utils::read.csv(files[["weather"]])

  expect_true(all(c("environment_id", "genotype_id") %in% names(phenotypes)))
  expect_true(all(c("environment_id", "latitude", "longitude",
                    "season_start", "season_end", "altitude_m") %in% names(environments)))
  expect_true(all(c("environment_id", "date") %in% names(weather)))
})

test_that("season_start and season_end are detected automatically", {
  periods <- data.frame(
    environment_id = c("E1", "E2"),
    season_start = c("2020-01-01", "2020-01-01"),
    season_end = c("2020-02-29", "2020-02-29")
  )
  windows <- make_env_windows(periods, window_sizes = 14, step = 7)
  expect_equal(windows$start_offset[1:3], c(0L, 7L, 14L))
  expect_true(all(windows$window_days == 14L))
})

test_that("weather query validates coordinates before internet access", {
  environments <- data.frame(
    environment_id = "E1",
    latitude = 100,
    longitude = -82,
    season_start = "2020-01-01",
    season_end = "2020-01-31"
  )
  expect_error(query_weather_data(environments, quiet = TRUE), "Latitude")
})
