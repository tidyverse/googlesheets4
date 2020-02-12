# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#updatecellsrequest

#' (Over)write new data into a range
#'
#' @description \lifecycle{experimental}
#' Writes a data frame into a range. Main differences from [sheets_write()]:
#'   * The edited cells are not explicitly formatted or styled as a table.
#'     Nothing special is done re: a header row or freezing rows.
#'   * (Work)sheet dimensions are not changed.
#'   * The target (spread)Sheet and (work)sheet must already exist. There is no
#'     ability to create a Sheet or add a worksheet.
#'
#' @template ss
#' @param data A data frame.
#' @eval param_sheet(
#'   action = "write into",
#'   "Ignored if the sheet is specified via `range`. If neither argument",
#'   "specifies the sheet, defaults to the first visible sheet."
#' )
#' @template range

#' @param col_names Logical, indicating whether to send the column names of
#'   `data`.
#'
#' @template ss-return
#' @export
#'
#' @examples
#' if (sheets_has_token()) {
#'   df <- data.frame(
#'     x = 1:3,
#'     y = letters[1:3]
#'   )
#'
#'   # create a Sheet with some initial, placeholder data
#'   (ss <- sheets_create("sheets-edit-demo", sheets = "alpha"))
#'
#'   #  write df somewhere other than the "upper left corner"
#'   sheets_edit(ss, data = df, range = "D6")
#'
#'   # view your magnificent creation in the browser
#'   # sheets_browse(ss)
#'
#'   # clean up
#'   googledrive::drive_rm(ss)
#' }
sheets_edit <- function(ss,
                        data,
                        sheet = NULL,
                        range = NULL,
                        col_names = TRUE) { # not sure about this default
  ssid <- as_sheets_id(ss)
  check_data_frame(data)
  maybe_sheet(sheet)
  check_range(range)
  check_bool(col_names)

  x <- sheets_get(ssid)
  message_glue("Editing {sq(x$name)}")

  s <- lookup_sheet(sheet, sheets_df = x$sheets)
  # why dq() here but sq() above?
  message_glue("Writing to sheet {dq(s$name)}")

  # pack the data, specify field mask ------------------------------------------
  # https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#updatecellsrequest
  bureq <- new(
    "UpdateCellsRequest",
    rows = as_RowData(data, col_names = col_names),
    fields = "userEnteredValue,userEnteredFormat",
  )

  # sort out start vs range ----------------------------------------------------
  range_spec <- as_range_spec(
    range, sheet = s$name,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  grid_range <- as_GridRange(range_spec)
  if (looks_like_start(grid_range)) {
    loc <- list(start = as_GridCoordinate(range_spec))
  } else {
    loc <- list(range = grid_range)
  }
  bureq <- patch(bureq, !!!loc)

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(list(updateCells = bureq)),
      responseIncludeGridData = FALSE
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}

looks_like_start <- function(x) {
  if (is.na(x$endRowIndex %||% NA) &&
      is.na(x$endColumnIndex %||% NA)) {
    return(TRUE)
  }

  row_index_diff <- x$endRowIndex - x$startRowIndex
  col_index_diff <- x$endColumnIndex - x$startColumnIndex
  if (row_index_diff == 1 && col_index_diff == 1) {
    return(TRUE)
  }

  FALSE
}

# gs_edit_cells <- function(ss, ws = 1, input = '', anchor = 'A1',
#                           byrow = FALSE, col_names = NULL, trim = FALSE,
#                           verbose = TRUE) {

# ideally we would (offer to?) clear the cells we're about to write to
# e.g. clear formatting
# but I don't necessarily know which cells we are writing to (at least, not
# without doing some extra work)

