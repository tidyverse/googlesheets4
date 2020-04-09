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
#' `sheets_sheets()` is replaced by [sheet_names()].
#' @rdname googlesheets4-deprecated
#' @export
sheets_sheets <- function(...) {
  deprecate_warn("0.2.0", "sheets_sheets()", "sheet_names()")
  sheet_names(...)
}

#' @description
#' `sheets_cells()` is replaced by [range_read_cells()].
#' @rdname googlesheets4-deprecated
#' @export
sheets_cells <- function(...) {
  deprecate_warn("0.2.0", "sheets_cells()", "range_read_cells()")
  range_read_cells(...)
}

#' @description
#' `sheets_read()` is replaced by [range_read()] (which is a synonym for
#' [read_sheet()]).
#' @rdname googlesheets4-deprecated
#' @export
sheets_read <- function(...) {
  deprecate_warn("0.2.0", "sheets_read()", "range_read()")
  range_read(...)
}

#' @description
#' `sheets_write()` is replaced by [sheet_write()] (which is a synonym for
#' [write_sheet()]).
#' @rdname googlesheets4-deprecated
#' @export
sheets_write <- function(...) {
  deprecate_warn("0.2.0", "sheets_write()", "sheet_write()")
  sheet_write(...)
}

# nocov end
