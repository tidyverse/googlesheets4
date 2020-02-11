#' Copy one (work)sheet
#'
#' Copy one (work)sheet from a (spread)Sheet to the same or a different (spread)Sheet
#'
#' @param origin_ss Something that identifies the origin Google Sheet: its file ID, a URL from
#'   which we can recover the ID, an instance of `googlesheets4_spreadsheet`
#'   (returned by [sheets_get()], or a [`dribble`][googledrive::dribble], which
#'   is how googledrive represents Drive files. Processed through
#'   [as_sheets_id()].
#' @param destination_ss Optional, defaults to `origin_ss`.
#'   Something that identifies the destination Google Sheet: its file ID, a URL from
#'   which we can recover the ID, an instance of `googlesheets4_spreadsheet`
#'   (returned by [sheets_get()], or a [`dribble`][googledrive::dribble], which
#'   is how googledrive represents Drive files. Processed through
#'   [as_sheets_id()].
#' @param origin_sheet Sheet name or position of the sheet to copy.
#' @param destination_sheet Optional sheet name of the newly copied sheet..
#'
#' @return A list containing the name and id of the newly copied sheet.
#'
#' @export
#' @family worksheet functions
#' @seealso Makes an `copyTo` request:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.sheets/copyTo>
#'
#' @examples
#' if (sheets_has_token()) {
#'   ss <- sheets_create("copy-sheets-from-me")
#'   ss2 <- sheets_create("copy-sheets-to-me")
#'   sheets_sheet_add(ss, c("alpha", "beta", "gamma"))
#'
#'   # get an overview of the sheets
#'   sheets_sheet_data(ss)
#'
#'   # rename sheets
#'   sheets_sheet_copy(ss, "gamma", destination_sheet="gamma ray")
#'   sheets_sheet_copy(ss, "beta", ss2, "beta particle")
#'
#'   # get an overview of the sheets
#'   sheets_sheet_data(ss)
#'   sheets_sheet_data(ss2)
#'
#'   # cleanup
#'   sheets_find("copy-sheets-from-me") %>% googledrive::drive_rm()
#'   sheets_find("copy-sheets-to-me") %>% googledrive::drive_rm()
#' }
sheets_sheet_copy <- function(origin_ss,origin_sheet,destination_ss=origin_ss,destination_sheet=NULL){
  ossid <- as_sheets_id(origin_ss)
  dssid <- as_sheets_id(destination_ss)
  origin_sheet <- check_sheet(origin_sheet, nm = "sheet")

  ox <- sheets_get(ossid)
  dx <- sheets_get(dssid)
  os <- lookup_sheet(origin_sheet, sheets_df = ox$sheets)

  msg <- glue::glue("Copying sheet {sq(os$name)} from {sq(ox$name)} to {sq(dx$name)}")
  message_collapse(msg)


  request <- request_generate(endpoint = "sheets.spreadsheets.sheets.copyTo",
                              params = list(spreadsheetId=as.character(ossid),
                                            sheetId=os$id,
                                            destinationSpreadsheetId=as.character(dssid)
                              ))
  raw_response <- request_make(request)
  r <- gargle::response_process(raw_response)
  dx <- sheets_get(dssid)
  rs <- lookup_sheet(r$title, sheets_df = dx$sheets)
  if (!is.null(destination_sheet)) {
    destination_sheet <- check_sheet(destination_sheet, nm = "sheet")
    rs <- sheets_sheet_rename(dx,sheet=rs$name,new_sheet=destination_sheet)
  }
  invisible(rs)
}
