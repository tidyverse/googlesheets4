#' Extract the file id from Sheet metadata
#'
#' This method implements [googledrive::as_id()] for the class used here to hold
#' metadata for a Sheet. It just calls [as_sheets_id()], but it's handy in case
#' you forget that exists and hope that `as_id()` will "just work".
#'
#' @inheritParams googledrive::as_id
#' @param x An instance of `sheets_Spreadsheet`, which is returned by, e.g.,
#'   [sheets_get()].
#' @inherit googledrive::as_id return
#' @export
#' @examples
#' if (sheets_has_token) {
#'   ss <- sheets_get(sheets_example("mini-gap"))
#'   class(ss)
#'   as_id(ss)
#' }
as_id.sheets_Spreadsheet <- function(x, ...) as_sheets_id(x)
