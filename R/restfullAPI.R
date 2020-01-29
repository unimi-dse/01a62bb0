#' restfullAPI
#'
#' Get the dataset from the Opendata website of the city of Milan using CRAN API.
#' @param id character. Identify the id of the dataset. if \code{NULL} return an error
#'
#' @return data.frame
#'
#' @examples
#' \dontrun{
#' restfullAPI(id)
#' }
#' @export
#'
restfullAPI <- function(id = NULL)
{
  if (is.null(id) ) {
    stop("Please, insert a valid ID for the dataset", call. = FALSE)
  }

  else{
    url <- paste0("http://dati.comune.milano.it/api/action/",
                  "datastore_search?", paste("resource_id=", id,"&limit=10000", sep=""))
    page <- httr::GET(url) # API request
    httr::status_code(page) # # Check that the call is successful
    leggo_list <- jsonlite::fromJSON(url)
    leggo <- leggo_list$result$records
    return(leggo)
  }


}

