#' Get data about (work)sheets
#'
#' Reveals full metadata or just the names for the (work)sheets inside a
#' (spread)Sheet.
#'
#' @eval param_ss()
#'
#' @return
#'   * `sheet_properties()`: A tibble with one row per (work)sheet.
#'   * `sheet_names()`: A character vector of (work)sheet names.
#' @export
#' @family worksheet functions
#' @examplesIf gs4_has_token()
#' ss <- gs4_example("gapminder")
#' sheet_properties(ss)
#' sheet_names(ss)
sheet_properties <- function(ss) {
  x <- gs4_get(ss)
  pluck(x, "sheets")
}

#' @export
#' @rdname sheet_properties
sheet_names <- function(ss) {
  sheet_properties(ss)$name
}
