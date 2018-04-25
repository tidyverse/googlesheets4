#' Read cells from a Sheet
#'
#' WIP! A low-level function that is, however, meant to be exposed. Retrieves
#' cell data and puts into a tibble with `row`, `column`, and a `cell`
#' list-column.
#'
#' @param ss Something that uniquely identifies a Google Sheet. Processed
#'   through [as_sheets_id()].
#' @param sheet Sheet to read. Either a string (the name of a sheet), or an
#'   integer (the position of the sheet). Ignored if the sheet is specified via
#'   `range`. If neither argument specifies the sheet, defaults to the first
#'   visible sheet. *wording basically copied from readxl* *NOT WIRED UP YET*
#' @param range A cell range to read from, as described in FILL THIS IN
#'   *wording basically copied copied from readxl*
#'
#' @return A tibble with one row per non-empty cell in the `range`. *this might
#'   get dignified with a class?*
#' @export
#'
#' @examples
#' sheets_cells(sheets_example("design-dates"))
#' sheets_cells(sheets_example("gapminder"))
#' sheets_cells(sheets_example("mini-gap"))
#' sheets_cells(sheets_example("ff"))
#' sheets_cells("1J5gb0u8n3D2qx3O3rY28isnI5SD89attRwhWPWlkmDM")
#' sheets_cells("1J5gb0u8n3D2qx3O3rY28isnI5SD89attRwhWPWlkmDM", range = "date-timeofday-duration")
sheets_cells <- function(ss,
                         sheet = NULL,
                         range = NULL) {
  ssid <- as_sheets_id(ss)
  x <- sheets_get(ssid)
  message_glue("Reading from {sq(x$name)}")
  range <- standardise_range(sheet, range, x$sheets)
  message_glue("Range {sq(sq_unescape(range))}")

  resp <- sheets_cells_impl_(
    ssid,
    ranges = range
  )
  cells(resp)
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

## input: an instance of Spreadsheet
## https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet
## output: a tibble with one row per non-empty cell (row, column, cell)
cells <- function(x = list()) {
  ## identify upper left cell of the rectangle
  ## values are absent in the response if equal to 0, hence the default
  ## return values are zero-based, hence we add 1
     start_row <- (pluck(x, "sheets", 1, "data", 1, "startRow") %||% 0) + 1
  start_column <- (pluck(x, "sheets", 1, "data", 1, "startColumn") %||% 0) + 1

  ## TODO: deal with the merged cells

  row_data <- x %>%
    pluck("sheets", 1, "data", 1, "rowData") %>%
    map("values")

  ## an empty row can be present as an explicit NULL
  ## within a non-empty row, an empty cell can be present as list()
  ## rows are ragged and appear to end at the last non-empty cell
  row_lengths <- map_int(row_data, length)
  n_rows <- length(row_data)

  out <- tibble::tibble(
    row = rep.int(
      seq.int(from = start_row, length.out = n_rows),
      times = row_lengths
    ),
    col = sequence(row_lengths),
    loc = as.character(glue("{cellranger::num_to_letter(col)}{row}")),
    cell = purrr::flatten(row_data)
  )

  ## cells can be present, just because they bear a format (much like Excel)
  ## as in readxl, we only load cells with content
  cell_is_empty <- map_lgl(out$cell, ~ is.null(pluck(.x, "effectiveValue")))
  out[!cell_is_empty, ]
}
