#' Install 'weva' CLI application
#' @inheritDotParams Rapp::install_pkg_cli_apps -package -lib.loc
#' @export
install_cli <- function(...) {
  Rapp::install_pkg_cli_apps(package = "weva", lib.loc = NULL, ...)
}
