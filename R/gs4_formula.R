new_formula <- function(x = character()) {
  vec_assert(x, character())
  new_vctr(x, class = "googlesheets4_formula")
}

#' Class for Google Sheets formulas
#'
#' In order to write a formula into Google Sheets, you need to store it as an
#' object of class `googlesheets4_formula`. This is how we distinguish a
#' "regular" character string from a string that should be interpreted as a
#' formula. `googlesheets4_formula` is an S3 class implemented using the [vctrs
#' package](https://vctrs.r-lib.org/articles/s3-vector.html).
#'
#' @param x Character.
#'
#' @return An S3 vector of class `googlesheets4_formula`.
#' @export
#' @family write functions
#'
#' @examples
#' if (gs4_has_token()) {
#'   dat <- data.frame(X = c(1, 5, 3, 2, 4, 6))
#'
#'   ss <- sheet_write(dat)
#'   ss
#'
#'   summaries <- tibble::tribble(
#'     ~desc, ~summaries,
#'     "max", "=max(A:A)",
#'     "sum", "=sum(A:A)",
#'     "min", "=min(A:A)",
#'     "sparkline", "=SPARKLINE(A:A, {\\"color\\", \\"blue\\"})"
#'   )
#'
#'   # explicitly declare a column as `googlesheets4_formula`
#'   summaries$summaries <- gs4_formula(summaries$summaries)
#'   summaries
#'
#'   range_write(ss, data = summaries, range = "C1", reformat = FALSE)
#'
#'   miscellany <- tibble::tribble(
#'     ~desc, ~example,
#'     "hyperlink", "=HYPERLINK(\\"http://www.google.com/\\",\\"Google\\")",
#'     "image", "=IMAGE(\\"https://www.google.com/images/srpr/logo3w.png\\")"
#'   )
#'   miscellany$example <- gs4_formula(miscellany$example)
#'   miscellany
#'
#'   sheet_write(miscellany, ss = ss)
#'
#'   # clean up
#'   googledrive::drive_trash(ss)
#' }
gs4_formula <- function(x = character()) {
  x <- vec_cast(x, character())
  new_formula(x)
}

#' @importFrom methods setOldClass
setOldClass(c("googlesheets4_formula", "vctrs_vctr"))

#' @export
vec_ptype_abbr.googlesheets4_formula <- function(x, ...) {
  "fmla"
}

#' @method vec_ptype2 googlesheets4_formula
#' @export vec_ptype2.googlesheets4_formula
#' @export
#' @rdname googlesheets4-vctrs
vec_ptype2.googlesheets4_formula <- function(x, y, ...) {
  UseMethod("vec_ptype2.googlesheets4_formula", y)
}

#' @method vec_ptype2.googlesheets4_formula default
#' @export
vec_ptype2.googlesheets4_formula.default <- function(x, y,
                                                     ...,
                                                     x_arg = "x", y_arg = "y") {
  vec_default_ptype2(x, y, x_arg = x_arg, y_arg = y_arg)
}

#' @method vec_ptype2.googlesheets4_formula googlesheets4_formula
#' @export
vec_ptype2.googlesheets4_formula.googlesheets4_formula <- function(x, y, ...) {
  new_formula()
}

#' @method vec_ptype2.googlesheets4_formula character
#' @export
vec_ptype2.googlesheets4_formula.character <- function(x, y, ...) character()

#' @method vec_ptype2.character googlesheets4_formula
#' @export
vec_ptype2.character.googlesheets4_formula <- function(x, y, ...) character()

#' @method vec_cast googlesheets4_formula
#' @export vec_cast.googlesheets4_formula
#' @export
#' @rdname googlesheets4-vctrs
vec_cast.googlesheets4_formula <- function(x, to, ...) {
  UseMethod("vec_cast.googlesheets4_formula")
}

#' @method vec_cast.googlesheets4_formula default
#' @export
vec_cast.googlesheets4_formula.default <- function(x, to, ...) {
  vec_default_cast(x, to)
}

#' @method vec_cast.googlesheets4_formula googlesheets4_formula
#' @export
vec_cast.googlesheets4_formula.googlesheets4_formula <- function(x, to, ...) {
  x
}

#' @method vec_cast.googlesheets4_formula character
#' @export
vec_cast.googlesheets4_formula.character <- function(x, to, ...) {
  gs4_formula(x)
}

#' @method vec_cast.character googlesheets4_formula
#' @export
vec_cast.character.googlesheets4_formula <- function(x, to, ...) {
  vec_data(x)
}
