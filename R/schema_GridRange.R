# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/other#GridRange
GridRange <- function(sheetId,
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
