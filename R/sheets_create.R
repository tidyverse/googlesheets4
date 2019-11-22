#' Create a new Sheet
#'
#' Creates an entirely new Sheet (spreadsheet or workbook). Offers some control
#' over the initial set of sheets (worksheets or tabs). CAUTION: this function
#' is still being developed and, for example, currently sends all data as
#' character.
#'
#' @seealso Wraps the `spreadsheets.create` endpoint:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create>
#'
#' @param name The name of the spreadsheet.
#' @param ... Optional spreadsheet properties that can be set through this API
#'   endpoint, such as locale and time zone.
#' @param sheets Optional named list of data frames. One sheet is created for
#'   each data frame.
#'
#' @inherit sheets_get return
#' @export
#'
#' @examples
#' if (sheets_has_token()) {
#'   sheets_create("sheets-create-demo-1")
#'
#'   sheets_create("sheets-create-demo-2", locale = "en_CA")
#'
#'   sheets_create(
#'     "sheets-create-demo-3",
#'     locale = "fr_FR",
#'     timeZone = "Europe/Paris"
#'   )
#'
#'   sheets_create(
#'     "sheets-create-demo-4",
#'     sheets = list(iris = head(iris), mtcars = head(mtcars))
#'   )
#' }
sheets_create <- function(name, ..., sheets = NULL) {
  ss_body <- new("Spreadsheet") %>%
    patch(properties = new(
      id = "SpreadsheetProperties",
      title = name, ...
    ))
  if (!is.null(sheets)) {
    ss_body <- ss_body %>%
      patch(sheets = unname(imap(sheets, as_Sheet)))
  }
  req <- request_generate(
    "sheets.spreadsheets.create",
    params = ss_body
  )
  raw_resp <- request_make(req)
  resp <- gargle::response_process(raw_resp)
  sheets_Spreadsheet(resp)
}
