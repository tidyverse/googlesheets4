#' Get Sheet metadata
#'
#' Retrieve spreadsheet-specific metadata, such as details on the individual
#' (work)sheets or named ranges.
#'   * `sheets_get()` complements [googledrive::drive_get()], which
#'     returns metadata that exists for any file on Drive.
#'
#' @inheritParams read_sheet
#'
#' @return A list with S3 class `googlesheets4_spreadsheet`, for printing
#'   purposes.
#' @export
#' @seealso Wraps the `spreadsheets.get` endpoint:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get>
#'
#' @examples
#' if (sheets_has_token()) {
#'   sheets_get(sheets_example("mini-gap"))
#' }
sheets_get <- function(ss) {
  resp <- sheets_get_impl_(as_sheets_id(ss))
  new_googlesheets4_spreadsheet(resp)
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
