#' Deprecated functions
#'
#' @description
#' \lifecycle{deprecated}
#'
#' These functions are deprecated and will be removed in a future release of
#' googlesheets4.
#'
#' @param ... Passed on to the function that succeeds the deprecated function.
#'
#' @keywords internal
#' @name googlesheets4-deprecated
#' @importFrom lifecycle deprecate_warn
NULL

# nocov start

#' @description
#' `sheets_sheets()` is replaced by `sheets_sheet_names()`.
#' @rdname googlesheets4-deprecated
#' @export
sheets_sheets <- function(...) {
  deprecate_warn("0.2.0", "sheets_sheets()", "sheets_sheet_names()")
  sheets_sheet_names(...)
}

#' @description
#' `sheets_cells()` is replaced by `range_read_cells()`.
#' @rdname googlesheets4-deprecated
#' @export
sheets_cells <- function(...) {
  deprecate_warn("0.2.0", "sheets_cells()", "range_read_cells()")
  range_read_cells(...)
}

# nocov end
