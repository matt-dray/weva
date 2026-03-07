#' Generate a User-Agent String for 'weva'
#' @return Character scalar. A user-agent string.
#' @noRd
generate_user_agent <- function() {
  package_name <- "weva"
  description <- utils::packageDescription(package_name)

  sprintf(
    "%s/%s (%s)",
    package_name,
    description[["Version"]],
    description[["URL"]]
  )
}
