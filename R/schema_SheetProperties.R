#' @export
tibblify.googlesheets4_schema_SheetProperties <- function(x, ...) {
  tibble::tibble(
    # TODO: open question whether I should explicitly unescape title here
    name         =  glean_chr(x, "title"),
    index        =  glean_int(x, "index"),
    id           =  glean_int(x, "sheetId"),
    type         =  glean_chr(x, "sheetType"),
    visible      = !glean_lgl(x, "hidden", .default = FALSE),
    grid_rows    =  glean_int(x, c("gridProperties", "rowCount")),
    grid_columns =  glean_int(x, c("gridProperties", "columnCount"))
  )
}
