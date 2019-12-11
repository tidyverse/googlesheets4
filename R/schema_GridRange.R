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
