#' Simulate example weather, phenotype, and environment data
#'
#' @description
#' Creates a reproducible multi-environment dataset with a known temperature
#' signal. The output follows the same structure recommended for real data:
#' phenotypes contain environment and genotype identifiers, environments contain
#' season dates and coordinates, and weather contains one row per day.
#'
#' @param n_environments Number of independent environments or environment-years.
#' @param n_days Number of weather days per environment.
#' @param n_genotypes Number of genotypes observed in every environment.
#' @param signal_start,signal_end True temperature-signal window offsets relative
#'   to season start. If `signal_end` extends beyond `n_days`, the signal is
#'   truncated at the final simulated day.
#' @param seed Random seed.
#'
#' @return A list containing:
#' 
#' * `weather`: daily temperature and rainfall;
#' * `traits` and `phenotypes`: identical phenotype tables containing
#'   `environment_id`, `genotype_id`, `yield`, and `quality`;
#' * `periods` and `environments`: identical environment tables containing
#'   season dates, coordinates, and altitude; and
#' * `truth`: the simulated weather variable and signal window.
#'
#' @examples
#' dat <- simulate_env_window_data(
#'   n_environments = 12,
#'   n_days = 100,
#'   n_genotypes = 5,
#'   signal_start = 30,
#'   signal_end = 55
#' )
#' head(dat$phenotypes)
#' head(dat$environments)
#' head(dat$weather)
#' @export
simulate_env_window_data <- function(n_environments = 24L, n_days = 180L,
                                     n_genotypes = 8L,
                                     signal_start = 70L, signal_end = 105L,
                                     seed = 1L) {
  if (length(n_environments) != 1L || !is.finite(n_environments) || n_environments < 2L)
    .abort("`n_environments` must be a single integer of at least 2.")
  if (length(n_days) != 1L || !is.finite(n_days) || n_days < 2L)
    .abort("`n_days` must be a single integer of at least 2.")
  if (length(n_genotypes) != 1L || !is.finite(n_genotypes) || n_genotypes < 1L)
    .abort("`n_genotypes` must be a single positive integer.")
  if (length(signal_start) != 1L || length(signal_end) != 1L ||
      !is.finite(signal_start) || !is.finite(signal_end) ||
      signal_start < 0L || signal_end < signal_start || signal_start >= n_days)
    .abort("`signal_start` and `signal_end` must define a nonempty window beginning within the simulated period.")

  n_environments <- as.integer(n_environments)
  n_days <- as.integer(n_days)
  n_genotypes <- as.integer(n_genotypes)
  signal_start <- as.integer(signal_start)
  signal_end <- min(as.integer(signal_end), n_days - 1L)

  set.seed(seed)
  env <- sprintf("E%02d", seq_len(n_environments))
  genotypes <- sprintf("G%03d", seq_len(n_genotypes))
  starts <- as.Date("2020-01-01") + sample(0:1200, n_environments, replace = TRUE)
  latitudes <- stats::runif(n_environments, 27, 31)
  longitudes <- stats::runif(n_environments, -83, -80)
  periods <- tibble::tibble(
    environment_id = env,
    latitude = latitudes,
    longitude = longitudes,
    season_start = starts,
    season_end = starts + n_days - 1L,
    altitude_m = round(stats::runif(n_environments, 5, 80), 1),
    start_date = starts,
    end_date = starts + n_days - 1L
  )
  weather <- dplyr::bind_rows(lapply(seq_along(env), function(i) {
    day <- 0:(n_days - 1L)
    base <- stats::rnorm(1, 20, 3)
    tibble::tibble(
      environment_id = env[i],
      date = starts[i] + day,
      temperature = base + 6 * sin(2 * pi * day / n_days) + stats::rnorm(n_days, 0, 1.5),
      rainfall = stats::rgamma(n_days, shape = 0.7, scale = 4)
    )
  }))
  signal <- weather |>
    dplyr::left_join(periods[, c("environment_id", "start_date")], by = "environment_id") |>
    dplyr::mutate(offset = as.integer(.data$date - .data$start_date)) |>
    dplyr::filter(.data$offset >= signal_start, .data$offset <= signal_end) |>
    dplyr::group_by(.data$environment_id) |>
    dplyr::summarise(signal = mean(.data$temperature), .groups = "drop")
  z <- as.numeric(scale(signal$signal))
  env_signal <- tibble::tibble(environment_id = signal$environment_id, z = z)
  genotype_effect_yield <- stats::rnorm(n_genotypes, 0, 0.8)
  genotype_effect_quality <- stats::rnorm(n_genotypes, 0, 0.5)
  traits <- tidyr::crossing(environment_id = env, genotype_id = genotypes) |>
    dplyr::left_join(env_signal, by = "environment_id") |>
    dplyr::mutate(
      yield = 10 + 2.2 * .data$z +
        genotype_effect_yield[match(.data$genotype_id, genotypes)] +
        stats::rnorm(dplyr::n(), 0, 1.2),
      quality = 5 - 1.4 * .data$z +
        genotype_effect_quality[match(.data$genotype_id, genotypes)] +
        stats::rnorm(dplyr::n(), 0, 1.1)
    ) |>
    dplyr::select(-dplyr::all_of("z"))
  list(weather = weather, traits = traits, phenotypes = traits,
       periods = periods, environments = periods,
       truth = list(weather_var = "temperature", start_offset = signal_start,
                    end_offset = signal_end))
}
