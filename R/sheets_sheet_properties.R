#' Get data about (work)sheets
#'
#' Reveals full metadata or just the names for the (work)sheets inside a
#' (spread)Sheet.
#'
#' @eval param_ss()
#'
#' @return
#'   * `sheets_sheet_properties()`: A tibble with one row per (work)sheet.
#'   * `sheet_names()`: A character vector of (work)sheet names.
#' @export
#' @family worksheet functions
#' @examples
#' if (sheets_has_token()) {
#'   ss <- sheets_example("gapminder")
#'   sheets_sheet_properties(ss)
#'   sheet_names(ss)
#' }
sheets_sheet_properties <- function(ss) {
  x <- sheets_get(ss)
  pluck(x, "sheets")
}

#' @export
#' @rdname sheets_sheet_properties
sheet_names <- function(ss) {
  sheets_sheet_properties(ss)$name
}
