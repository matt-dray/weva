#' Prepare Weather Report
#' @param response A list. Response to a query from the 'Open-Meteo' API,
#'     fetched with [get_weather].
#' @export
prepare_report <- function(response) {
  current <- response[["current"]]
  current_units <- response[["current_units"]]

  dt <- current[["time"]] |>
    as.POSIXlt(format = "%Y-%m-%dT%H:%M", tz = response[["timezone"]])

  temp <- paste(
    current[["temperature_2m"]],
    current_units[["temperature_2m"]]
  )

  # fmt: skip
  paste0(
    "It's \033[1;33m", temp, "\033[0m",
    " at ", format(dt, "%H:%M"), "ish",
    " on ", format(dt, "%Y-%m-%d")
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
      current = "temperature_2m"
    )
}

convert_postcode <- function(postcode) {
  info <- PostcodesioR::postcode_lookup(postcode)
  list(
    lat = info[["latitude"]],
    lon = info[["longitude"]]
  )
}
