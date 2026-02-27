#' Prepare Weather Report
#'
#' Prepare data into a micro weather-report string with 'now' and 'later'
#' segments, and possibly a segment for today's min- and max-temperature.
#' @param response A list. Response to a query from the 'Open-Meteo' API,
#'     fetched with [get_weather].
#' @param hours Integer scalar. How many hours after now for the 'later' report.
#' @param extremes Logical scalar. Show today's min/max temperatures?
#' @examples \dontrun{get_weather("wc2n5du") |> prepare_report(3L, TRUE)}
#' @return Character scalar.
#' @export
prepare_report <- function(response, hours, extremes) {
  if (!is.list(response)) {
    stop("Argument 'response' must be a list.", call. = FALSE)
  }
  if (
    !all(c("current", "hourly", "daily", "current_units") %in% names(response))
  ) {
    stop("Response is missing expected elements.", call. = FALSE)
  }
  if (
    !is.numeric(hours) ||
      length(hours) != 1 ||
      is.na(hours) ||
      hours < 0 ||
      hours != as.integer(hours)
  ) {
    stop("'hours' must be a non-negative integer scalar.", call. = FALSE)
  }
  if (!is.logical(extremes) || length(extremes) != 1) {
    stop("Argument 'extremes' must be logical scalar.", call. = FALSE)
  }

  current <- response[["current"]]
  hourly <- response[["hourly"]]

  if (hours > length(hourly[["temperature_2m"]])) {
    stop("Requested hour exceeds forecast range.", call. = FALSE)
  }

  units <- response[["current_units"]][["temperature_2m"]]
  temp_now <- paste0(current[["temperature_2m"]], units)
  temp_later <- paste0(hourly[["temperature_2m"]][[hours]], units)

  weather_now <- current[["weather_code"]] |> as_emoji()
  weather_later <- hourly[["weather_code"]][[hours]] |> as_emoji()

  # fmt: skip
  report <- paste0(
    "now \033[1;33m", temp_now, "\033[0m ", weather_now, " | ",
    "+", hours, "h \033[1;33m", temp_later, "\033[0m ", weather_later, " "
  )

  if (extremes) {
    daily <- response[["daily"]]
    temp_min <- paste0(daily[["temperature_2m_min"]][[1]], units)
    temp_max <- paste0(daily[["temperature_2m_max"]][[1]], units)

    report <- paste0(
      report,
      # fmt: skip
      paste0(
        "| today \033[1;94m", temp_min, "\033[0m to ", 
        "\033[1;91m", temp_max, "\033[0m "
      )
    )
  }

  report
}

#' Convert Weather Codes into Emoji Representations
#' @param weather_code Integer scalar. A weather code.
#' @return Character scalar.
#' @noRd
as_emoji <- function(weather_code) {
  if (!is.numeric(weather_code) || length(weather_code) != 1) {
    stop("Argument 'weather_code' must be numeric scalar.", call. = FALSE)
  }

  # Weather
  SUN <- "\u2600\uFE0F"
  MOSTLY_SUNNY <- "\U0001F324\uFE0F"
  PARTLY_CLOUDY <- "\u26C5\uFE0F"
  CLOUD <- "\u2601\uFE0F"
  FOG <- "\U0001F32B\uFE0F"
  DRIZZLE <- "\U0001F327\uFE0F"
  SNOW <- "\U0001F328\uFE0F"
  THUNDER <- "\u26C8\uFE0F"
  SHOWER <- "\U0001F6BF"
  RAIN <- "\U0001F4A6"
  SHRUG <- "\U0001F937"

  # Modifiers
  LIGHT <- "\U0001FAB6" # feather
  HEAVY <- "\U0001F3CB\uFE0F" # weightlifter
  ICE <- "\u2744\uFE0F" # snowflake

  switch(
    as.character(weather_code),

    "0" = SUN,
    "1" = MOSTLY_SUNNY,
    "2" = PARTLY_CLOUDY,
    "3" = CLOUD,

    "45" = FOG,
    "48" = paste0(FOG, ICE),

    "51" = paste0(DRIZZLE, LIGHT),
    "53" = DRIZZLE,
    "55" = paste0(DRIZZLE, HEAVY),
    "56" = paste0(DRIZZLE, ICE, LIGHT),
    "57" = paste0(DRIZZLE, ICE),

    "61" = paste0(RAIN, LIGHT),
    "63" = RAIN,
    "65" = paste0(RAIN, HEAVY),
    "66" = paste0(RAIN, ICE, LIGHT),
    "67" = paste0(RAIN, ICE),

    "80" = paste0(SHOWER, LIGHT),
    "81" = SHOWER,
    "82" = paste0(SHOWER, HEAVY),

    "71" = paste0(SNOW, LIGHT),
    "73" = SNOW,
    "75" = paste0(SNOW, HEAVY),
    "77" = SNOW,
    "85" = paste0(SNOW, LIGHT),
    "86" = SNOW,

    "95" = THUNDER,
    "96" = paste0(THUNDER, LIGHT),
    "99" = paste0(THUNDER, ICE),

    SHRUG # otherwise
  )
}

