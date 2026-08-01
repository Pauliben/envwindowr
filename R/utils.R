`%||%` <- function(x, y) if (is.null(x)) y else x

.abort <- function(..., call = rlang::caller_env()) {
  rlang::abort(paste0(...), call = call)
}

.warn <- function(..., call = rlang::caller_env()) {
  rlang::warn(paste0(...), call = call)
}

.assert_columns <- function(data, columns, label) {
  missing <- setdiff(columns, names(data))
  if (length(missing)) {
    .abort(label, " is missing required column(s): ", paste(missing, collapse = ", "), ".")
  }
}

.as_date_strict <- function(x, label) {
  if (inherits(x, "Date")) return(x)
  if (inherits(x, c("POSIXct", "POSIXlt"))) return(as.Date(x))
  if (is.numeric(x)) {
    .abort(label, " is numeric. Convert it to Date or character before use.")
  }

  values <- trimws(as.character(x))
  out <- as.Date(rep(NA_character_, length(values)))
  formats <- c("%Y-%m-%d", "%m/%d/%Y", "%m/%d/%y", "%Y/%m/%d")
  for (fmt in formats) {
    missing <- is.na(out) & !is.na(values) & nzchar(values)
    if (!any(missing)) break
    out[missing] <- as.Date(values[missing], format = fmt)
  }
  if (anyNA(out)) {
    bad <- unique(values[is.na(out)])
    bad <- bad[seq_len(min(length(bad), 3L))]
    .abort(label, " contains invalid dates: ", paste(bad, collapse = ", "),
           ". Use Date values, YYYY-MM-DD, or MM/DD/YYYY strings.")
  }
  out
}

.resolve_period_columns <- function(periods, period_start_col, period_end_col) {
  if (!period_start_col %in% names(periods) && identical(period_start_col, "start_date") &&
      "season_start" %in% names(periods)) {
    period_start_col <- "season_start"
  }
  if (!period_end_col %in% names(periods) && identical(period_end_col, "end_date") &&
      "season_end" %in% names(periods)) {
    period_end_col <- "season_end"
  }
  list(start = period_start_col, end = period_end_col)
}

.mean_na <- function(x) if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)

.safe_stat <- function(x, statistic) {
  x <- x[is.finite(x)]
  if (!length(x)) return(NA_real_)
  if (is.function(statistic)) return(as.numeric(statistic(x)))
  switch(tolower(statistic),
    mean = mean(x), sum = sum(x), min = min(x), max = max(x),
    median = stats::median(x), sd = if (length(x) > 1L) stats::sd(x) else NA_real_,
    .abort("Unsupported summary statistic '", statistic,
           "'. Use mean, sum, min, max, median, sd, or a function.")
  )
}

.safe_cor <- function(x, y, method, min_pairs) {
  keep <- is.finite(x) & is.finite(y)
  x <- x[keep]; y <- y[keep]; n <- length(x)
  sx <- if (n > 1L) stats::sd(x) else NA_real_
  sy <- if (n > 1L) stats::sd(y) else NA_real_
  result <- function(r = NA_real_, p = NA_real_, status) {
    tibble::tibble(correlation = r, p_value = p, n_pairs = n,
                   environmental_sd = sx, trait_sd = sy, status = status)
  }
  if (n < min_pairs) return(result(status = "too_few_pairs"))
  tol <- sqrt(.Machine$double.eps)
  if (!is.finite(sx) || sx <= tol) return(result(status = "zero_environmental_variance"))
  if (!is.finite(sy) || sy <= tol) return(result(status = "zero_trait_variance"))
  test <- tryCatch(suppressWarnings(stats::cor.test(x, y, method = method, exact = FALSE)),
                   error = identity)
  if (inherits(test, "error")) return(result(status = paste0("correlation_error: ", conditionMessage(test))))
  result(unname(test$estimate), test$p.value, "ok")
}
