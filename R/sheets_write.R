#' (Over)write new data into an existing sheet
#'
#' Updates an existing (work)sheet in an existing (spread)Sheet with a data
#' frame. All pre-existing values, formats, and dimensions of the targeted sheet
#' are cleared and it gets its new values and dimensions from `data`. Special
#' formatting is applied to the header row, which holds column names, and the
#' first `skip + 1` rows are frozen (so, up to and including the header row).
#' *NOTE: this function is very alpha and currently writes everything as
#' character.*
#'
#' @param data A data frame.
#' @inheritParams read_sheet
#' @param sheet Sheet to write into, as in "worksheet" or "tab". Either a string
#'   (the name of a sheet), or an integer (the position of the sheet). If
#'   unspecified, defaults to the first sheet.
#' @param skip Number of rows to leave empty before starting to write.
#' @param na Not implemented yet.
#'
#' @return Updated metadata for the (spread)Sheet `ss`, as an instance of S3
#'   class `googlesheets4_spreadsheet`.
#' @export
#'
#' @examples
#' if (sheets_has_token()) {
#'   # create a Sheet with some initial, placeholder data
#'   ss <- sheets_create(
#'     "sheets-write-demo",
#'     sheets = list(alpha = data.frame(x = 1), omega = data.frame(x = 1))
#'   )
#'
#'   df <- data.frame(
#'     x = 1:3,
#'     y = letters[1:3],
#'     stringsAsFactors = FALSE
#'   )
#'
#'   # write df into the first sheet
#'   (ss <- sheets_write(data = df, ss = ss))
#'
#'   # write mtcars into the sheet named 'omega'
#'   (ss <- sheets_write(data = mtcars, ss = ss, sheet = "omega"))
#'
#'   # view your magnificent creation in the browser
#'   # sheets_browse(ss)
#'
#'   # clean up
#'   sheets_find("sheets-write-demo") %>% googledrive::drive_rm()
#' }
write_sheet <- function(data,
                        ss,
                        sheet = NULL,
                        skip = 0,
                        na = "") {
  # https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#updatecellsrequest
  ssid <- as_sheets_id(ss)
  check_sheet(sheet)
  check_non_negative_integer(skip)

  # retrieve spreadsheet metadata ----------------------------------------------
  x <- sheets_get(ssid)
  message_glue("Writing to {sq(x$name)}")

  # capture sheet id and start row ---------------------------------------------
  # we always send a sheet id
  # if we don't, the default is 0
  # but there's no guarantee that there is such a sheet id
  # it's more trouble to check for that than to just send a sheet id
  s <- lookup_sheet(sheet, sheets_df = x$sheets)
  message_glue("Writing to sheet {dq(s$name)}")
  # `start` (or `range`) must be sent, even if `skip = 0`
  start <- new("GridCoordinate", sheetId = s$id)
  if (skip > 0) {
    start <- patch(start, rowIndex = skip)
    message_glue("Starting at row {skip + 1}")
  }

  # pack the data --------------------------------------------------------------
  request_values <- new(
    "UpdateCellsRequest",
    start = start,
    rows = as_RowData(data), # an array of instances of RowData
    fields = "userEnteredValue"
  )

  # determine sheet dimensions that shrink wrap the data -----------------------
  request_dims <- bureq_set_dimensions(
    sheetId = s$id,
    nrow = nrow(data) + 1 + skip, ncol = ncol(data),
    sheets_df = x$sheets
  )

  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = rlang::list2(
        # set dimensions
        !!!request_dims,
        # clear existing data and formatting
        list(repeatCell = bureq_clear_sheet(s$id)),
        # write data
        list(updateCells = request_values),
        # configure header row
        list(updateSheetProperties =
               bureq_frozen_rows(n = skip + 1, sheetId = s$id)),
        list(repeatCell = bureq_header_row(row = skip + 1, sheetId = s$id))
      )
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  sheets_get(ssid)
}


#' @rdname write_sheet
#' @export
sheets_write <- write_sheet
