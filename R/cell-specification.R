#' Specify cells for reading
#'
#' The `range` argument in [read_sheet()] or [sheets_cells()] is used to limit
#' the read to a specific rectangle of cells. The Sheets v4 API only accepts
#' ranges in A1 notation, but googlesheets4 accepts and converts a few
#' alternative specifications provided by the functions in the
#' [cellranger][cellranger] package. Of course, you can always provide A1-style
#' ranges directly to functions like [read_sheet()] or [sheets_cells()].
#'
#' @examples
#' \dontrun{
#' ss <- sheets_example("mini-gap")
#'
#' # Specify only the rows or only the columns
#' read_sheet(ss, range = cell_rows(1:3))
#' read_sheet(ss, range = cell_cols("C:D"))
#' read_sheet(ss, range = cell_cols(1))
#'
#' # Specify exactly upper bound on row or column
#' read_sheet(ss, range = cell_rows(c(NA, 4)))
#' read_sheet(ss, range = cell_cols(c(NA, "D")))
#' }
#'
#' @name cell-specification
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

## shim around cellranger::as.range()
## I'm not sure if this is permanent or not?
## currently cellranger::as.range() does not tolerate any NAs
## but some valid Sheets ranges imply NAs in the cell limits
## hence, this function must exist for now
as_sheets_range <- function(x) {
  ## this is not our definitive source of sheet
  x$sheet <- NA_character_
  limits <- x[c("ul", "lr")]

  ## "case numbers" refer to output produced by:
  # tidyr::crossing(
  #   start_row = c(NA, "start_row"), start_col = c(NA, "start_col"),
  #   end_row = c(NA, "end_row"), end_col = c(NA, "end_col")
  # )

  ## nothing is specified
  # 16 NA        NA        NA      NA
  if (allNA(unlist(limits))) {return(NULL)}

  ## end_row and end_col are specified --> lower right cell is fully specified
  #  1 start_row start_col end_row end_col
  #  5 start_row NA        end_row end_col
  #  9 NA        start_col end_row end_col
  # 13 NA        NA        end_row end_col
  if (noNA(limits$lr)) {return(cellranger::as.range(x, fo = "A1"))}

  row_limits <- map_int(limits, 1)
  col_limits <- map_int(limits, 2)

  ## no cols specified, but end_row is
  #  6 start_row NA        end_row NA
  # 14 NA        NA        end_row NA
  if (allNA(col_limits) && !is.na(row_limits[2])) {
    return(paste0(row_limits, collapse = ":"))
  }
  ## no rows specified, but end_col is
  # 11 NA        start_col NA      end_col
  # 15 NA        NA        NA      end_col
  if (allNA(row_limits) && noNA(col_limits)) {
    return(paste0(cellranger::num_to_letter(col_limits), collapse = ":"))
  }

  ## in all remaining scenarios, we would need to use knowledge from the Sheet
  ## in order to produce a valid A1 referencee :(
  ## TODO: come back to this if there's evidence people want it
  ## TODO: create a cellranger::cell_limits format method so this error message
  ##       can convey more about user's input

  ## shared property of what's left:
  ## if start_X is specified, then so must end_X be
  ## NAs in that position must be replaced with the relevant maximum extent,
  ## row or col, from actual Sheet
  #  2 start_row start_col end_row NA
  # 10 NA        start_col end_row NA
  #  3 start_row start_col NA      end_col
  #  7 start_row NA        NA      end_col
  #  4 start_row start_col NA      NA

  ## start_X is specified --> must replace the NA in end_X with actual max
  #  8 start_row NA        NA      NA
  # 12 NA        start_col NA      NA
  stop_glue("Can't express the specified {bt('range')} as an A1 reference")
}
