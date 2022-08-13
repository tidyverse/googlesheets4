#' Read cells from a Sheet
#'
#' This low-level function returns cell data in a tibble with one row per cell.
#' This tibble has integer variables `row` and `col` (referring to location
#' with the Google Sheet), an A1-style reference `loc`, and a `cell`
#' list-column. The flagship function [read_sheet()], a.k.a. [range_read()], is
#' what most users are looking for, rather than `range_read_cells()`.
#' [read_sheet()] is basically `range_read_cells()` (this function), followed by
#' [spread_sheet()], which looks after reshaping and column typing. But if you
#' really want raw cell data from the API, `range_read_cells()` is for you!
#'
#' @eval param_ss()
#' @eval param_sheet(
#'   action = "read",
#'   "Ignored if the sheet is specified via `range`. If neither argument",
#'   "specifies the sheet, defaults to the first visible sheet."
#' )
#' @template range
#' @template skip-read
#' @template n_max
#' @param cell_data How much detail to get for each cell. `"default"` retrieves
#'   the fields actually used when googlesheets4 guesses or imposes cell and
#'   column types. `"full"` retrieves all fields in the [`CellData`
#'   schema](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/cells#CellData).
#'   The main differences relate to cell formatting.
#' @param discard_empty Whether to discard cells that have no data. Literally,
#'   we check for an `effectiveValue`, which is one of the fields in the
#'   [`CellData`
#'   schema](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/cells#CellData).
#'
#' @seealso Wraps the `spreadsheets.get` endpoint:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get>
#'
#' @return A tibble with one row per cell in the `range`.
#' @export
#'
#' @examplesIf gs4_has_token()
#' range_read_cells(gs4_example("deaths"), range = "arts_data")
#'
#' # if you want detailed and exhaustive cell data, do this
#' range_read_cells(
#'   gs4_example("formulas-and-formats"),
#'   cell_data = "full",
#'   discard_empty = FALSE
#' )
range_read_cells <- function(ss,
                             sheet = NULL,
                             range = NULL,
                             skip = 0, n_max = Inf,
                             cell_data = c("default", "full"),
                             discard_empty = TRUE) {
  cell_data <- match.arg(cell_data)

  # range spec params are checked inside get_cells():
  # ss, sheet, range, skip, n_max
  out <- get_cells(
    ss = ss,
    sheet = sheet, range = range,
    skip = skip, n_max = n_max,
    col_names_in_sheet = FALSE,
    detail_level = cell_data,
    discard_empty = discard_empty
  )
  out$cell <- apply_ctype(out$cell)
  add_loc(out)
}

# I use this elsewhere during development, so handy to have in a function
add_loc <- function(df) {
  tibble::add_column(
    df,
    loc = as.character(glue("{cellranger::num_to_letter(df$col)}{df$row}")),
    .before = "cell"
  )
}
