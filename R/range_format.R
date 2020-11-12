#' Auto-fit columns or rows to the data
#'
#' Applies automatic resizing to either columns or rows of a (work)sheet. The
#' width or height of targeted columns or rows, respectively, is determined
#' from the current cell contents. This only affects the appearance of a sheet
#' in the browser and doesn't affect its values or dimensions in any way.
#'
#' @eval param_ss()
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
#' @seealso Makes an `AutoResizeDimensionsRequest`:
#' * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#autoresizedimensionsrequest>
#'
#' @examples
#' if (gs4_has_token()) {
#'   dat <- tibble::tibble(
#'     fruit = c("date", "lime", "pear", "plum")
#'   )
#'
#'   ss <- gs4_create("range-autofit-demo", sheets = dat)
#'   ss
#'
#'   # open in the browser
#'   gs4_browse(ss)
#'
#'   # shrink column A to fit the short fruit names
#'   range_autofit(ss)
#'   # in the browser, notice how the column width shrank
#'
#'   # send some longer fruit names
#'   dat2 <- tibble::tibble(
#'     fruit = c("cucumber", "honeydew")
#'   )
#'   ss %>% sheet_append(dat2)
#'   # in the browser, see that column A is now too narrow to show the data
#'
#'   range_autofit(ss)
#'   # in the browser, see the column A reveals all the data now
#'
#'   # clean up
#'   gs4_find("range-autofit-demo") %>%
#'     googledrive::drive_trash()
#' }
range_format_number <- function(ss,
                                range,
                                pattern,
                                type = c("NUMBER", "DATE"),
                                sheet = NULL,
                                dimension = c("columns", "rows")) {
  type <- toupper(type)
  type <- rlang::arg_match(type)

  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_range(range)

  x <- gs4_get(ssid)

  # determine targeted sheet ---------------------------------------------------
  range_spec <- as_range_spec(
    range,
    sheet = sheet,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  range_spec$sheet_name <- range_spec$sheet_name %||% first_visible_name(x$sheets)
  s <- lookup_sheet(range_spec$sheet_name, sheets_df = x$sheets)

  # form request ---------------------------------------------------------------
  range_req <- as_GridRange(range_spec)
  cell_req <- list(
    userEnteredFormat = list(
      numberFormat = list(
        type = type,
        pattern = pattern
      )
    )
  )
  field_req <- "userEnteredFormat.numberFormat"

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(
        repeatCell = list(
          range = range_req,
          cell = cell_req,
          fields = field_req
        )
      )
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}
