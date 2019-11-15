# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/other#GridRange
new_GridRange <- function(sheetId,
                          startRowIndex,
                          endRowIndex,
                          startColumnIndex,
                          endColumnIndex) {

  x <- list(
    sheetId = sheetId,
    startRowIndex = startRowIndex,
    endRowIndex = endRowIndex,
    startColumnIndex = startColumnIndex,
    endColumnIndex = endColumnIndex
  )
  structure(x, class = "GridRange")
}

validate_GridRange <- function(x) {
  check_non_negative_integer(x$sheetId)
  check_non_negative_integer(x$startRowIndex)
  check_non_negative_integer(x$endRowIndex)
  check_non_negative_integer(x$startColumnIndex)
  check_non_negative_integer(x$endColumnIndex)
  x
}

GridRange <- function(sheetId,
                      startRowIndex,
                      endRowIndex,
                      startColumnIndex,
                      endColumnIndex) {
  x <- new_GridRange(
    sheetId = sheetId,
    startRowIndex = startRowIndex,
    endRowIndex = endRowIndex,
    startColumnIndex = startColumnIndex,
    endColumnIndex = endColumnIndex
  )
  validate_GridRange(x)
}
