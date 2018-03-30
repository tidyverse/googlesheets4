## TODO: ideally these would be actual Sheet names; currently not true
## TODO: consult remote key-value store for these? in case they change?
.sheets_examples <- c(
     "gapminder" = "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ",
      "mini-gap" = "1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY",
            "ff" = "132Ij_8ggTKVLnLqCOM3ima6mV9F8rmY7HEcR-5hjWoQ",
  "design-dates" = "1xTUxWGcFLtDIHoYJ1WsjQuLmpUtBf--8Bcu5lQ302SU"
)

#' Access IDs of example Sheets
#'
#' googlesheets4 ships with static IDs for some world-readable example Sheets
#' for use in examples and documentation. This function make them easy to
#' access by a nickname.
#'
#' @param name Nickname of an example Sheet. If `NULL`, the examples are
#'   listed.
#'
#' @return Either a single [sheets_id] object or a named character vector of all
#'   built-in examples.
#' @export
#' @examples
#' sheets_example()
#' sheets_example("gapminder")
sheets_example <- function(name = NULL) {
  if (is.null(name)) {
    .sheets_examples
  } else {
    stopifnot(is_string(name))
    m <- match(name, names(.sheets_examples))
    if (is.na(m)) {
      stop_glue_data(
        list(x = paste("  * ", names(.sheets_examples), collapse = "\n")),
        "{sq('name')} must be one of these:\n{x}"
      )
    }
    new_sheets_id(.sheets_examples[[name]])
  }
}
