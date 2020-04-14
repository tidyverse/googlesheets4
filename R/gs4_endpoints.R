#' List Sheets endpoints
#'
#' Returns a list of selected Sheets API v4 endpoints, as stored inside the
#' googlesheets4 package. The names of this list (or the `id` sub-elements) are
#' the nicknames that can be used to specify an endpoint in
#' [request_generate()]. For each endpoint, we store its nickname or `id`, the
#' associated HTTP `method`, the `path`, and details about the parameters. This
#' list is derived programmatically from the [Sheets API v4 Discovery
#' Document](https://www.googleapis.com/discovery/v1/apis/sheets/v4/rest).
#'
#' @param i The name(s) or integer index(ices) of the endpoints to return.
#'   Optional. By default, the entire list is returned.
#'
#' @return A list containing some or all of the subset of the Sheets API v4
#'   endpoints that are used internally by googlesheets4.
#' @export
#'
#' @examples
#' str(gs4_endpoints(), max.level = 2)
#' gs4_endpoints("sheets.spreadsheets.values.get")
#' gs4_endpoints(4)
gs4_endpoints <- function(i = NULL) {
  if (is.null(i)) {
    i <- seq_along(.endpoints)
  }
  .endpoints[i]
}
