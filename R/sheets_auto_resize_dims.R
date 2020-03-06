#' Auto-resize columns or rows
#'
#' Applies automatic resizing to either columns or rows of a (work)sheet. The
#' width or height of targeted columns or rows, respectively, is determined
#' from the current cell contents. This only affects the appearance of a Sheet
#' in the browser and doesn't affect its values in any way.
#'
#' @template ss
#' @eval param_sheet(
#'   action = "modify",
#'   "Ignored if the sheet is specified via `range`. If neither argument",
#'   "specifies the sheet, defaults to the first visible sheet."
#' )
#' @param range Which columns or rows to resize. Optional. If you want to resize
#'   all columns or all rows, use `dimension` instead. All the usual `range`
#'   specifications are accepted, but the targeted range must specify only
#'   columns (e.g. "B:F") or only rows (e.g. "2:7").
#' @param dimension Ignored if `range` is given. If consulted, `dimension` must
#'   be either `"columns"` (the default) or `"rows"`. This is the simplest way
#'   to request auto-resize for all columns or all rows.
#'
#' @template ss-return
#' @export
#' @family formatting functions
#' @seealso Makes an `AutoResizeDimensionsRequest`: *
#'   <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#autoresizedimensionsrequest>
#'
#' @examples
#' if (sheets_has_token()) {
#' dat <- tibble::tibble(
#'   fruit = c("date", "lime", "pear", "plum")
#' )
#'
#' ss <- sheets_write(dat)
#' ss
#'
#' # open in the browser
#' sheets_browse(ss)
#'
#' # shrink column A to fit the short fruit names
#' sheets_auto_resize_dims(ss)
#'
#' # send some longer fruit names
#' dat2 <- tibble::tibble(
#'   fruit = c("cucumber", "honeydew")
#' )
#' sheets_append(dat2, ss)
#' # in the browser, see that column A is now too narrow to show the data
#'
#' sheets_auto_resize_dims(ss)
#' # in the browser, see the column A reveals all the data now
#'
#' googledrive::drive_trash(ss)
#' }
sheets_auto_resize_dims <- function(ss,
                                    sheet = NULL,
                                    range = NULL,
                                    dimension = c("columns", "rows")) {
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_range(range)

  x <- sheets_get(ssid)

  # determine targeted sheet ---------------------------------------------------
  range_spec <- as_range_spec(
    range, sheet = sheet,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  range_spec$sheet_name <- range_spec$sheet_name %||% first_visible_name(x$sheets)
  s <- lookup_sheet(range_spec$sheet_name , sheets_df = x$sheets)

  # form request ---------------------------------------------------------------
  if (is.null(range)) {
    dimension <- match.arg(dimension)
    resize_req <- list(bureq_auto_resize_dimensions(
      sheetId = s$id, dimension = toupper(dimension)
    ))
  } else {
    resize_req <- prepare_auto_resize_request(s$id, range_spec)
  }
  resize_dim <- pluck(
    resize_req,
    1, "autoResizeDimensions", "dimensions", "dimension"
  )

  message_glue("Editing {dq(x$name)}")
  message_glue(
    "Resizing one or more {tolower(resize_dim)} in {dq(range_spec$sheet_name)}"
  )

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = resize_req
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)

}

force_cell_limits <- function(x) {
  if (!is.null(x$cell_limits)) {
    return(x)
  }

  if (is.null(x$cell_range)) {
    x$cell_limits <- cell_limits()
  } else {
    x$cell_limits <- limits_from_range(x$cell_range)
  }
  x
}

check_only_one_dimension <- function(x) {
  limits <- x$cell_limits

  if (is.na(limits$ul[1]) && is.na(limits$lr[1])) {
    return(invisible(x))
  }
  if (is.na(limits$ul[2]) && is.na(limits$lr[2])) {
    return(invisible(x))
  }

  stop_glue("The {bt('range')} must target only columns or only rows")
}

determine_dimension <- function(x) {
  limits <- x$cell_limits

  if (notNA(limits$ul[1]) || notNA(limits$lr[1])) {
    "ROWS"
  } else {
    "COLUMNS"
  }
}

prepare_auto_resize_request <- function(sheet_id, range_spec) {
  range_spec <- force_cell_limits(range_spec)
  check_only_one_dimension(range_spec)
  dimension <- determine_dimension(range_spec)

  element <- if (dimension == "ROWS") 1L else 2L

  list(bureq_auto_resize_dimensions(
    sheetId = sheet_id,
    dimension = dimension,
    start = pluck(range_spec, "cell_limits", "ul", element),
    end = pluck(range_spec, "cell_limits", "lr", element)
  ))
}
