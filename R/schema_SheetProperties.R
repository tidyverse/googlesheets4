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
    sheetType = sheetType,           # enum
    gridProperties = gridProperties, # unimplemented schema
    hidden = hidden,
    tabColor = tabColor,             # schema
    rightToLeft = rightToLeft
  )
  structure(x, class = "SheetProperties")
}

tibblify_SheetProperties <- function(x) {
  # weird-looking workaround for the (current) lack of typed pluck()
  # revisit this when I depend on vctrs directly
  x <- list(x)
  tibble::tibble(
    # TODO: open question whether I should explicitly unescape title here
    name         =  hoist_chr(x, "title"),
    index        =  hoist_int(x, "index"),
    id           =  hoist_int(x, "sheetId"),
    type         =  hoist_chr(x, "sheetType"),
    visible      = !hoist_lgl(x, "hidden", .default = FALSE),
    grid_rows    =  hoist_int(x, c("gridProperties", "rowCount")),
    grid_columns =  hoist_int(x, c("gridProperties", "columnCount"))
  )
}
