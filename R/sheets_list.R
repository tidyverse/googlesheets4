#' List your Google Sheets
#'
#' Lists your Google Sheets. This is a very thin wrapper around
#' [googledrive::drive_find()], that specifies you want to list Drive files
#' where `type = "spreadsheet"`.
#'
#' @param ... Arguments (other than `type`, which is hard-wired as `type =
#'   "spreadsheet"`) that are passed along to [googledrive::drive_find()].
#'
#' @inherit googledrive::drive_find return
#' @export
#'
#' @examples
#' if (interactive()) {
#'   sheets_list()
#' }
sheets_list <- function(...) {
  googledrive::drive_find(..., type = "spreadsheet")
}
