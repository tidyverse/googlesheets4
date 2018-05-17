#' Read cells from a Sheet
#'
#' This low-level function returns cell data in a tibble with integer variables
#' `row` and `column` (referring to location with the Google Sheet), an A1-style
#' reference `loc`, and a `cell` list-column. The flagship function
#' [read_sheet()] is what most users are looking for. It is basically
#' `sheets_cells()` (this function), followed by [spread_sheet()], which looks
#' after reshaping and column typing.
#'
#' @inheritParams read_sheet
#'
#' @return A tibble with one row per non-empty cell in the `range`. *this might
#'   get dignified with a class?*
#' @export
#'
#' @examples
#' sheets_cells(sheets_example("deaths"))
#'
#' \dontrun{
#' ## use tidyr::complete() if you want one row per cell, even if empty
#' test_sheet <- "1J5gb0u8n3D2qx3O3rY28isnI5SD89attRwhWPWlkmDM"
#' (x <- sheets_cells(test_sheet, range = "C2:D4"))
#' x %>% tidyr::complete(row, col, fill = list(cell = list(list())))
#' }
sheets_cells <- function(ss,
                         sheet = NULL,
                         range = NULL) {
  out <- get_cells(ss = ss, sheet = sheet, range = range)
  out$cell <- apply_ctype(out$cell)
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
