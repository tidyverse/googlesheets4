#' Deprecated functions
#'
#' @keywords internal
#' @name googlesheets4-deprecated
NULL

#' Use `sheets_sheet_names()` instead of `sheets_sheets()`.
#' @rdname googlesheets4-deprecated
#' @inheritParams read_sheet
#' @export
sheets_sheets <- function(ss) {
  .Deprecated("sheets_sheet_names()", package = "googlesheets4",
              old = "sheets_sheets()")
  sheets_sheet_names(ss)
}
