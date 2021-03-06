# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/other#GridRange
#
# All indexes are zero-based. Indexes are half open, e.g the start index is
# inclusive and the end index is exclusive -- [startIndex, endIndex). Missing
# indexes indicate the range is unbounded on that side.

#' @export
as_tibble.googlesheets4_schema_GridRange <- function(x, ...) {
  tibble::tibble(
    # if there is only 1 sheet, sheetId might not be sent!
    # https://github.com/tidyverse/googlesheets4/issues/29
    # don't be shocked if this is NA
    sheet_id    = glean_int(x, "sheetId"),
    # API sends zero-based row and column
    #   => we add one
    # API indices are half-open, i.e. [start, end)
    #   => we substract one from end_[row|column]
    # net effect
    #   => we add one to start_[row|column] but not to end_[row|column]
    start_row    = glean_int(x, "startRowIndex") + 1L,
    end_row      = glean_int(x, "endRowIndex"),
    start_column = glean_int(x, "startColumnIndex") + 1L,
    end_column   = glean_int(x, "endColumnIndex")
  )
}

as_GridRange <- function(x, ...) {
  UseMethod("as_GridRange")
}

#' @export
as_GridRange.default <- function(x, ...) {
  abort_unsupported_conversion(x, to = 'GridRange')
}

#' @export
as_GridRange.range_spec <- function(x, ...) {
  if (!is.null(x$named_range)) {
    abort_bad_range("
      This function does not accept a named range as {bt('range')}")
  }
  s <- lookup_sheet(x$sheet_name, sheets_df = x$sheets_df)
  out <- new("GridRange", sheetId = s$id)

  if (is.null(x$cell_limits)) {
    if (is.null(x$cell_range)) {
      return(out)
    }
    x$cell_limits <- limits_from_range(x$cell_range)
  }

  cl <- list(
    startRowIndex    = x$cell_limits$ul[1] - 1,
    endRowIndex      = x$cell_limits$lr[1],
    startColumnIndex = x$cell_limits$ul[2] - 1,
    endColumnIndex   = x$cell_limits$lr[2]
  )
  cl <- discard(cl, is.na)
  patch(out, !!!cl)
}
