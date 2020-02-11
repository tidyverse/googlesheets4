as_GridCoordinate <- function(x, ...) {
    UseMethod("as_GridCoordinate")
}

#' @export
as_GridCoordinate.default <- function(x, ...) {
  stop_glue(
    "Don't know how to make an instance of {bt('GridCoordinate')} from something of ",
    "class {class_collapse(x)}."
  )
}

#' @export
as_GridCoordinate.range_spec <- function(x, ..., strict = TRUE) {
  grid_range <- as_GridRange(x)
  out <- new("GridCoordinate", sheetId = grid_range$sheetId)

  if (identical(names(grid_range), "sheetId")) {
    return(out)
  }

  if (strict) {
    row_index_diff <- grid_range$endRowIndex - grid_range$startRowIndex
    col_index_diff <- grid_range$endColumnIndex - grid_range$startColumnIndex
    if (row_index_diff != 1 || col_index_diff != 1) {
      stop_glue(
        "Range must identify exactly 1 cell:\n",
        "  * Invalid cell range: {x$cell_range}"
      )
    }
  }

  if (notNA(grid_range$startRowIndex %||% NA)) {
    out <- patch(out, rowIndex = grid_range$startRowIndex)
  }
  if (notNA(grid_range$startColumnIndex %||% NA)) {
    out <- patch(out, columnIndex = grid_range$startColumnIndex)
  }
  out
}
