#' Delete one or more (work)sheets
#'
#' Deletes one or more (work)sheets from a (spread)Sheet.
#'
#' @template ss
#' @eval param_sheet(
#'   action = "delete",
#'   "You can pass a vector to delete multiple sheets at once or even a list,",
#'   "if you need to mix names and positions."
#' )
#'
#' @return The input `ss`, as an instance of [`sheets_id`]
#' @export
#' @family worksheet functions
#' @seealso Makes an `DeleteSheetsRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#DeleteSheetRequest>
#'
#' @examples
#' if (sheets_has_token()) {
#'   ss <- sheets_create("delete-sheets-from-me")
#'   sheets_sheet_add(ss, c("alpha", "beta", "gamma", "delta"))
#'
#'   # get an overview of the sheets
#'   sheets_sheet_data(ss)
#'
#'   # delete sheets
#'   sheets_sheet_delete(ss, 1)
#'   sheets_sheet_delete(ss, "gamma")
#'   sheets_sheet_delete(ss, list("alpha", 2))
#'
#'   # get an overview of the sheets
#'   sheets_sheet_data(ss)
#'
#'   # cleanup
#'   sheets_find("delete-sheets-from-me") %>% googledrive::drive_rm()
#' }
sheets_sheet_delete <- function(ss, sheet) {
  ssid <- as_sheets_id(ss)
  walk(sheet, ~ check_sheet(.x, nm = "sheet"))

  # retrieve spreadsheet metadata ----------------------------------------------
  x <- sheets_get(ssid)

  # capture sheet ids ----------------------------------------------------------
  s <- map(sheet, ~ lookup_sheet(.x, sheets_df = x$sheets))
  msg <- glue("  * {map_chr(s, 'name')}\n")
  msg <- c(glue("Deleting these sheet(s) from {sq(x$name)}:"), msg)
  message_collapse(msg)

  sid <- map(s, "id")
  requests <- map(sid, ~ list(deleteSheet = list(sheetId = .x)))

  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = requests
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)
  invisible(ssid)
}
