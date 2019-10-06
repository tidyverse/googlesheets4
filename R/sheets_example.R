## TODO: ideally these would be actual Sheet names; currently not true
## TODO: consult remote key-value store for these? in case they change?
.sheets_examples <- structure(
  c(
     "gapminder" = "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ",
      "mini-gap" = "1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY",
            "ff" = "132Ij_8ggTKVLnLqCOM3ima6mV9F8rmY7HEcR-5hjWoQ",
  "design-dates" = "1xTUxWGcFLtDIHoYJ1WsjQuLmpUtBf--8Bcu5lQ302SU",
        "deaths" = "1ESTf_tH08qzWwFYRC1NVWJjswtLdZn9EGw5e3Z5wMzA"
  ),
  class = c("sheets_id", "drive_id")
)

#' Access IDs of example Sheets
#'
#' googlesheets4 ships with static IDs for some world-readable example Sheets
#' for use in examples and documentation. These functions make them easy to
#' access by a nickname.
#'
#' @param name Nickname of an example Sheet.
#'
#' @return
#'   * `sheets_example()`: a single [sheets_id] object
#'   * `sheets_examples()`: a named character vector of all built-in examples
#'
#' @export
#' @examples
#' sheets_examples()
#'
#' sheets_example("gapminder")
sheets_example <- function(name = names(sheets_examples())) {
  if (missing(name)) {
    stop_glue("`name` is a required argument")
  }
  name <- match.arg(name)
  new_sheets_id(.sheets_examples[[name]])
}


#' @rdname sheets_example
#' @export
sheets_examples <- function() .sheets_examples
