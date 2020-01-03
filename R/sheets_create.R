#' Create a new Sheet
#'
#' @description
#' \lifecycle{experimental}
#'
#' Creates an entirely new (spread)Sheet (or, in Excel-speak, workbook). Optionally,
#' you can also provide names and/or data for the initial set of (work)sheets.
#'
#' @seealso
#' Wraps the `spreadsheets.create` endpoint:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create>
#'
#' There is an article on writing Sheets:
#'   * <https://googlesheets4.tidyverse.org/articles/articles/write-sheets.html>
#'
#' @param name The name of the new spreadsheet.
#' @param ... Optional spreadsheet properties that can be set through this API
#'   endpoint, such as locale and time zone.
#' @param sheets Optional input for initializing (work)sheets. If unspecified,
#'   the Sheets API automatically creates an empty "Sheet1". You can provide a
#'   vector of sheet names, a data frame, or a (possibly named) list of data
#'   frames. See the examples.
#'
#' @return The ID of the new Sheet, as an instance of [`sheets_id`].
#' @export
#'
#' @examples
#' if (sheets_has_token()) {
#'   sheets_create("sheets-create-demo-1")
#'
#'   sheets_create("sheets-create-demo-2", locale = "en_CA")
#'
#'   sheets_create(
#'     "sheets-create-demo-3",
#'     locale = "fr_FR",
#'     timeZone = "Europe/Paris"
#'   )
#'
#'   sheets_create(
#'     "sheets-create-demo-4",
#'     sheets = c("alpha", "beta")
#'   )
#'
#'   my_data <- data.frame(x = 1)
#'   sheets_create(
#'     "sheets-create-demo-5",
#'     sheets = my_data
#'   )
#'
#'   sheets_create(
#'     "sheets-create-demo-6",
#'     sheets = list(iris = head(iris), mtcars = head(mtcars))
#'   )
#'
#'   # clean up
#'   sheets_find("sheets-create-demo") %>% googledrive::drive_trash()
#' }
sheets_create <- function(name, ..., sheets = NULL) {
  sheets       <- enlist_sheets(rlang::enquo(sheets))
  sheets_given <- !is.null(sheets)
  data_given   <- sheets_given && !is.null(unlist(sheets$value))

  # create the (spread)Sheet ---------------------------------------------------
  ss_body <- new("Spreadsheet") %>%
    patch(properties = new(
      id = "SpreadsheetProperties",
      title = name, ...
    ))
  if (sheets_given) {
    ss_body <- ss_body %>%
      patch(sheets = map(sheets$name, as_Sheet))
  }
  req <- request_generate(
    "sheets.spreadsheets.create",
    params = ss_body
  )
  resp_raw <- request_make(req)
  resp_create <- gargle::response_process(resp_raw)
  ss <- new_googlesheets4_spreadsheet(resp_create)
  ssid <- as_sheets_id(ss)

  if (!data_given) {
    message_glue(glue_collapse(format(ss), sep = "\n"))
    return(invisible(ssid))
  }

  request_populate_sheets <- map2(ss$sheets$id, sheets$value, prepare_df)
  request_populate_sheets <- flatten(request_populate_sheets)
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = request_populate_sheets,
      includeSpreadsheetInResponse = TRUE,
      responseIncludeGridData = FALSE
    )
  )
  resp_raw <- request_make(req)
  resp_sheets <- gargle::response_process(resp_raw)
  ss <- new_googlesheets4_spreadsheet(resp_sheets$updatedSpreadsheet)
  message_glue(glue_collapse(format(ss), sep = "\n"))

  invisible(ssid)
}

prepare_df <- function(sheet_id, df, skip = 0) {
  # pack the data --------------------------------------------------------------
  # `start` (or `range`) must be sent, even if `skip = 0`
  start <- new("GridCoordinate", sheetId = sheet_id)
  if (skip > 0) {
    start <- patch(start, rowIndex = skip)
  }
  request_values <- new(
    "UpdateCellsRequest",
    start = start,
    rows = as_RowData(df), # an array of instances of RowData
    fields = "userEnteredValue,userEnteredFormat"
  )

  # set sheet dimenions and freeze top row -------------------------------------
  request_sheet_properties <- bureq_set_grid_properties(
    sheetId = sheet_id,
    nrow = nrow(df) + skip + 1, ncol = ncol(df), frozenRowCount = skip + 1
  )

  rlang::list2(
    list(updateSheetProperties = request_sheet_properties),
    list(updateCells = request_values),
    list(repeatCell = bureq_header_row(sheetId = sheet_id, row = skip + 1))
  )
}
