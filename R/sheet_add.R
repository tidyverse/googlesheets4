#' Add one or more (work)sheets
#'
#' Adds one or more (work)sheets to an existing (spread)Sheet. Note that sheet
#' names must be unique.
#'
#' @eval param_ss()
#' @param sheet One or more new sheet names. If unspecified, one new sheet is
#'   added and Sheets autogenerates a name of the form "SheetN".
#' @param ... Optional parameters to specify additional properties, common to
#'   all of the new sheet(s). Not relevant to most users. Specify fields of the
#'   [`SheetProperties`
#'   schema](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#SheetProperties)
#'    in `name = value` form.
#' @eval param_before_after("sheet(s)")
#'
#' @template ss-return
#'
#' @export
#' @family worksheet functions
#' @seealso
#' Makes a batch of `AddSheetRequest`s (one per sheet):
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#addsheetrequest>
#'
#' @examplesIf gs4_has_token()
#' ss <- gs4_create("add-sheets-to-me")
#'
#' # the only required argument is the target spreadsheet
#' ss %>% sheet_add()
#'
#' # but you CAN specify sheet name and/or position
#' ss %>% sheet_add("apple", .after = 1)
#' ss %>% sheet_add("banana", .after = "apple")
#'
#' # add multiple sheets at once
#' ss %>% sheet_add(c("coconut", "dragonfruit"))
#'
#' # keeners can even specify additional sheet properties
#' ss %>%
#'   sheet_add(
#'     sheet = "eggplant",
#'     .before = 1,
#'     gridProperties = list(
#'       rowCount = 3, columnCount = 6, frozenRowCount = 1
#'     )
#'   )
#'
#' # get an overview of the sheets
#' sheet_properties(ss)
#'
#' # clean up
#' gs4_find("add-sheets-to-me") %>%
#'   googledrive::drive_trash()
sheet_add <- function(ss,
                      sheet = NULL,
                      ...,
                      .before = NULL,
                      .after = NULL) {
  ssid <- as_sheets_id(ss)
  maybe_character(sheet)
  x <- gs4_get(ssid)
  index <- resolve_index(x$sheets, .before, .after)
  n_new <- if (is.null(sheet)) 1 else length(sheet)
  gs4_bullets(c(v = "Adding {n_new} sheet{?s} to {.s_sheet {x$name}}:"))

  ss <- sheet_add_impl_(ssid, sheet_name = sheet, index = index, ...)

  new_sheet_names <- setdiff(ss$sheets$name, x$sheets$name)
  gs4_bullets(
    bulletize(gargle_map_cli(new_sheet_names, template = "{.w_sheet <<x>>}"))
  )

  invisible(ssid)
}

sheet_add_impl_ <- function(ssid,
                            sheet_name = NULL,
                            index = NULL, ...) {
  sheet_name <- sheet_name %||% list(NULL)
  dots <- list2(...)
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

resolve_index <- function(sheets_df, .before = NULL, .after = NULL) {
  if (is.null(.before) && is.null(.after)) {
    return(NULL)
  }

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

  list(addSheet = new(
    "AddSheetRequest",
    properties = new("SheetProperties", title = title, index = index, !!!dots)
  ))
}
