#' Read cells from a Sheet
#'
#' WIP WIP WIP
#'
#' @param ss Something that uniquely identifies a Google Sheet. Processed
#'   through [as_sheets_id()].
#' @param sheet Sheet to read. Either a string (the name of a sheet), or an
#'   integer (the position of the sheet). Ignored if the sheet is specified via
#'   `range`. If neither argument specifies the sheet, defaults to the first
#'   visible sheet. *basically copied from readxl*
#' @param range A cell range to read from, as described in cell-specification
#'   (does not link to anything yet) *basically copied from readxl*
#'
#' @return something TBD
#' @export
#'
#' @examples
#' x <- sheets_cells(sheets_example("design-dates"))
sheets_cells <- function(ss, sheet = NULL, range = NULL) {
  ssid <- as_sheets_id(ss)
  x <- sheets_get(ssid)
  message_glue("Reading from {sq(x$name)}")
  range <- standardise_range(sheet, range, x$sheets)
  message_glue("Range {sq(range)}")

  resp <- sheets_cells_impl_(
    ssid,
    ranges = range
  )
  cells(resp)
}

standardise_range <- function(sheet = NULL, range = NULL, sheet_df) {
  if (!is.null(sheet)) {
    message_glue("{sq('sheet')} is not wired up yet. Ignored.")
  }
  if (is.null(range)) {
    visible_sheets <- sheet_df$name[sheet_df$visible]
    if (length(visible_sheets)) {
      range <- visible_sheets[[1]]
    }
  }
  range
}

## I want a separate worker so there is a version of this available that
## accepts `fields`, yet I don't want a user-facing function with `fields` arg
sheets_cells_impl_ <- function(ssid,
                               ranges,
                               fields = NULL) {
  fields <- fields %||% "spreadsheetId,properties,sheets.data(startRow,startColumn),sheets.data.rowData.values(formattedValue,userEnteredValue,effectiveValue,effectiveFormat.numberFormat)"

  req <- request_generate(
    "spreadsheets.get",
    params = list(
      spreadsheetId = ssid,
      ranges = ranges,
      fields = fields
    )
  )
  raw_resp <- request_make(req)
  response_process(raw_resp)
}

## input: an instance of Spreadsheet, in Sheets API v4 sense, as a list
## https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet
## output: ?a list or an instance of some TBD S3 class?
cells <- function(x = list()) {
  ## identify upper left cell of the rectangle
  ## return values are zero-based, hence we add 1
  ## values are absent in the response if equal to 0, hence the default
     start_row <- (pluck(x, "sheets", 1, "data", 1, "startRow") %||% 0) + 1
  start_column <- (pluck(x, "sheets", 1, "data", 1, "startColumn") %||% 0) + 1

  row_data <-  x %>%
    pluck("sheets", 1, "data", 1, "rowData") %>%
    map("values")

  ## TODO: remove this once I feel confident re: the empty cell situation
  row_lengths <- lengths(row_data)
  if (min(row_lengths) != max(row_lengths)) {
    stop_glue(
      "Rows do not contain same number of cells!\n",
      "min = {min(row_lengths)}, max = {max(row_lengths)}"
    )
  }

  n_rows <- length(row_data)
  n_cols <- length(row_data[[1]])

  tibble::tibble(
    row = rep(seq_len(n_rows), each = n_cols),
    col = rep.int(seq_len(n_cols), times = n_rows),
    cell = purrr::flatten(row_data)
  )
}
