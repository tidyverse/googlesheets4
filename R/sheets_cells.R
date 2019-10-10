#' Read cells from a Sheet
#'
#' This low-level function returns cell data in a tibble with integer variables
#' `row` and `column` (referring to location with the Google Sheet), an A1-style
#' reference `loc`, and a `cell` list-column. The flagship function
#' [read_sheet()], a.k.a. [sheets_read()], is what most users are looking for.
#' It is basically `sheets_cells()` (this function), followed by
#' [spread_sheet()], which looks after reshaping and column typing. But if you
#' want the raw data from the API, use `sheets_cells()`.
#'
#' @inheritParams read_sheet
#'
#' @return A tibble with one row per non-empty cell in the `range`.
#' @export
#'
#' @examples
#' if (sheets_has_token) {
#'   sheets_cells(sheets_example("deaths"), range = "arts_data")
#'
#'   sheets_example("cell-contents-and-formats") %>%
#'     sheets_cells(range = "types!A2:A5")
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
