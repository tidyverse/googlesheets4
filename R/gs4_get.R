#' Get Sheet metadata
#'
#' Retrieve spreadsheet-specific metadata, such as details on the individual
#' (work)sheets or named ranges.
#'   * `gs4_get()` complements [googledrive::drive_get()], which
#'     returns metadata that exists for any file on Drive.
#'
#' @eval param_ss()
#'
#' @return A list with S3 class `googlesheets4_spreadsheet`, for printing
#'   purposes.
#' @export
#' @seealso Wraps the `spreadsheets.get` endpoint:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get>
#'
#' @examplesIf gs4_has_token()
#' gs4_get(gs4_example("mini-gap"))
gs4_get <- function(ss) {
  resp <- gs4_get_impl_(as_sheets_id(ss))
  new_googlesheets4_spreadsheet(resp)
}

## I want a separate worker so there is a version of this available that
## accepts `fields`, yet I don't want a user-facing function with `fields` arg
gs4_get_impl_ <- function(ssid,
                          fields = NULL) {
  fields <- fields %||% "spreadsheetId,properties,spreadsheetUrl,sheets.properties,sheets.protectedRanges,namedRanges"
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
