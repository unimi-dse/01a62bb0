
#' pollution function that runs the application
#'
#' @return
#' @export
#'
#' @examples
pollution <- function() {
  dir <- system.file("pollution", package = "milanpollution")
  if (dir == "") {
    stop("Could not find pollution. Try re-installing `mypackage`.", call. = FALSE)
  }

  shiny::runApp(dir, display.mode = "normal")
}
