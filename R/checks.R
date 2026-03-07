# Type ----

#' Check for Scalar
#' @param value User-provided value to be checked.
#' @param type Character scalar. The data type to check `value` against.
#' @return Error if `value` is not as expected, otherwise nothing.
#' @noRd
check_scalar <- function(value, type) {
  name <- deparse(substitute(value))

  is_type <- switch(
    type,
    character = is.character(value),
    logical = is.logical(value),
    numeric = is.numeric(value),
    stop("Supplied `type` is unsupported.", call. = FALSE)
  )

  if (!is_type || length(value) != 1L || is.na(value)) {
    stop(
      sprintf("`%s` must be a non-missing %s scalar.", name, type),
      call. = FALSE
    )
  }
}

#' Check for Character Scalar
#' @param value User-provided value to be checked.
#' @return Error if `value` is not as expected, otherwise nothing.
#' @noRd
check_character_scalar <- function(value) {
  check_scalar(value, "character")
}

#' Check for Logical Scalar
#' @param value User-provided value to be checked.
#' @return Error if `value` is not as expected, otherwise nothing.
#' @noRd
check_logical_scalar <- function(value) {
  check_scalar(value, "logical")
}

#' Check for Numeric Scalar
#' @param value User-provided value to be checked.
#' @return Error if `value` is not as expected, otherwise nothing.
#' @noRd
check_numeric_scalar <- function(value) {
  check_scalar(value, "numeric")
}

#' Check Structure of Geolocation Object
#' @param value User-provided value to be checked.
#' @return Error if `value` is not as expected, otherwise nothing.
#' @noRd
check_latlon_list <- function(value) {
  if (!is.list(value) || !all(c("lat", "lon") %in% names(value))) {
    stop("`latlon` must be a list with numeric `lat` and `lon`.", call. = FALSE)
  }

  check_numeric_scalar(value[["lat"]])
  check_numeric_scalar(value[["lon"]])
}

# Request ----

#' Check Request to an API
#' @param value User-provided value to be checked.
#' @param endpoint Character scalar. Expected API endpoint prefix.
#' @return Error if `value` is not as expected, otherwise nothing.
#' @noRd
check_request <- function(value, endpoint) {
  name <- deparse(substitute(value))

  if (!inherits(value, "httr2_request")) {
    stop(
      sprintf("`%s` must be a 'httr2_request' object.", name),
      call. = FALSE
    )
  }

  url <- value[["url"]]

  if (!is.character(url) || length(url) != 1L) {
    stop(sprintf("`%s` must contain a valid request URL.", name), call. = FALSE)
  }

  if (!startsWith(url, endpoint)) {
    stop(
      sprintf(
        "`%s` must target the API endpoint %s.",
        name,
        endpoint
      ),
      call. = FALSE
    )
  }

  user_agent <- value[["options"]][["useragent"]]

  if (is.null(user_agent) || !nzchar(user_agent)) {
    stop(
      sprintf("`%s` must contain a user-agent header.", name),
      call. = FALSE
    )
  }
}

# Response object ----

#' Check API Response
#' @param value User-provided value to be checked.
#' @return Error if `value` is not as expected, otherwise nothing.
#' @noRd
check_response <- function(value) {
  name <- deparse(substitute(value))

  if (!inherits(value, "httr2_response")) {
    stop(
      sprintf("`%s` must be a 'httr2_response' object.", name),
      call. = FALSE
    )
  }
}

# Response body ----

#' Check the Response Body from the 'postcodes.io' API
#' @param value User-provided value to be checked.
#' @return Error if `value` is not as expected, otherwise nothing.
#' @noRd
check_postcode_response_body <- function(value) {
  name <- deparse(substitute(value))

  if (!is.list(value)) {
    stop(sprintf("`%s` must be a list.", name), call. = FALSE)
  }

  result <- value[["result"]]

  if (!is.list(result)) {
    stop(
      sprintf("`%s` must contain a `result` list.", name),
      call. = FALSE
    )
  }

  lat <- result[["latitude"]]
  lon <- result[["longitude"]]

  if (is.null(lat) || is.null(lon)) {
    stop(
      sprintf(
        "`%s` must contain `latitude` and `longitude` under `result`.",
        name
      ),
      call. = FALSE
    )
  }

  check_numeric_scalar(lat)
  check_numeric_scalar(lon)
}

#' Check the Response Body from the 'Open-Meteo' API
#' @param value User-provided value to be checked.
#' @return Error if `value` is not as expected, otherwise nothing.
#' @noRd
check_weather_response_body <- function(value) {
  name <- deparse(substitute(value))

  if (!is.list(value)) {
    stop(sprintf("`%s` must be a list.", name), call. = FALSE)
  }

  required <- c("current", "hourly", "daily")
  missing <- setdiff(required, names(value))

  if (length(missing) > 0) {
    stop(
      sprintf(
        "`%s` must contain elements: %s.",
        name,
        paste(required, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  tz <- value[["timezone"]]

  if (!identical(tz, WEVA_TIMEZONE)) {
    stop(
      sprintf(
        "`%s` must have timezone '%s'.",
        name,
        WEVA_TIMEZONE
      ),
      call. = FALSE
    )
  }
}
