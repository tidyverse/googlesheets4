#' Visit Sheet in browser
#'
#' Visits a Google Sheet in your default browser.
#'
#' @inheritParams read_sheet
#'
#' @return The Sheet's browser URL, invisibly.
#' @export
#' @examples
#' \dontrun{
#' sheets_example("mini-gap") %>% sheets_browse()
#' }
sheets_browse <- function(ss) {
  ## TO RECONSIDER AFTER AUTH: get the official link, if we're in auth state?
  # googledrive::drive_browse(as_sheets_id(ss))
  ssid <- as_sheets_id(ss)
  url <- glue("https://docs.google.com/spreadsheets/d/{ssid}")
  if (!interactive()) return(invisible(url))
  utils::browseURL(url)
  return(invisible(url))
}
