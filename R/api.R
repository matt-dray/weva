#' Prepare a Weather Report
#'
#' Prepare data into a micro weather-report string with 'now' and 'later'
#' segments, and possibly a segment for today's minimum and maximum
#' temperatures. The output contains emoji weather representations and styled
#' text when printed with [cat] and if your terminal supports ANSI escape codes.
#'
#' @param response A list. Response to a query from the 'Open-Meteo' API fetched
#'     with [get_weather].
#' @param hours_to_forecast Integer scalar. How many hours after now for the
#'     'later' segment of the report. Default is `1L` hour. See details.
#' @param show_datetimes Logical scalar. Show datetimes in each segment instead
#'     of explanatory text? Default is `FALSE` (do not show). See details.
#' @param show_extremes Logical scalar. Show a segment with today's minimum and
#'     maximum temperatures? Default is `FALSE` (do not show).
#' @details
#' You cannot request a number of `hours_to_forecast` beyond what has been
#' returned from the 'Open-Meteo' API, which is three days inclusive of today.
#' That's a maximum of 72 hours, but that value will shrink over the course of
#' today.
#'
#' To return the forecast for later, the current time according to 'Open-Meteo'
#' (nearest quarter-hour) is rounded to the nearest top-of-the-hour and the
#' `hours_to_forecast` supplied by the user is added. The weather for the
#' calculated hour is returned.
#'
#' For clarity, set `show_datetimes = TRUE` to expose these datetimes in the
#' 'now' and 'later' segments.
#' @examples
#' \dontrun{get_weather("wc2n5du") |> prepare_report(24L, TRUE, TRUE) |> cat()}
#' @return Character scalar. A string containing a weather report.
#' @export
prepare_report <- function(
  response,
  hours_to_forecast = 1L,
  show_datetimes = FALSE,
  show_extremes = FALSE
) {
  if (!is.list(response)) {
    stop("Argument 'response' must be a list.", call. = FALSE)
  }
  if (
    !all(c("current", "hourly", "daily", "current_units") %in% names(response))
  ) {
    stop("Response is missing expected elements.", call. = FALSE)
  }

  if (
    !is.numeric(hours_to_forecast) ||
      length(hours_to_forecast) != 1 ||
      is.na(hours_to_forecast) ||
      hours_to_forecast < 1 ||
      hours_to_forecast != as.integer(hours_to_forecast)
  ) {
    stop(
      "'hours_to_forecast' must be a positive non-zero integer scalar.",
      call. = FALSE
    )
  }

  if (!is.logical(show_extremes) || length(show_extremes) != 1) {
    stop("Argument 'show_extremes' must be logical scalar.", call. = FALSE)
  }

  current <- response[["current"]]
  hourly <- response[["hourly"]]
  units <- response[["current_units"]][["temperature_2m"]]

  current_time_rounded <- current[["time"]] |>
    lubridate::ymd_hm(tz = "Europe/London") |>
    lubridate::round_date("hour") |>
    format("%Y-%m-%dT%H:%M")
  current_index <- match(current_time_rounded, hourly[["time"]])

  hours_available <- length(hourly[["temperature_2m"]]) - current_index
  if (hours_to_forecast > hours_available) {
    stop(
      "Argument 'hours_to_forecast' exceeds limit (three days inclusive of today).",
      call. = FALSE
    )
  }

  temp_now <- paste0(current[["temperature_2m"]], units)
  index_later <- current_index + hours_to_forecast
  temp_later <- paste0(hourly[["temperature_2m"]][[index_later]], units)

  weather_now <- current[["weather_code"]] |> as_emoji()
  weather_later <- hourly[["weather_code"]][[index_later]] |> as_emoji()

  # fmt: skip
  report <- paste0(
    "now \033[1;93m", temp_now, "\033[0m ", weather_now, " | ",
    "+", hours_to_forecast, "h \033[1;95m", temp_later, "\033[0m ", weather_later, " "
  )

  if (show_datetimes) {
    format_string <- "%Y-%m-%d %H:%M"
    dt_now <- current[["time"]] |>
      lubridate::ymd_hm(tz = "Europe/London") |>
      format(format_string)
    dt_later <- hourly[["time"]][[index_later]] |>
      lubridate::ymd_hm(tz = "Europe/London") |>
      format(format_string)

    # fmt: skip
    report <- paste0(
      dt_now, " \033[1;93m", temp_now, "\033[0m ", weather_now, " | ",
      dt_later, " \033[1;95m", temp_later, "\033[0m ", weather_later, " "
    )
  }

  if (show_extremes) {
    daily <- response[["daily"]]
    temp_min <- paste0(daily[["temperature_2m_min"]][[1]], units)
    temp_max <- paste0(daily[["temperature_2m_max"]][[1]], units)

    when <- ifelse(
      show_datetimes,
      current[["time"]] |>
        lubridate::ymd_hm(tz = "Europe/London") |>
        format("%Y-%m-%d"),
      "today"
    )

    report <- paste0(
      report,
      # fmt: skip
      paste0(
        "| ", when, " \033[1;94m", temp_min, "\033[0m to ", 
        "\033[1;91m", temp_max, "\033[0m "
      )
    )
  }

  paste0(report, "\n")
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
#'
#' @param postcode Character scalar. A valid UK postcode.
#' @details
#' - Fixed for timezone Europe/London.
#' - Fixed to a three-day forecast (inclusive of today).
#' - Data fetched from the 'Open-Meteo' API:
#'   - current `temperature_2m` and `weather_code`
#'   - hourly `temperature_2m` and `weather_code`
#'   - daily `temperature_2m_min` and `temperature_2m_max`
#' @return A list.
#' @examples \dontrun{get_weather("wc2n5du")}
#' @export
get_weather <- function(postcode) {
  if (!is.character(postcode) || length(postcode) != 1) {
    stop("Argument 'postcode' must be character scalar.", call. = FALSE)
  }

  req <- build_request(postcode = postcode)
  resp <- httr2::req_perform(req)
  resp |> httr2::resp_body_json()
}

#' Build an API Query
#' @param url Character scalar. The base URL for the API service.
#' @param postcode Character scalar. A UK postcode.
#' @return A 'httr2_request' object.
#' @noRd
build_request <- function(postcode) {
  if (!is.character(postcode) || length(postcode) != 1) {
    stop("Argument 'postcode' must be character scalar.", call. = FALSE)
  }

  geo <- convert_postcode(postcode)

  httr2::request("https://api.open-meteo.com/v1/forecast") |>
    httr2::req_url_query(
      latitude = geo[["lat"]],
      longitude = geo[["lon"]],
      timezone = "Europe/London",
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
