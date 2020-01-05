#' Append rows to a sheet
#'
#' Adds new cells after the last row with data in a (work)sheet, inserting new
#' rows into the sheet if necessary.
#'
#' @param data A data frame.
#' @template ss
#' @eval param_sheet(action = "append to")
#'
#' @template ss-return
#' @export
#' @seealso Makes an `AppendCellsRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#AppendCellsRequest>
#'
#' @examples
#' if (sheets_has_token()) {
#'   # we will recreate the table of "other" deaths from this example Sheet
#'   (deaths <- sheets_example("deaths") %>%
#'     sheets_read(range = "other_data", col_types = "????DD"))
#'
#'   # split the data into 3 pieces, which we will send separately
#'   deaths_one <- deaths[1:5, ]
#'   deaths_two <- deaths[6, ]
#'   deaths_three <- deaths[7:10, ]
#'
#'   # create a Sheet and send the first chunk of data
#'   ss <- sheets_create("sheets-append-demo", sheets = list(deaths = deaths_one))
#'
#'   # append a single row
#'   sheets_append(deaths_two, ss)
#'
#'   # append remaining rows
#'   sheets_append(deaths_three, ss)
#'
#'   # read and check against the original
#'   deaths_replica <- sheets_read(ss, col_types = "????DD")
#'   identical(deaths, deaths_replica)
#'
#'   # cleanup
#'   googledrive::drive_rm(ss)
#' }
sheets_append <- function(data, ss, sheet = 1) {
  check_data_frame(data)
  ssid <- as_sheets_id(ss)
  check_sheet(sheet)

  x <- sheets_get(ssid)
  message_glue("Writing to {sq(x$name)}")

  s <- lookup_sheet(sheet, sheets_df = x$sheets)
  message_glue("Appending {nrow(data)} row(s) to {sq(s$name)}")

  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = prepare_rows(s$id, data),
      includeSpreadsheetInResponse = TRUE,
      responseIncludeGridData = FALSE
    )
  )
  resp_raw <- request_make(req)
  resp <- gargle::response_process(resp_raw)
  ss <- new_googlesheets4_spreadsheet(resp$updatedSpreadsheet)
  message_glue(glue_collapse(format(ss), sep = "\n"))

  invisible(ssid)
}

prepare_rows <- function(sheet_id, df) {
  list(appendCells = new(
    "AppendCellsRequest",
    sheetId = sheet_id,
    rows = as_RowData(df, col_names = FALSE), # an array of instances of RowData
    fields = "userEnteredValue,userEnteredFormat"
  ))
}
