#' Deprecated functions
#'
#' @description
#' \lifecycle{deprecated}
#'
#' These functions are deprecated and will be removed in a future release of
#' googlesheets4.
#'
#' @keywords internal
#' @name googlesheets4-deprecated
#' @importFrom lifecycle deprecate_warn
NULL

# nocov start

#' @description
#' `sheets_sheets()` is replaced by `sheets_sheet_names()`.
#' @rdname googlesheets4-deprecated
#' @inheritParams read_sheet
#' @export
sheets_sheets <- function(ss) {
  deprecate_warn("0.2.0", "sheets_sheets()", "sheets_sheet_names()")
  sheets_sheet_names(ss)
}

# nocov end
