#' Add a (work)sheet
#'
#' Adds a (work)sheet to an existing (spread)Sheet.
#'
#' @inheritParams read_sheet
#' @param sheet A string providing the new sheet's name. If unspecified, Sheets
#'   autogenerates a name of the form "SheetN".
#' @param ... Optional parameters to specify additional properties of the new
#'   sheet. Not relevant to most users. Specify fields of the [`SheetProperties`
#'   schema](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#SheetProperties)
#'    in `name = value` form.
#' @param .before,.after Optional specification of where to put the new sheet.
#'   Can be an existing sheet name or a position. If unspecified, Sheets puts
#'   the new sheet at the end.
#'
#' @return `ss`, as an instance of [`sheets_id`]
#' @export
#' @seealso Makes an `AddSheetsRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#addsheetrequest>
#'
#' @examples
#' if (sheets_has_token()) {
#' ss <- sheets_create("add-sheets-to-me")
#'
#' # the only required argument is the target spreadsheet
#' ss %>% sheets_sheet_add()
#'
#' # but you CAN specify sheet name and/or position
#' ss %>% sheets_sheet_add("apple", .after = 1)
#' ss %>% sheets_sheet_add("banana", .after = "apple")
#'
#' # keeners can even specify additional sheet properties
#' ss %>%
#' sheets_sheet_add(
#'   sheet = "coconut",
#'   gridProperties = list(
#'               rowCount = 3, columnCount = 6, frozenRowCount = 1
#'               )
#'               )
#'
#' # get an overview of the sheets
#' sheets_sheet_data(ss)
#'
#' # cleanup
#' sheets_find("add-sheets-to-me") %>% googledrive::drive_rm()
#' }
sheets_sheet_add <- function(ss,
                             sheet = NULL,
                             ...,
                             .before = NULL,
                             .after = NULL) {
  #
  # send an instance of SheetProperties

  ssid <- as_sheets_id(ss)

  maybe_string(sheet)
  dots <- rlang::list2(...)
  index <- resolve_index(ssid, .before, .after)

  msg <- "Adding a sheet"
  if (length(sheet) + length(dots) + length(index) == 0) {
    # if sending no sheet properties, this must be NULL and not list()
    add_sheet <- NULL
  } else {
    sp <- new("SheetProperties")

    # do first, so that sheet, .before, .after overwrite anything in `...`
    sp <- patch(sp, !!!dots)

    if (!is.null(sheet)) {
      sp <- patch(sp, title = sheet)
      msg <- glue("{msg} named {sq(sheet)}")
    }

    if (!is.null(index)) {
      sp <- patch(sp, index = index)
      # index is zero-based
      msg <- glue("{msg} at position {index + 1}")
    }
    add_sheet <- list(properties = sp)
  }

  message_glue(msg)
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(addSheet = add_sheet)
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)
  invisible(ssid)
}

resolve_index <- function(ssid, .before = NULL, .after = NULL) {
  if (is.null(.before) && is.null(.after)) {
    return(NULL)
  }
  sheets_df <- sheets_sheet_data(ssid)

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
