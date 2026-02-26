#' Prepare Weather Report
#' @param response A list. Response to a query from the 'Open-Meteo' API,
#'     fetched with [get_weather].
#' @param hours Integer scalar. How many hours after now for the 'later' report.
#' @param extremes Logical scalar. Show today's min/max temperatures?
#' @export
prepare_report <- function(response, hours, extremes) {
  current <- response[["current"]]
  hourly <- response[["hourly"]]

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

as_emoji <- function(weather_code) {
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

#' Get Weather Response from 'Open-Meteo'
#' @param postcode Character scalar. A UK postcode.
#' @export
get_weather <- function(postcode) {
  url <- "https://api.open-meteo.com/v1/forecast"
  req <- build_request(url, postcode)
  resp <- httr2::req_perform(req)
  resp |> httr2::resp_body_json()
}

build_request <- function(url, postcode) {
  geo <- convert_postcode(postcode)

  httr2::request(url) |>
    httr2::req_url_query(
      latitude = geo[["lat"]],
      longitude = geo[["lon"]],
      timezone = "GMT",
      current = paste("temperature_2m", "weather_code", sep = ","),
      hourly = paste("temperature_2m", "weather_code", sep = ","),
      daily = paste("temperature_2m_min", "temperature_2m_max", sep = ",")
    ) |>
    httr2::req_user_agent("weva (http://github.com/matt-dray/weva)")
}

convert_postcode <- function(postcode) {
  info <- PostcodesioR::postcode_lookup(postcode)
  list(
    lat = info[["latitude"]],
    lon = info[["longitude"]]
  )
}
