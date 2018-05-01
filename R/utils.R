is_string <- function(x) is.character(x) && length(x) == 1L

is_integerish <- function(x) {
  floor(x) == x
}

check_string <- function(x, nm = deparse(substitute(x))) {
  check_character(x)
  check_length_one(x)
  x
}

check_length_one <- function(x, nm = deparse(substitute(x))) {
  if (length(x) != 1) {
    stop_glue("{bt(nm)} must have length 1, not length {length(x)}")
  }
  x
}

check_character <- function(x, nm = deparse(substitute(x))) {
  if (!is.character(x)) {
    stop_glue(
      "{bt(nm)} must be character:\n",
      "  * {bt(nm)} has class {glue_collapse(class(x), sep = '/')}"
    )
  }
  x
}

check_non_negative_integer <- function(i, nm = deparse(substitute(x))) {
  if (length(i) != 1 || !is.numeric(i) ||
      !is_integerish(i) || is.na(i) || i < 0) {
    stop_glue(
      "{bt(nm)} must be a positive integer:\n",
      "  * {bt(nm)} has class {glue_collapse(class(x), sep = '/')}"
    )
  }
  i
}

check_bool <- function(bool, nm = deparse(substitute(x))) {
  if (!isTRUE(bool) && !identical(bool, FALSE)) {
    stop_glue("{bt(nm)} must be either TRUE or FALSE")
  }
  bool
}

vlookup <- function(this, data, key, value) {
  stopifnot(is_string(key), is_string(value))
  m <- match(this, data[[key]])
  data[[value]][m]
}

## avoid the name `trim_ws` because it's an argument of several functions in
## this package
ws_trim <- function(x) {
  sub("\\s*$", "", sub("^\\s*", "", x))
}
