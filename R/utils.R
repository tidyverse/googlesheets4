is_string <- function(x) is.character(x) && length(x) == 1L

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
