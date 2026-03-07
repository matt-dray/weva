#' Prepare a Weather Report
#'
#' Prepare data into a micro weather-report string with 'now' and 'later'
#' segments, and possibly a segment for today's minimum and maximum
#' temperatures. The output contains emoji weather representations and styled
#' text when printed with [cat] and if your terminal supports ANSI escape codes.
#'
#' @param weather_body A list. Response to a query from the 'Open-Meteo' API
#'     fetched with [get_weather].
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
#' \dontrun{
#' get_latlon("wc2n5du") |>
#'   get_weather() |>
#'   write_report(24L, TRUE, TRUE) |>
#'   cat()
#' }
#' @return Character scalar. A string containing a weather report.
#' @export
write_report <- function(
  weather_body,
  hours_to_forecast = 1L,
  show_datetimes = FALSE,
  show_extremes = FALSE
) {
  check_weather_response_body(weather_body)
  check_numeric_scalar(hours_to_forecast)
  check_logical_scalar(show_datetimes)
  check_logical_scalar(show_extremes)

  if (
    hours_to_forecast < 1 || hours_to_forecast != as.integer(hours_to_forecast)
  ) {
    stop(
      "`hours_to_forecast` must be a positive integer scalar.",
      call. = FALSE
    )
  }

  current <- weather_body[["current"]]
  hourly <- weather_body[["hourly"]]
  daily <- weather_body[["daily"]]
  units <- weather_body[["current_units"]][["temperature_2m"]]

  current_time_rounded <- current[["time"]] |>
    parse_time() |>
    lubridate::round_date("hour") |>
    format("%Y-%m-%dT%H:%M")

  current_index <- match(current_time_rounded, hourly[["time"]])

  if (is.na(current_index)) {
    stop("Unable to align current time with hourly forecast.", call. = FALSE)
  }

  hours_available <- length(hourly[["temperature_2m"]]) - current_index

  if (hours_to_forecast > hours_available) {
    stop(
      "`hours_to_forecast` exceeds available forecast horizon.",
      call. = FALSE
    )
  }

  index_later <- current_index + hours_to_forecast

  temp_now <- paste0(current[["temperature_2m"]], units)
  temp_later <- paste0(hourly[["temperature_2m"]][index_later], units)

  weather_now <- as_emoji(current[["weather_code"]])
  weather_later <- as_emoji(hourly[["weather_code"]][[index_later]])

  segment_now <- paste("now", style_text(temp_now, "yellow"), weather_now)
  segment_later <- paste(
    paste0("+", hours_to_forecast, "h"),
    style_text(temp_later, "magenta"),
    weather_later
  )

  if (show_datetimes) {
    dt_now <- parse_time(current[["time"]]) |> format("%Y-%m-%d %H:%M")
    dt_later <- parse_time(hourly[["time"]][[index_later]]) |>
      format("%Y-%m-%d %H:%M")

    segment_now <- paste(dt_now, style_text(temp_now, "yellow"), weather_now)

    segment_later <- paste(
      dt_later,
      style_text(temp_later, "magenta"),
      weather_later
    )
  }

  report <- paste(segment_now, "|", segment_later)

  if (show_extremes) {
    temp_min <- paste0(daily[["temperature_2m_min"]][1], units)
    temp_max <- paste0(daily[["temperature_2m_max"]][1], units)

    when <- "today"
    if (show_datetimes) {
      when <- parse_time(current[["time"]]) |> format("%Y-%m-%d")
    }

    extremes <- paste(
      "|",
      when,
      style_text(temp_min, "blue"),
      "to",
      style_text(temp_max, "red")
    )

    report <- paste(report, extremes)
  }

  paste0(report, "\n")
}

#' Parse Time String
#' @param datetime Character scalar. A datetime string in the expected
#'    'YYYY-MM-DDTHH:MM' format returned with [get_weather].
#' @return POSIXct datetime.
#' @noRd
parse_time <- function(datetime) {
  check_character_scalar(datetime)
  lubridate::ymd_hm(datetime, tz = WEVA_TIMEZONE)
}

#' Style Text with ANSI Escape Codes
#' @param string Character scalar. The text to add ANSI escape codes to.
#' @param colour Character scalar. A colour.
#' @return Character scalar.
#' @noRd
style_text <- function(string, colour) {
  lookup <- c(
    yellow = "\033[1;93m",
    magenta = "\033[1;95m",
    blue = "\033[1;94m",
    red = "\033[1;91m"
  )

  if (!colour %in% names(lookup)) {
    stop("Invalid `colour` supplied.", call. = FALSE)
  }

  paste0(lookup[colour], string, "\033[0m")
}

#' Convert Weather Codes into Emoji Representations
#' @param weather_code Integer scalar. A weather code.
#' @return Character scalar.
#' @noRd
as_emoji <- function(weather_code) {
  check_numeric_scalar(weather_code)

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
  SHRUG <- "\U0001F937" # if not found

  # Modifiers
  LIGHT <- "\U0001FAB6" # feather
  HEAVY <- "\U0001F3CB\uFE0F" # weightlifter
  ICE <- "\u2744\uFE0F" # snowflake

  emoji_lookup <- c(
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
    "99" = paste0(THUNDER, ICE)
  )

  emoji_lookup[as.character(weather_code)] %||% SHRUG
}
