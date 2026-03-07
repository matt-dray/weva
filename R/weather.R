#' Get Response from the 'Open-Meteo' API and Parse It
#' @param latlon A list with two numeric elements: 'lat' and 'lon'. Returned by
#'     [get_latlon].
#' @return If the API call is successful, a list with 13 elements, including
#'     `current`, `hourly` and `daily`.
#' @examples
#' \dontrun{
#' latlon <- get_latlon("WC2N 5DU")
#' get_weather(latlon)
#' }
#' @export
get_weather <- function(latlon) {
  check_latlon_list(latlon)

  request <- build_weather_request(latlon)
  response <- perform_weather_request(request)
  parse_weather_response(response)
}

#' Build an API Request for 'Open-Meteo'
#' @param latlon A list with two numeric elements: 'lat' and 'lon'. Returned by
#'     [get_latlon].
#' @return A 'httr2_request' object.
#' @noRd
build_weather_request <- function(latlon) {
  httr2::request(OPENMETEO_ENDPOINT) |>
    httr2::req_url_query(
      latitude = latlon[["lat"]],
      longitude = latlon[["lon"]],
      timezone = WEVA_TIMEZONE,
      forecast_days = 3L,
      current = "temperature_2m,weather_code",
      hourly = "temperature_2m,weather_code",
      daily = "temperature_2m_min,temperature_2m_max"
    ) |>
    httr2::req_user_agent(generate_user_agent())
}

#' Perform 'Open-Meteo' API Request
#' @param request Class 'httr2_request'. A request object for 'Open-Meteo'
#'     generated with [build_weather_request].
#' @return Class 'httr2_response'.
#' @noRd
perform_weather_request <- function(request) {
  check_request(request, OPENMETEO_ENDPOINT)

  request |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_error() |> # on 4xx and 5xx
    httr2::req_timeout(10) |>
    httr2::req_perform()
}

#' Parse Response from 'Open-Meteo' API Request
#' @param response A 'httr2_response'. Response from 'Open-Meteo' API after
#'     sending a request with [perform_weather_request].
#' @return A list with 13 elements, including `current`, `hourly` and `daily`.
#' @noRd
parse_weather_response <- function(response) {
  check_response(response)
  body <- httr2::resp_body_json(response)
  check_weather_response_body(body)
  body
}
