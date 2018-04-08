is_string <- function(x) is.character(x) && length(x) == 1L

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
      "  * {bt(nm)} has class {collapse(class(x), sep = '/')}"
    )
  }
  x
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