#' Get Weather Data from the 'Open-Meteo' API
#'
#' Get a restricted set of information from the 'Open-Meteo' API for a valid UK
#' postcode that is interpretable by the 'postcodes.io' API.
#' @param postcode Character scalar. A UK postcode. Defaults to finding
#'     the environment variable `WEVA_POSTCODE`, otherwise Trafalgar Square
#'     (WC2N5DU).
#' @details
#' - Fixed for the `GMT` timezone for three `forecast_days`.
#' - Data fetched from the 'Open-Meteo' API:
#'   - current `temperature_2m` and `weather_code`
#'   - hourly `temperature_2m` and `weather_code`
#'   - daily `temperature_2m_min` and `temperature_2m_max`
#' - Attempts to contact the API time out after 10 s with 3 retries
#' @return A list.
#' @examples \dontrun{get_weather("wc2n5du") }
#' @export
get_weather <- function(postcode) {
  if (!is.character(postcode) || length(postcode) != 1) {
    stop("Argument 'postcode' must be character scalar.", call. = FALSE)
  }

  req <- build_request(postcode = postcode) |>
    httr2::req_timeout(10) |>
    httr2::req_retry(max_tries = 3)

  resp <- httr2::req_perform(req)
  httr2::resp_check_status(resp)

  httr2::resp_body_json(resp)
}

#' Build an API Query
#' @param url Character scalar. The base URL for the API service.
#' @param postcode Character scalar. A UK postcode.
#' @return A 'httr2_request' object.
#' @noRd
build_request <- function(
  url = "https://api.open-meteo.com/v1/forecast",
  postcode
) {
  if (!is.character(url) || length(url) != 1) {
    stop("Argument 'url' must be character scalar.", call. = FALSE)
  }
  if (!is.character(postcode) || length(postcode) != 1) {
    stop("Argument 'postcode' must be character scalar.", call. = FALSE)
  }

  geo <- convert_postcode(postcode)

  httr2::request(url) |>
    httr2::req_url_query(
      latitude = geo[["lat"]],
      longitude = geo[["lon"]],
      timezone = "GMT",
      forecast_days = 3L,
      current = paste("temperature_2m", "weather_code", sep = ","),
      hourly = paste("temperature_2m", "weather_code", sep = ","),
      daily = paste("temperature_2m_min", "temperature_2m_max", sep = ",")
    ) |>
    httr2::req_user_agent("weva (http://github.com/matt-dray/weva)")
}

#' Convert a Postcode to Latitude and Longitude
#' @param postcode Character scalar. A UK postcode.
#' @return A list with two named numeric values ('lat' and 'lon').
#' @noRd
convert_postcode <- function(postcode) {
  if (!is.character(postcode) || length(postcode) != 1) {
    stop("Argument 'postcode' must be character scalar.", call. = FALSE)
  }

  lookup <- PostcodesioR::postcode_lookup(postcode)

  list(
    lat = lookup[["latitude"]],
    lon = lookup[["longitude"]]
  )
}
