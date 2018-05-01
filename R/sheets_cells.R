#' Read cells from a Sheet
#'
#' WIP! A low-level function that is, however, meant to be exposed. Retrieves
#' cell data and puts into a tibble with `row`, `column`, `loc`, and a `cell`
#' list-column.
#'
#' @inheritParams read_sheet
#'
#' @return A tibble with one row per non-empty cell in the `range`. *this might
#'   get dignified with a class?*
#' @export
#'
#' @examples
#' sheets_cells(sheets_example("design-dates"))
#' #sheets_cells(sheets_example("gapminder"))
#' sheets_cells(sheets_example("mini-gap"))
#' sheets_cells(sheets_example("ff"))
#'
#' test_sheet <- "1J5gb0u8n3D2qx3O3rY28isnI5SD89attRwhWPWlkmDM"
#' sheets_cells(test_sheet)
#' sheets_cells(test_sheet, range = "date-timeofday-duration")
#' x <- sheets_cells(test_sheet, range = "C2:D4")
#' x
#' #x %>% tidyr::complete(row, col, fill = list(cell = list(list())))
sheets_cells <- function(ss,
                         sheet = NULL,
                         range = NULL) {
  out <- get_cells(ss = ss, sheet = sheet, range = range)
  add_loc(out)
}

## I use this elsewhere during development, so handy to have in a function
add_loc <- function(df) {
  tibble::add_column(
    df,
    loc = as.character(glue("{cellranger::num_to_letter(df$col)}{df$row}")),
    .before = "cell"
  )
}
