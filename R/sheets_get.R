#' Get Sheet metadata
#'
#' Retrieve spreadsheet-specific metadata, such as details on the individual
#' (work)sheets or named ranges.
#'   * `sheets_get()` complements [googledrive::drive_get()], which
#'     returns metadata that exists for any file on Drive.
#'   * `sheets_sheets()` is a very focused function that only returns
#'     (work)sheet names.
#'
#' @inheritParams read_sheet
#'
#' @return
#'   * `sheets_get()`: A list with S3 class `sheets_Spreadsheet`, for printing
#'     purposes.
#'   * `sheets_sheets()`: A character vector.
#' @export
#'
#' @examples
#' if (sheets_has_token()) {
#'   sheets_get(sheets_example("mini-gap"))
#' }
sheets_get <- function(ss) {
  resp <- sheets_get_impl_(as_sheets_id(ss))
  sheets_Spreadsheet(resp)
}

#' @export
#' @rdname sheets_get
#' @examples
#' if (sheets_has_token()) {
#'   sheets_sheets(sheets_example("deaths"))
#' }
sheets_sheets <- function(ss) {
  x <- sheets_get(ss)
  pluck(x, "sheets", "name")
}

## I want a separate worker so there is a version of this available that
## accepts `fields`, yet I don't want a user-facing function with `fields` arg
sheets_get_impl_ <- function(ssid,
                             fields = NULL) {
  fields <- fields %||% "spreadsheetId,properties,spreadsheetUrl,sheets.properties,namedRanges"
  req <- request_generate(
    "sheets.spreadsheets.get",
    params = list(
      spreadsheetId = ssid,
      fields = fields
    )
  )
  raw_resp <- request_make(req)
  gargle::response_process(raw_resp)
}
