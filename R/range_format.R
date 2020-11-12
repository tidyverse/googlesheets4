#' Range format following pattern
#'
#' Applies Google Sheets number formatting to control how your data appears in a
#' sheet for a given range.
#'
#' @eval param_ss()
#' @eval param_sheet(
#'   action = "modify",
#'   "Ignored if the sheet is specified via `range`. If neither argument",
#'   "specifies the sheet, defaults to the first visible sheet."
#' )
#' @param range Which columns or rows to resize. Optional.
#' @param pattern Character. Google Sheets format pattern. For options see the
#'   [Google
#'   Documentation](https://developers.google.com/sheets/api/guides/formats).
#' @param type Character. Type of data. Either "NUMBER" or "DATE".
#'
#' @template ss-return
#' @export
#' @family formatting functions
#'
#' @examples
#' if (gs4_has_token()) {
#'   dat <- data.frame(small_number = runif(12),
#'                     big_number = runif(12) * 1e6,
#'                     date = Sys.Date() - (0:11) * 30)
#'   # make the sheet
#'   ss <- gs4_create("gs4-number-formats-demo", sheets = dat)
#'   # format as percent
#'   range_format_pattern(ss, range = "A", pattern = "0.0%")
#'   # format as big number
#'   # from https://webapps.stackexchange.com/questions/77974
#'   range_format_pattern(ss, range = "B", pattern = "[>999999]0.0,,\\M;[>999]0.0,\\K;0")
#'   # format as day-month
#'   range_format_pattern(ss, range = "C", pattern = "dd\"-\"mmmm")
#'
#'   # clean up
#'   gs4_find("gs4-number-formats-demo") %>%
#'     googledrive::drive_trash()
#' }
range_format_pattern <- function(ss,
                                 pattern,
                                 type = c("NUMBER", "DATE"),
                                 sheet = NULL,
                                 range = NULL) {
  # see https://developers.google.com/sheets/api/samples/formatting
  # I think type can always be "NUMBER" without issue, including the option for
  # "DATE" because it's technically more right and maybe it matters in some
  # cases
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
