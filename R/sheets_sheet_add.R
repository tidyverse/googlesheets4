#' Add one or more (work)sheets
#'
#' Adds one or more (work)sheets to an existing (spread)Sheet. Note that sheet
#' names must be unique.
#'
#' @template ss
#' @param sheet One or more new sheet names. If unspecified, one new sheet is
#'   added and Sheets autogenerates a name of the form "SheetN".
#' @param ... Optional parameters to specify additional properties, common to
#'   all of the new sheet(s). Not relevant to most users. Specify fields of the
#'   [`SheetProperties`
#'   schema](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#SheetProperties)
#'    in `name = value` form.
#' @param .before,.after Optional specification of where to put the new
#'   sheet(s). Specify, at most, one of `.before` and `.after`. Refer to an
#'   existing sheet by name (via a string) or by position (via a number). If
#'   unspecified, Sheets puts the new sheet(s) at the end.
#'
#' @template ss-return
#'
#' @export
#' @family worksheet functions
#' @seealso Makes an `AddSheetRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#addsheetrequest>
#'
#' @examples
#' if (sheets_has_token()) {
#'   ss <- sheets_create("add-sheets-to-me")
#'
#'   # the only required argument is the target spreadsheet
#'   ss %>% sheets_sheet_add()
#'
#'   # but you CAN specify sheet name and/or position
#'   ss %>% sheets_sheet_add("apple", .after = 1)
#'   ss %>% sheets_sheet_add("banana", .after = "apple")
#'
#'   # add multiple sheets at once
#'   ss %>% sheets_sheet_add(c("coconut", "dragonfruit"))
#'
#'   # keeners can even specify additional sheet properties
#'   ss %>%
#'     sheets_sheet_add(
#'       sheet = "eggplant",
#'       .before = 1,
#'       gridProperties = list(
#'         rowCount = 3, columnCount = 6, frozenRowCount = 1
#'       )
#'     )
#'
#'   # get an overview of the sheets
#'   sheets_sheet_properties(ss)
#'
#'   # cleanup
#'   sheets_find("add-sheets-to-me") %>% googledrive::drive_rm()
#' }
sheets_sheet_add <- function(ss,
                             sheet = NULL,
                             ...,
                             .before = NULL,
                             .after = NULL) {
  ssid <- as_sheets_id(ss)
  maybe_character(sheet)
  index <- resolve_index(ssid, .before, .after)

  ss <- sheets_sheet_add_impl_(ssid, sheet_name = sheet, index = index, ...)

  invisible(ssid)
}

sheets_sheet_add_impl_ <- function(ssid,
                                   sheet_name = NULL,
                                   index = NULL, ...) {
  sheet_name <- sheet_name %||% list(NULL)
  dots <- rlang::list2(...)
  requests <- map(
    sheet_name,
    ~ make_addSheet(title = .x, index = index, dots = dots)
  )
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = requests,
      includeSpreadsheetInResponse = TRUE,
      responseIncludeGridData = FALSE
    )
  )
  resp_raw <- request_make(req)
  resp <- gargle::response_process(resp_raw)
  new_googlesheets4_spreadsheet(resp$updatedSpreadsheet)
}

resolve_index <- function(ssid, .before = NULL, .after = NULL) {
  if (is.null(.before) && is.null(.after)) {
    return(NULL)
  }
  sheets_df <- sheets_sheet_properties(ssid)

  if (is.null(.after)) {
    s <- lookup_sheet(.before, sheets_df = sheets_df)
    return(s$index)
  }

  if (is.numeric(.after)) {
    .after <- min(.after, nrow(sheets_df))
  }
  s <- lookup_sheet(.after, sheets_df = sheets_df)
  s$index + 1
}

make_addSheet <- function(title = NULL, index = NULL, dots = list()) {
  if (length(title) + length(index) + length(dots) == 0) {
    # if sending no sheet properties, this must be NULL and not list()
    return(list(addSheet = NULL))
  }

  sp <- new("SheetProperties")

  # do first, so that title and index (derived from formal args sheet, .before,
  # .after) overwrite anything passed via `...`
  sp <- patch(sp, !!!dots)

  if (!is.null(title)) {
    sp <- patch(sp, title = title)
  }

  if (!is.null(index)) {
    sp <- patch(sp, index = index)
  }

  list(addSheet = list(properties = sp))
}
