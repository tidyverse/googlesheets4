# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#SheetProperties
SheetProperties <- function(sheetId = NULL,
                            title = NULL,
                            index = NULL,
                            sheetType = NULL,
                            gridProperties = NULL,
                            hidden = NULL,
                            tabColor = NULL,
                            rightToLeft = NULL) {
  x <- list(
    sheetId = sheetId,
    title = title,
    index = index,
    sheetType = sheetType,
    gridProperties = gridProperties,
    hidden = hidden,
    tabColor = tabColor,
    rightToLeft = rightToLeft
  )
  structure(x, class = "SheetProperties")
}
