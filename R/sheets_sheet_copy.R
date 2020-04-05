#' Copy a (work)sheet
#'
#' Copies a (work)sheet, within its current (spread)Sheet or to another Sheet.
#'
#' @eval param_ss(pname = "from_ss")
#' @eval param_sheet(
#'   pname = "from_sheet",
#'   action = "copy",
#'   "Defaults to the first visible sheet."
#' )
#' @param to_ss The Sheet to copy *to*. Accepts all the same types of input as
#'   `from_ss`, which is also what this defaults to, if unspecified.
#' @param to_sheet Not implemented yet. But once it is: Name of the new sheet,
#'   as a string. If you don't specify this, Google generates a name, along the
#'   line of "Copy of blah". Note that sheet names must be unique within a
#'   Sheet, so if the automatic name would violate this, Google also
#'   de-duplicates it for you, e.g. "Copy of blah 2". If you have strong
#'   opinions about these matters, you should specify `to_sheet`.
#' @param .before Not implemented yet.
#' @param .after Not implemented yet.
#'
#' @return The receiving Sheet, `to_ ss`, as an instance of [`sheets_id`].
#' @export
#' @family worksheet functions
#' @seealso Makes a `copyTo` request:
#' * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.sheets/copyTo>
#'
#'
#' @examples
#' if (sheets_has_token()) {
#'   ss_aaa <- sheets_create(
#'     "sheets-sheet-copy-demo-aaa",
#'     sheets = list(iris = head(iris), chickwts = head(chickwts))
#'   )
#'
#'   # copies 'iris' sheet within existing Sheet
#'   ss_aaa %>%
#'     sheets_sheet_copy()
#'
#'   # make a second Sheet
#'   ss_bbb <- sheets_create("sheets-sheet-copy-demo-bbb")
#'
#'   # copies 'chickwts' sheet from first Sheet to second
#'   ss_aaa %>%
#'     sheets_sheet_copy("chickwts", to_ss = ss_bbb)
#'
#'   # clean up
#'   googledrive::drive_find("sheets-sheet-copy-demo") %>%
#'     googledrive::drive_trash()
#' }
sheets_sheet_copy <- function(from_ss,
                              from_sheet = NULL,
                              to_ss = from_ss,
                              to_sheet = NULL,
                              .before = NULL,
                              .after = NULL) {
  from_ssid <- as_sheets_id(from_ss)
  maybe_sheet(from_sheet)
  to_ssid <- as_sheets_id(to_ss)
  internal_copy <- identical(from_ssid, to_ssid)

  from_x <- sheets_get(from_ssid)
  if (internal_copy) {
    to_x <- from_x
    details <- glue("within {dq(from_x$name)}")
  } else {
    to_x <- sheets_get(to_ssid)
    details <- glue("from {dq(from_x$name)} to {dq(to_x$name)}")
  }
  from_s <- lookup_sheet(from_sheet, sheets_df = from_x$sheets)
  message_glue("Copying sheet {dq(from_s$name)} {details}")

  req <- request_generate(
    "sheets.spreadsheets.sheets.copyTo",
    params = list(
      spreadsheetId = from_ssid,
      sheetId = from_s$id,
      destinationSpreadsheetId = as.character(to_ssid)
    )
  )
  resp_raw <- request_make(req)
  to_s <- gargle::response_process(resp_raw)
  message_glue("Copied as {dq(to_s$title)}")

  invisible(to_ssid)
}
