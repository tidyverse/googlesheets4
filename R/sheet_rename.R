#' Rename a (work)sheet
#'
#' Changes the name of a (work)sheet.
#'
#' @eval param_ss()
#' @eval param_sheet(
#'   action = "rename",
#'   "Defaults to the first visible sheet."
#' )
#' @param new_name New name of the sheet, as a string. This is required.
#'
#' @template ss-return
#' @export
#' @family worksheet functions
#' @seealso Makes an `UpdateSheetPropertiesRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest>
#'
#' @examples
#' if (gs4_has_token()) {
#'   ss <- gs4_create(
#'     "sheet-rename-demo",
#'     sheets = list(iris = head(iris), chickwts = head(chickwts))
#'   )
#'   sheet_names(ss)
#'
#'   ss %>%
#'     sheet_rename(1, new_name = "flowers") %>%
#'     sheet_rename("chickwts", new_name = "poultry")
#'
#'   # clean up
#'   gs4_find("sheet-rename-demo") %>%
#'     googledrive::drive_trash()
#' }
sheet_rename <- function(ss,
                         sheet = NULL,
                         new_name) {
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_string(new_name)

  x <- gs4_get(ssid)
  s <- lookup_sheet(sheet, sheets_df = x$sheets)
  gs4_bullets(c(v = "Renaming sheet {.field {s$name}} to {.field {new_name}}"))

  sp <- new("SheetProperties", sheetId = s$id, title = new_name)
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
  gargle::response_process(resp_raw)

  invisible(ssid)
}
