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
