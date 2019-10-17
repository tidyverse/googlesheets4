## this file represents the interface with the cellranger package

#' Specify cells for reading
#'
#' The `range` argument in [read_sheet()] or [sheets_cells()] is used to limit
#' the read to a specific rectangle of cells. The Sheets v4 API only accepts
#' ranges in [A1
#' notation](https://developers.google.com/sheets/api/guides/concepts#a1_notation),
#' but googlesheets4 accepts and converts a few alternative specifications
#' provided by the functions in the [cellranger][cellranger] package. Of course,
#' you can always provide A1-style ranges directly to functions like
#' [read_sheet()] or [sheets_cells()]. Why would you use the
#' [cellranger][cellranger] helpers? Some ranges are practically impossible to
#' express in A1 notation, specifically when you want to describe rectangles
#' with some bounds that are specified and others determined by the data.
#'
#' @name cell-specification
#'
#' @examples
#' if (sheets_has_token() && interactive()) {
#'   ss <- sheets_example("mini-gap")
#'
#'   # Specify only the rows or only the columns
#'   read_sheet(ss, range = cell_rows(1:3))
#'   read_sheet(ss, range = cell_cols("C:D"))
#'   read_sheet(ss, range = cell_cols(1))
#'
#'   # Specify upper or lower bound on row or column
#'   read_sheet(ss, range = cell_rows(c(NA, 4)))
#'   read_sheet(ss, range = cell_cols(c(NA, "D")))
#'   read_sheet(ss, range = cell_rows(c(3, NA)))
#'   read_sheet(ss, range = cell_cols(c(2, NA)))
#'   read_sheet(ss, range = cell_cols(c("C", NA)))
#'
#'   # Specify a partially open rectangle
#'   read_sheet(ss, range = cell_limits(c(2, 3), c(NA, NA)), col_names = FALSE)
#'   read_sheet(ss, range = cell_limits(c(1, 2), c(NA, 4)))
#' }
NULL

#' @importFrom cellranger cell_limits
#' @name cell_limits
#' @export
#' @rdname cell-specification
NULL

#' @importFrom cellranger cell_rows
#' @name cell_rows
#' @export
#' @rdname cell-specification
NULL

#' @importFrom cellranger cell_cols
#' @name cell_cols
#' @export
#' @rdname cell-specification
NULL

#' @importFrom cellranger anchored
#' @name anchored
#' @export
#' @rdname cell-specification
NULL
