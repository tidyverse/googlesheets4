#' (Over)write new data into a range
#'
#' @description
#' \lifecycle{experimental}
#'
#' Writes a data frame into a range. Main differences from [sheets_write()]:
#'   * The edited rectangle is not explicitly styled as a table.
#'     Nothing special is done re: formatting a header row or freezing rows.
#'   * Column names can be suppressed. This means that, although `data` must
#'     be a data frame (at least for now), `sheets_edit()` can actually be used
#'     to write arbitrary data.
#'   * The dimensions of the target (work)sheet are not changed.
#'   * The target (spread)Sheet and (work)sheet must already exist. There is no
#'     ability to create a Sheet or add a worksheet.
#'
#' If you just want to add rows to an existing table, the function you probably
#' want is [sheets_append()].
#'
#' @template ss
#' @param data A data frame.
#' @eval param_sheet(
#'   action = "write into",
#'   "Ignored if the sheet is specified via `range`. If neither argument",
#'   "specifies the sheet, defaults to the first visible sheet."
#' )
#' @param range Where to write. This `range` argument has important similarities
#'   and differences to `range` elsewhere (e.g. [sheets_read()]):
#'   * Similarities: Can be a cell range, using A1 notation ("A1:D3") or using
#'     the helpers in [`cell-specification`]. Can combine sheet name and cell
#'     range ("Sheet1!A5:A") or refer to a sheet by name (`range = "Sheet1"`,
#'     although `sheet = "Sheet1"` is preferred).
#'   * Difference: Can NOT be a named range.
#'   * Difference: `range` can be interpreted as the *start* of the target
#'     rectangle (the upper left corner) or, more literally, as the actual
#'     target rectangle. We send it as the start when FILL THIS IN and as the
#'     range when FILL THIS IN.
#' @param col_names Logical, indicating whether to send the column names of
#'   `data`.
#'
#' @template ss-return
#' @export
#' @family write functions
#' @seealso Makes an `UpdateCellsRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#updatecellsrequest>
#'
#' @examples
#' if (sheets_has_token()) {
#'   # create a Sheet with some initial, empty (work)sheets
#'   (ss <- sheets_create("sheets-edit-demo", sheets = c("alpha", "beta")))
#'
#'   df <- data.frame(
#'     x = 1:3,
#'     y = letters[1:3]
#'   )
#'
#'   #  write df somewhere other than the "upper left corner"
#'   sheets_edit(ss, data = df, range = "D6")
#'
#'   # view your magnificent creation in the browser
#'   # sheets_browse(ss)
#'
#'   # send data of disparate types to a 1-row rectangle
#'   dat <- tibble::tibble(
#'     string = "string",
#'     logical = TRUE,
#'     datetime = Sys.time()
#'   )
#'   sheets_edit(ss, data = dat, sheet = "beta", col_names = FALSE)
#'
#'   # send data of disparate types to a 1-column rectangle
#'   dat <- tibble::tibble(
#'     x = list(Sys.time(), FALSE, "string")
#'   )
#'   sheets_edit(ss, data = dat, range = "beta!C5", col_names = FALSE)
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
  # make implicit missing data explicit
  x <- new("GridRange",
           startRowIndex    = x$startRowIndex    %||% NA,
           startColumnIndex = x$startColumnIndex %||% NA,
           endRowIndex      = x$endRowIndex      %||% NA,
           endColumnIndex   = x$endColumnIndex   %||% NA
  )

  if (is.na(x$endRowIndex) && is.na(x$endColumnIndex)) {
    return(TRUE)
  }

  if (noNA(x)) {
    row_index_diff <- x$endRowIndex - x$startRowIndex
    col_index_diff <- x$endColumnIndex - x$startColumnIndex
    if (row_index_diff == 1 && col_index_diff == 1) {
      return(TRUE)
    }
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

