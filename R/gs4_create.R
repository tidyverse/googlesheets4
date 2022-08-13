#' Create a new Sheet
#'
#' @description
#'
#' Creates an entirely new (spread)Sheet (or, in Excel-speak, workbook).
#' Optionally, you can also provide names and/or data for the initial set of
#' (work)sheets. Any initial data provided via `sheets` is styled as a table,
#' as described in [sheet_write()].
#'
#' @seealso
#' Wraps the `spreadsheets.create` endpoint:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create>
#'
#' There is an article on writing Sheets:
#'   * <https://googlesheets4.tidyverse.org/articles/articles/write-sheets.html>
#'
#' @param name The name of the new spreadsheet.
#' @param ... Optional spreadsheet properties that can be set through this API
#'   endpoint, such as locale and time zone.
#' @param sheets Optional input for initializing (work)sheets. If unspecified,
#'   the Sheets API automatically creates an empty "Sheet1". You can provide a
#'   vector of sheet names, a data frame, or a (possibly named) list of data
#'   frames. See the examples.
#'
#' @template ss-return
#' @export
#' @family write functions
#'
#' @examplesIf gs4_has_token()
#' gs4_create("gs4-create-demo-1")
#'
#' gs4_create("gs4-create-demo-2", locale = "en_CA")
#'
#' gs4_create(
#'   "gs4-create-demo-3",
#'   locale = "fr_FR",
#'   timeZone = "Europe/Paris"
#' )
#'
#' gs4_create(
#'   "gs4-create-demo-4",
#'   sheets = c("alpha", "beta")
#' )
#'
#' my_data <- data.frame(x = 1)
#' gs4_create(
#'   "gs4-create-demo-5",
#'   sheets = my_data
#' )
#'
#' gs4_create(
#'   "gs4-create-demo-6",
#'   sheets = list(chickwts = head(chickwts), mtcars = head(mtcars))
#' )
#'
#' # Clean up
#' gs4_find("gs4-create-demo") %>%
#'   googledrive::drive_trash()
gs4_create <- function(name = gs4_random(), ..., sheets = NULL) {
  sheets       <- enlist_sheets(enquo(sheets))
  sheets_given <- !is.null(sheets)
  data_given   <- sheets_given && !is.null(unlist(sheets$value))

  # create the (spread)Sheet ---------------------------------------------------
  gs4_bullets(c(v = "Creating new Sheet: {.s_sheet {name}}."))
  ss_body <- new(
    "Spreadsheet",
    properties = new("SpreadsheetProperties", title = name, ...)
  )
  if (sheets_given) {
    ss_body <- ss_body %>%
      patch(sheets = map(sheets$name, as_Sheet))
  }
  req <- request_generate(
    "sheets.spreadsheets.create",
    params = ss_body
  )
  resp_raw <- request_make(req)
  resp_create <- gargle::response_process(resp_raw)
  ss <- new_googlesheets4_spreadsheet(resp_create)
  ssid <- as_sheets_id(ss)

  if (!data_given) {
    return(invisible(ssid))
  }

  request_populate_sheets <- map2(ss$sheets$id, sheets$value, prepare_df)
  request_populate_sheets <- purrr::flatten(request_populate_sheets)
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = request_populate_sheets,
      responseIncludeGridData = FALSE
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}

prepare_df <- function(sheet_id, df, skip = 0) {
  # if df is a 0-row data frame, we must send a 1-row data frame of NAs in order
  # to shrink wrap the data and freeze the top row
  # https://github.com/tidyverse/googlesheets4/issues/92
  if (nrow(df) == 0) {
    df <- vec_init(df, n = 1)
  }

  # pack the data --------------------------------------------------------------
  # `start` (or `range`) must be sent, even if `skip = 0`
  start <- new("GridCoordinate", sheetId = sheet_id)
  if (skip > 0) {
    start <- patch(start, rowIndex = skip)
  }
  request_values <- list(updateCells = new(
    "UpdateCellsRequest",
    start = start,
    rows = as_RowData(df), # an array of instances of RowData
    fields = "userEnteredValue,userEnteredFormat"
  ))

  # set sheet dimensions and freeze top row -------------------------------------
  request_sheet_properties <- bureq_set_grid_properties(
    sheetId = sheet_id,
    nrow = nrow(df) + skip + 1, ncol = ncol(df), frozenRowCount = skip + 1
  )

  c(
    list(request_sheet_properties),
    list(request_values),
    list(bureq_header_row(sheetId = sheet_id, row = skip + 1))
  )
}

#' Generate a random Sheet name
#'
#' Generates a random name, suitable for a newly created Sheet, using
#' [ids::adjective_animal()].
#'
#' @param n Number of names to generate.
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' gs4_random()
gs4_random <- function(n = 1) {
  ids::adjective_animal(n = n, max_len = 10, style = "kebab")
}
