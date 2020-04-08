#' Relocate one or more (work)sheets
#'
#' @description
#' Move (work)sheets around within a (spread)Sheet. The results are most
#' predictable for these common and simple use cases:
#' * Move a single sheet.
#' * Move multiple sheets to the front with `.before = 1`.
#' * Move multiple sheets to the back with `.after = 100` (`.after` can be
#'   any number greater than or equal to the number of sheets).
#' * Exhaustively list existing sheets in a new order and specify .`before = 1`.
#'
#' If your relocating is more complicated and you are puzzled by the results,
#' express it as a sequence of simpler calls to `sheets_sheet_relocate()`.
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
#' @seealso
#' Constructs a batch of `UpdateSheetPropertiesRequest`s (one per sheet):
#' * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest>
#'
#' @examples
#' if (sheets_has_token()) {
#'   ss <- sheets_create(
#'     "sheets-sheet-relocate-demo",
#'     sheets = c("alfa", "bravo", "charlie", "delta", "echo", "foxtrot")
#'   )
#'   sheets_sheet_names(ss)
#'
#'   # move one sheet, forwards then backwards
#'   ss %>%
#'     sheets_sheet_relocate("echo", .before = "bravo") %>%
#'     sheets_sheet_names()
#'   ss %>%
#'     sheets_sheet_relocate("echo", .after = "delta") %>%
#'     sheets_sheet_names()
#'
#'   # move multiple sheets to the front
#'   ss %>%
#'     sheets_sheet_relocate(list("foxtrot", 4), .before = 1) %>%
#'     sheets_sheet_names()
#'
#'   # exhaustively list all sheets in a desired order
#'   new_order <- rev(c("alfa", "bravo", "charlie", "delta", "echo", "foxtrot"))
#'   ss %>%
#'     sheets_sheet_relocate(new_order, .before = 1) %>%
#'     sheets_sheet_names()
#'
#'   # move multiple sheets to the back
#'   ss %>%
#'     sheets_sheet_relocate(c("bravo", "alfa", "echo"), .after = 10) %>%
#'     sheets_sheet_names()
#'
#'   # clean up
#'   googledrive::drive_find("sheets-sheet-relocate-demo") %>%
#'     googledrive::drive_trash()
#' }
sheets_sheet_relocate <- function(ss,
                                  sheet,
                                  .before = NULL,
                                  .after = NULL) {
  ssid <- as_sheets_id(ss)
  walk(sheet, check_sheet)
  if (is.null(.before) && is.null(.after)) {
    stop_glue(
      "Either {bt('.before')} or {bt('.after')} must be specified"
    )
  }

  x <- sheets_get(ssid)
  message_glue("Relocating sheets in {dq(x$name)}")

  if (!is.null(.before)) {
    sheet <- rev(sheet)
  }
  requests <- map(
    sheet,
    ~ make_UpdateSheetPropertiesRequest(
        sheet = .x, .before = .before, .after = .after, sheets_df = x$sheets
    )
  )
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

make_UpdateSheetPropertiesRequest <- function(sheet,
                                              .before, .after,
                                              sheets_df) {
  s <- lookup_sheet(sheet, sheets_df = sheets_df)
  index <- resolve_index(sheets_df, .before, .after)
  sp <- new("SheetProperties", sheetId = s$id, index = index)
  update_req <- new(
    "UpdateSheetPropertiesRequest",
    properties = sp,
    fields = gargle::field_mask(sp)
  )
  list(updateSheetProperties = update_req)
}
