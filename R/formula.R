new_googlesheets4_formula <- function(x = character()) {
  vec_assert(x, character())
  new_vctr(x, class = "googlesheets4_formula")
}

#' `googlesheets4_formula` class
#'
#' In order to write a formula into Google Sheets, you need to store it as an
#' object of class `googlesheets4_formula`. This is how we distinguish a
#' "regular" character string from a string that should be interpreted as a
#' formula. `googlesheets4_formula` is an S3 class implemented using the [vctrs
#' package](https://vctrs.r-lib.org/articles/s3-vector.html).
#'
#' @param x Character.
#' @inheritParams vctrs::vec_cast
#' @inheritParams vctrs::vec_ptype2
#' @param ... Not used
#'
#' @return An S3 vector of class `googlesheets4_formula`.
#' @export
#'
#' @examples
#' if (sheets_has_token()) {
#' dat <- data.frame(X = c(1, 5, 3, 2, 4, 6))
#'
#' ss <- sheets_write(dat)
#'
#' summaries <- tibble::tribble(
#'        ~ desc, ~ summaries,
#'         "max", "=max(A:A)",
#'         "sum", "=sum(A:A)",
#'         "min", "=min(A:A)",
#'   "sparkline", "=SPARKLINE(A:A, {\"color\", \"blue\"})"
#' )
#'
#' # explicitly declare a column as `googlesheets4_formula`
#' summaries$summaries <- googlesheets4_formula(summaries$summaries)
#'
#' sheets_edit(ss, data = summaries, range = "C1", reformat = FALSE)
#'
#' miscellany <- tibble::tribble(
#'        ~ desc, ~ example,
#'   "hyperlink", "=HYPERLINK(\"http://www.google.com/\",\"Google\")",
#'        "image", "=IMAGE(\"https://www.google.com/images/srpr/logo3w.png\")"
#' )
#' miscellany$example <- googlesheets4_formula(miscellany$example)
#'
#' sheets_write(miscellany, ss = ss)
#'
#' # clean up
#' googledrive::drive_trash(ss)
#' }
googlesheets4_formula <- function(x = character()) {
  x <- vec_cast(x, character())
  new_googlesheets4_formula(x)
}

#' @importFrom methods setOldClass
methods::setOldClass(c("googlesheets4_formula", "vctrs_vctr"))

#' @rdname googlesheets4_formula
#' @export
is_googlesheets4_formula <- function(x) {
  inherits(x, "googlesheets4_formula")
}

#' @export
vec_ptype_abbr.googlesheets4_formula <- function(x, ...) {
  "fmla"
}

#' @export
#' @rdname googlesheets4_formula
vec_ptype2.googlesheets4_formula <- function(x, y, ...) {
  UseMethod("vec_ptype2.googlesheets4_formula", y)
}

#' @export
vec_ptype2.googlesheets4_formula.default <- function(x, y,
                                                     ...,
                                                     x_arg = "x", y_arg = "y") {
  vctrs::vec_default_ptype2(x, y, x_arg = x_arg, y_arg = y_arg)
}

#' @export
vec_ptype2.googlesheets4_formula.googlesheets4_formula <- function(x, y, ...) {
  new_googlesheets4_formula()
}

#' @export
vec_ptype2.googlesheets4_formula.character <- function(x, y, ...) character()

#' @export
#' @rdname googlesheets4_formula
vec_ptype2.character.googlesheets4_formula <- function(x, y, ...) character()

#' @export
#' @rdname googlesheets4_formula
vec_cast.googlesheets4_formula <- function(x, to, ...) {
  UseMethod("vec_cast.googlesheets4_formula")
}

#' @export
vec_cast.googlesheets4_formula.default <- function(x, to, ...) {
  vctrs::vec_default_cast(x, to)
}

#' @export
vec_cast.googlesheets4_formula.googlesheets4_formula <- function(x, to, ...) {
  x
}

#' @export
vec_cast.googlesheets4_formula.character <- function(x, to, ...) {
  googlesheets4_formula(x)
}

#' @export
vec_cast.character.googlesheets4_formula <- function(x, to, ...) {
  vec_data(x)
}

#' @rdname googlesheets4_formula
#' @export
as_googlesheets4_formula <- function(x) {
  vec_cast(x, new_googlesheets4_formula())
}
