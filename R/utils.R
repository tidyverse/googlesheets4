# for development only
str1 <- function(x, ...) utils::str(x, ..., max.level = 1)

noNA <- Negate(anyNA)
allNA <- function(x) all(is.na(x))
notNA <- Negate(is.na)

isFALSE <- function(x) identical(x, FALSE)

is_string <- function(x) is.character(x) && length(x) == 1L

is_integerish <- function(x) {
  floor(x) == x
}

check_data_frame <- function(x, arg = caller_arg(x), call = caller_env()) {
  if (!is.data.frame(x)) {
    gs4_abort(
      c(
        "{.arg {arg}} must be a {.cls data.frame}:",
        x = "{.arg {arg}} has class {.cls {class(x)}}."
      ),
      call = call
    )
  }
  x
}

check_string <- function(x, arg = caller_arg(x), call = caller_env()) {
  check_character(x, arg = arg, call = call)
  check_length_one(x, arg = arg, call = call)
  x
}

maybe_string <- function(x, arg = caller_arg(x), call = caller_env()) {
  if (is.null(x)) {
    x
  } else {
    check_string(x, arg = arg, call = call)
  }
}

check_length_one <- function(x, arg = caller_arg(x), call = caller_env()) {
  if (length(x) != 1) {
    gs4_abort(
      "{.arg {arg}} must have length 1, not length {length(x)}.",
      call = call
    )
  }
  x
}

check_has_length <- function(x, arg = caller_arg(x), call = caller_env()) {
  if (length(x) < 1) {
    gs4_abort(
      "{.arg {arg}} must have length greater than zero.",
      call = call
    )
  }
  x
}

check_character <- function(x, arg = caller_arg(x), call = caller_env()) {
  if (!is.character(x)) {
    gs4_abort(
      c(
        "{.arg {arg}} must be {.cls character}:",
        x = "{.arg {arg}} has class {.cls {class(x)}}."
      ),
      call = call
    )
  }
  x
}

maybe_character <- function(x, arg = caller_arg(x), call = caller_env()) {
  if (is.null(x)) {
    x
  } else {
    check_character(x, arg = arg, call = call)
  }
}

check_non_negative_integer <- function(i,
                                       arg = caller_arg(i),
                                       call = caller_env()) {
  if (length(i) != 1 || !is.numeric(i) ||
    !is_integerish(i) || is.na(i) || i < 0) {
    gs4_abort(
      c(
        "{.arg {arg}} must be a positive integer:",
        x = "{.arg {arg}} has class {.cls {class(i)}}."
      ),
      call = call
    )
  }
  i
}

maybe_non_negative_integer <- function(i,
                                       arg = caller_arg(i),
                                       call = caller_env()) {
  if (is.null(i)) {
    i
  } else {
    check_non_negative_integer(i, arg = arg, call = call)
  }
}

check_bool <- function(bool,
                       arg = caller_arg(bool),
                       call = caller_env()) {
  if (!is_bool(bool)) {
    gs4_abort(
      "{.arg {arg}} must be either {.code TRUE} or {.code FALSE}.",
      call = call
    )
  }
  bool
}

maybe_bool <- function(bool,
                       arg = caller_arg(bool),
                       call = caller_env()) {
  if (is.null(bool)) {
    bool
  } else {
    check_bool(bool, arg = arg, call = call)
  }
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

enforce_na <- function(x, na = "") {
  stopifnot(is.character(x), is.character(na))
  out <- x
  if (length(na) > 0) {
    out[x %in% na] <- NA_character_
  }
  if (!("" %in% na)) {
    out[is.na(x)] <- ""
  }
  out
}

groom_text <- function(x, na = "", trim_ws = TRUE) {
  if (isTRUE(trim_ws)) {
    x <- ws_trim(x)
  }
  enforce_na(x, na)
}
