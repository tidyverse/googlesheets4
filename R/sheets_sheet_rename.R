#' Rename one  (work)sheet
#'
#' Rename one (work)sheet from a (spread)Sheet
#'
#' @template ss
#' @eval param_sheet(
#'   action = "rename",
#'   "You can pass a sheet name or position."
#' )
#' @param new_sheet New name to rename the sheet to.
#'
#' @return A list containing the name and id of the renamed sheet.
#'
#' @export
#' @family worksheet functions
#' @seealso Makes an `UpdateSheetPropertiesRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest>
#'
#' @examples
#' if (sheets_has_token()) {
#'   ss <- sheets_create("rename-sheets-from-me")
#'   sheets_sheet_add(ss, c("alpha", "beta", "gamma"))
#'
#'   # get an overview of the sheets
#'   sheets_sheet_data(ss)
#'
#'   # rename sheets
#'   sheets_sheet_rename(ss, 1,"alpha particle")
#'   sheets_sheet_rename(ss, "gamma","gamma ray")
#'
#'   # get an overview of the sheets
#'   sheets_sheet_data(ss)
#'
#'   # cleanup
#'   sheets_find("rename-sheets-from-me") %>% googledrive::drive_rm()
#' }
sheets_sheet_rename <- function(ss,sheet,new_sheet){
  ssid <- as_sheets_id(ss)
  check_sheet(sheet, nm = "sheet")

  x <- sheets_get(ssid)
  s <- lookup_sheet(sheet, sheets_df = x$sheets)

  msg <- glue::glue("Renaming {sq(s$name)} from {sq(x$name)} to {new_sheet}")
  message_collapse(msg)

  sid <- s$id
  request <- list(updateSheetProperties = list(
    properties = list(sheetId = sid,
                      title = new_sheet),
    fields = "title"))
  req <- request_generate(
    endpoint = "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = as.character(ssid),
      requests = list(request)
    )
  )

  raw_response <- request_make(req)
  gargle::response_process(raw_response)

  x <- sheets_get(ssid)
  s <- lookup_sheet(new_sheet, sheets_df = x$sheets)

  invisible(s)
}
