#' Delete cells
#'
#' Deletes a range of cells and shifts other cells into the deleted area. There
#' are several related tasks that are implemented by other functions:
#'   * To clear cells of their value and/or format, use [range_clear()].
#'   * To delete an entire (work)sheet, use [sheets_sheet_delete()].
#'   * To change the dimensions of a (work)sheet, use [sheets_sheet_resize()].
#'
#' @eval param_ss()
#' @eval param_sheet(
#'   action = "delete",
#'   "Ignored if the sheet is specified via `range`. If neither argument",
#'   "specifies the sheet, defaults to the first visible sheet."
#' )
#' @param range Cells to delete. There are a couple differences between `range`
#'   here and how it works in other functions (e.g. [sheets_read()]):
#'   * `range` must be specified.
#'   * `range` must not be a named range.
#'   * `range` must not be the name of a (work) sheet. Instead, use
#'     [sheets_sheet_delete()] to delete an entire sheet.
#'  Row-only and column-only ranges are especially relevant, such as "2:6" or
#'  "D". Remember you can also use the helpers in [`cell-specification`],
#'  such as `cell_cols(4:6)`, or `cell_rows(5)`.
#' @param shift Must be one of "up" or "left", if specified. Required if `range`
#'   is NOT a rows-only or column-only range (in which case, we can figure it
#'   out for you). Determines whether the deleted area is filled by shifting
#'   surrounding cells up or to the left.
#'
#' @template ss-return
#' @export
#' @family write functions
#' @seealso Makes a `DeleteRangeRequest`:
#' * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#DeleteRangeRequest>
#'
#' @examples
#' if (sheets_has_token()) {
#'   # create a data frame to use as initial data
#'   df <- sheets_fodder(10)
#'
#'   # create Sheet
#'   ss <- sheets_create("sheets-delete-example", sheets = list(df))
#'
#'   # delete some rows
#'   range_delete(ss, range = "2:4")
#'
#'   # delete a column
#'   range_delete(ss, range = "C")
#'
#'   # delete a rectangle and specify how to shift remaining cells
#'   range_delete(ss, range = "B3:F4", shift = "left")
#'
#'   # clean up
#'   googledrive::drive_trash(ss)
#' }
range_delete <- function(ss,
                         sheet = NULL,
                         range,
                         shift = NULL) {
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_range(range)
  stopifnot(!is.null(range))
  if (is.null(shift)) {
    shift_dimension <- NULL
  } else {
    shift <- match.arg(shift, c("up", "left"))
    shift_dimension <- switch(shift, up = "ROWS", left = "COLUMNS")
  }

  x <- sheets_get(ssid)
  message_glue("Editing {dq(x$name)}")

  # determine (work)sheet and range --------------------------------------------
  range_spec <- as_range_spec(
    range,
    sheet = sheet,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  if (is.null(range_spec$cell_range) && is.null(range_spec$cell_limits)) {
    stop_glue("{bt('range_delete()')} requires a cell range")
  }
  range_spec$sheet_name <- range_spec$sheet_name %||% first_visible_name(x$sheets)
  # as_GridRange() throws an error for a named range
  grid_range <- as_GridRange(range_spec)
  message_glue("Deleting cells in sheet {dq(range_spec$sheet_name)}")

  # form batch update request --------------------------------------------------
  shift_dimension <- shift_dimension %||% determine_shift(grid_range)
  if (is.null(shift_dimension)) {
    stop_glue(
      "The `shift` direction must be specified for this `range`. It can't be
      automatically determined."
    )
  }

  # form batch update request --------------------------------------------------
  delete_req <- list(deleteRange = new(
    "DeleteRangeRequest",
    range = grid_range,
    shiftDimension = shift_dimension
  ))

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(delete_req)
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}

determine_shift <- function(gr) {
  stopifnot(inherits(gr, "googlesheets4_schema_GridRange"))
  bounded_on_bottom <- !is.null(gr$endRowIndex) && notNA(gr$endRowIndex)
  bounded_on_right <- !is.null(gr$endColumnIndex) && notNA(gr$endColumnIndex)

  if (bounded_on_bottom && bounded_on_right) { # user must specify shift
    return(NULL)
  }

  if (bounded_on_bottom) { # and not bounded_on_right
    return("ROWS")
  }

  if (bounded_on_right) { # and not bounded_on_bottom
    return("COLUMNS")
  }

  stop_glue(
    "`range` must be bounded on the bottom and/or on the right.
     See `sheets_sheet_delete()` or `sheets_sheet_resize()` to delete or \\
     resize a (work)sheet."
  )
}
