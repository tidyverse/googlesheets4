#' Print info about a `gsheet` object
#'
#' Display information about a Google spreadsheet that has been registered with
#' googlesheets: the name or title of the spreadsheet, date-time of
#' registration, date-time of last update (at time of registration), visibility,
#' permissions, version, the number of worksheets contained, worksheet titles
#' and extent, and sheet key. *A lot of that is not true yet or anymore!*
#'
#' @param x [`gsheet`] object returned by functions such as [sheet_name()],
#'   [sheet_id()], and friends
#' @param ... potential further arguments (required for Method/Generic reasons)
#'
#' @examples
#' \dontrun{
#' foo <- gs_new("foo")
#' foo
#' print(foo)
#' }
#'
#' @export
print.gsheet <- function(x, ...) {

  cpf("                  Spreadsheet name: %s", x$name)
  cpf("                          More key: more value")
#  cpf("                 Spreadsheet author: %s", x$author)
  # cpf("  Date of googlesheets registration: %s",
  #     x$reg_date %>% format.POSIXct(usetz = TRUE))
  # cpf("    Date of last spreadsheet update: %s",
  #     x$updated %>% format.POSIXct(usetz = TRUE))
  # cpf("                         visibility: %s", x$visibility)
  # cpf("                        permissions: %s", x$perm)
  # cpf("                            version: %s", x$version)
  cat("\n")

  ws_output <-
    sprintf("%s: %d x %d",
            x$ws$title, x$ws$rowCount, x$ws$columnCount)
  cpf("Contains %d worksheets:", x$n_ws)
  cat("(Title): (Nominal worksheet extent as rows x columns)\n")
  cat(ws_output, sep = "\n")

  cat("\n")
  cpf("Id: %s", x$id)
  cpf("Browser URL: %s", x$browser_url)

  invisible(x)
}
