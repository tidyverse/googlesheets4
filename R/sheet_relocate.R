#' Relocate one or more (work)sheets
#'
#' @description
#' Move (work)sheets around within a (spread)Sheet. The outcome is most
#' predictable for these common and simple use cases:
#' * Reorder and move one or more sheets to the front.
#' * Move a single sheet to a specific (but arbitrary) location.
#' * Move multiple sheets to the back with `.after = 100` (`.after` can be
#'   any number greater than or equal to the number of sheets).
#'
#' If your relocation task is more complicated and you are puzzled by the
#' result, break it into a sequence of simpler calls to
#' `sheet_relocate()`.
#'
#' @eval param_ss()
#' @eval param_sheet(
#'   action = "relocate",
#'   "You can pass a vector to move multiple sheets at once or even a list,",
#'   "if you need to mix names and positions."
#' )
#' @param .before,.after Specification of where to locate the sheets(s)
#'   identified by `sheet`. Exactly one of `.before` and `.after` must be
#'   specified. Refer to an existing sheet by name (via a string) or by position
#'   (via a number).
#'
#' @template ss-return
#' @export
#' @family worksheet functions
#' @seealso
#' Constructs a batch of `UpdateSheetPropertiesRequest`s (one per sheet):
#' * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest>
#'
#' @examples
#' if (gs4_has_token()) {
#'   sheet_names <- c("alfa", "bravo", "charlie", "delta", "echo", "foxtrot")
#'   ss <- gs4_create("sheet-relocate-demo", sheets = sheet_names)
#'   sheet_names(ss)
#'
#'   # move one sheet, forwards then backwards
#'   ss %>%
#'     sheet_relocate("echo", .before = "bravo") %>%
#'     sheet_names()
#'   ss %>%
#'     sheet_relocate("echo", .after = "delta") %>%
#'     sheet_names()
#'
#'   # reorder and move multiple sheets to the front
#'   ss %>%
#'     sheet_relocate(list("foxtrot", 4)) %>%
#'     sheet_names()
#'
#'   # put the sheets back in the original order
#'   ss %>%
#'     sheet_relocate(sheet_names) %>%
#'     sheet_names()
#'
#'   # reorder and move multiple sheets to the back
#'   ss %>%
#'     sheet_relocate(c("bravo", "alfa", "echo"), .after = 10) %>%
#'     sheet_names()
#'
#'   # clean up
#'   gs4_find("sheet-relocate-demo") %>%
#'     googledrive::drive_trash()
#' }
sheet_relocate <- function(ss,
                           sheet,
                           .before = if (is.null(.after)) 1,
                           .after = NULL) {
  ssid <- as_sheets_id(ss)
  walk(sheet, check_sheet)
  maybe_sheet(.before)
  maybe_sheet(.after)

  x <- gs4_get(ssid)
  gs4_bullets(c(v = "Relocating sheets in {.s_sheet {x$name}}."))

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
