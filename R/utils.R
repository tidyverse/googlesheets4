is_string <- function(x) is.character(x) && length(x) == 1L

vlookup <- function(this, data, key, value) {
  stopifnot(is_string(key), is_string(value))
  m <- match(this, data[[key]])
  data[[value]][m]
}
