#' Relocate one or more (work)sheets
#'
#' Moves (work)sheets around within a (spread)Sheet.
#'
#' @eval param_ss()
#' @eval param_sheet(
#'   action = "relocate",
#'   "You can pass a vector to move multiple sheets at once or even a list,",
#'   "if you need to mix names and positions."
#' )
#' @eval param_before_after("sheet")
#'
#' @template ss-return
#' @export
#' @family worksheet functions
#' @seealso Makes an `UpdateSheetPropertiesRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest>
#'
#' @examples
#' if (sheets_has_token()) {
#'   ss <- sheets_create(
#'     "sheets-sheet-relocate-demo",
#'     sheets = c("alfa", "bravo", "charlie", "delta", "echo", "foxtrot")
#'   )
#'   sheets_sheet_names(ss)
#'
#'   ss %>%
#'     sheets_sheet_relocate("echo", .before = "bravo") %>%
#'     sheets_sheet_names()
#'
#'   ss %>%
#'     sheets_sheet_relocate(1, .after = 3) %>%
#'     sheets_sheet_names()
#'
#'   ss %>%
#'     sheets_sheet_relocate(6, .after = 2) %>%
#'     sheets_sheet_names()
#'
#'   # clean up
#'   googledrive::drive_find("sheets-sheet-relocate-demo") %>%
#'     googledrive::drive_trash()
#' }
sheets_sheet_relocate <- function(ss,
                                  sheet = NULL,
                                  .before = NULL,
                                  .after = NULL) {
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)

  x <- sheets_get(ssid)
  message_glue("Relocating sheets in {dq(x$name)}")

  s <- lookup_sheet(sheet, sheets_df = x$sheets)
  index <- resolve_index(x$sheets, .before, .after)
  sp <- new("SheetProperties", sheetId = s$id, index = index)
  update_req <- new(
    "UpdateSheetPropertiesRequest",
    properties = sp,
    fields = gargle::field_mask(sp)
  )

  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(updateSheetProperties = update_req)
    )
  )
  resp_raw <- request_make(req)
  foo <- gargle::response_process(resp_raw)

  invisible(ssid)
}
