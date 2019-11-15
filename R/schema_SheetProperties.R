# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#SheetProperties
new_SheetProperties <- function(sheetId = NULL,
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
  structure(validate_SheetProperties(x), class = "SheetProperties")
}

validate_SheetProperties <- function(x) {
  maybe_non_negative_integer(x$sheetId, "sheetId")
  maybe_string(x$title, "title")
  maybe_non_negative_integer(x$index, "index")
  maybe_string(x$sheetType, "sheetType") # enum

  # gridProperties is an instance of GridProperties

  maybe_bool(x$hidden, "hidden")

  # tabColor is an instance of Color

  maybe_bool(x$rightToLeft, "rightToLeft")

  x
}

SheetProperties <- function(...) {
  x <- new_SheetProperties(...)
  compact(x)
}
