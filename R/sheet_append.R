#' Append rows to a sheet
#'
#' Adds one or more new rows after the last row with data in a (work)sheet,
#' increasing the row dimension of the sheet if necessary.
#'
#' @eval param_ss()
#' @param data A data frame.
#' @eval param_sheet(action = "append to")
#'
#' @template ss-return
#' @export
#' @family write functions
#' @family worksheet functions
#' @seealso Makes an `AppendCellsRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#AppendCellsRequest>
#'
#' @examples
#' if (gs4_has_token()) {
#'   # we will recreate the table of "other" deaths from this example Sheet
#'   (deaths <- gs4_example("deaths") %>%
#'     range_read(range = "other_data", col_types = "????DD"))
#'
#'   # split the data into 3 pieces, which we will send separately
#'   deaths_one   <- deaths[ 1:5, ]
#'   deaths_two   <- deaths[   6, ]
#'   deaths_three <- deaths[7:10, ]
#'
#'   # create a Sheet and send the first chunk of data
#'   ss <- gs4_create("sheet-append-demo", sheets = list(deaths = deaths_one))
#'
#'   # append a single row
#'   ss %>% sheet_append(deaths_two)
#'
#'   # append remaining rows
#'   ss %>% sheet_append(deaths_three)
#'
#'   # read and check against the original
#'   deaths_replica <- range_read(ss, col_types = "????DD")
#'   identical(deaths, deaths_replica)
#'
#'   # clean up
#'   gs4_find("sheet-append-demo") %>%
#'     googledrive::drive_trash()
#' }
sheet_append <- function(ss, data, sheet = 1) {
  check_data_frame(data)
  ssid <- as_sheets_id(ss)
  check_sheet(sheet)

  x <- gs4_get(ssid)
  gs4_bullets(c(v = "Writing to {.file {x$name}}"))

  s <- lookup_sheet(sheet, sheets_df = x$sheets)
  gs4_bullets(c(v = "Appending {nrow(data)} row{?s} to {.field {s$name}}"))

  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = prepare_rows(s$id, data),
      responseIncludeGridData = FALSE
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

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
