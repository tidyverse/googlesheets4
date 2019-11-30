sheets_write <- function(data,
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

# docs on Sheets NA
# https://support.google.com/docs/answer/3093359?hl=en
# #N/A
