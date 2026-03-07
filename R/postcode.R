#' Get Response from the 'postcodes.io' API and Parse It
#' @param postcode Character scalar. A UK postcode.
#' @return If the API call is successfult, a list with two numeric elements:
#'     `lat` and `lon`.
#' @examples \dontrun{get_latlon("wc2n5du")}
#' @export
get_latlon <- function(postcode) {
  check_character_scalar(postcode)

  request <- build_postcode_request(postcode)
  response <- perform_postcode_request(request)
  parse_postcode_response(response)
}

#' Build an API Request for 'postcodes.io'
#' @param postcode Character scalar. A UK postcode.
#' @return Class 'httr2_request'.
#' @noRd
build_postcode_request <- function(postcode) {
  postcode_norm <- postcode |> gsub("\\s+", "", x = _) |> toupper()

  httr2::request(POSTCODES_ENDPOINT) |>
    httr2::req_url_path_append(postcode_norm) |>
    httr2::req_user_agent(generate_user_agent())
}

#' Perform 'postcodes.io' API Request
#' @param request. Class 'httr2_request'. A request object for 'postcodes.io'
#'     generated with [build_postcode_request].
#' @return Class 'httr2_response'.
#' @noRd
perform_postcode_request <- function(request) {
  check_request(request, POSTCODES_ENDPOINT)

  request |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_error() |> # on 4xx and 5xx
    httr2::req_timeout(10) |>
    httr2::req_perform()
}

#' Parse Response from 'postcodes.io' API Request
#' @param response A 'httr2_response'. Response from 'postcodes.io' API after
#'     sending a with [perform_postcode_request].
#' @return A list with two numeric elements: 'lat' and 'lon'.
#' @noRd
parse_postcode_response <- function(response) {
  check_response(response)

  body <- httr2::resp_body_json(response)
  check_postcode_response_body(body)

  result <- body[["result"]]

  list(
    lat = result[["latitude"]],
    lon = result[["longitude"]]
  )
}
