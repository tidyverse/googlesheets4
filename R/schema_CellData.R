# Why not `new("CellData", ...)`? It seems excessive to store the schema as
# an attribute for each cell. Possibly a premature concern.
new_CellData <- function(...) {
  # explicit 'list' class is a bit icky but it makes jsonlite happy
  structure(
    list2(...),
    class = c(
      "googlesheets4_schema_CellData",
      "googlesheets4_schema",
      "list"
    )
  )
}

# Use this instead of `new_CellData()` when (light) validation makes sense.
CellData <- function(...) {
  dots <- list2(...)
  stopifnot(is_dictionaryish(dots))
  check_against_schema(dots, id = "CellData")
  new_CellData(...)
}

is_CellData <- function(x) inherits(x, "googlesheets4_schema_CellData")

as_CellData <- function(x, .na = NULL) {
  UseMethod("as_CellData")
}

#' @export
as_CellData.default <- function(x, .na = NULL) {
  abort_unsupported_conversion(x, to = "CellData")
}

# I want to centralize what we send for NA, even though -- for now, at
# least -- I have not exposed this in user-facing functions. You could imagine
# generalizing to allow user to request we send #N/A.
# More about #N/A:
# https://support.google.com/docs/answer/3093359?hl=en
# However, again, for now, we leave NA as NA and let jsonlite do its usual
# thing, which is to encode as JSON `null`.
empty_cell <- function(.na = NULL) {
  if (is.null(.na)) {
    new_CellData(userEnteredValue = NA)
  } else {
    CellData(!!!.na)
  }
}

# Note that this always returns a **list** of instances of
# googlesheets4_schema_CellData
# of the same length as x.
cell_data <- function(x, val_type, .na = NULL) {
  force(val_type)
  f <- function(y) {
    new_CellData(userEnteredValue = list2(!!val_type := y))
  }
  out <- map(x, f)
  out[is.na(x)] <- list(empty_cell(.na = .na))
  out
}

#' @export
as_CellData.NULL <- function(x, .na = NULL) {
  list(empty_cell(.na))
}

#' @export
as_CellData.googlesheets4_schema_CellData <- function(x, .na = NULL) {
  x
}

#' @export
as_CellData.logical <- function(x, .na = NULL) {
  cell_data(x, val_type = "boolValue", .na = .na)
}

#' @export
as_CellData.character <- function(x, .na = NULL) {
  cell_data(x, val_type = "stringValue", .na = .na)
}

#' @export
as_CellData.factor <- function(x, .na = NULL) {
  as_CellData(as.character(x), .na = .na)
}

#' @export
as_CellData.numeric <- function(x, .na = NULL) {
  cell_data(x, val_type = "numberValue", .na = .na)
}

#' @export
as_CellData.list <- function(x, .na = NULL) {
  out <- map(x, as_CellData, .na = .na)
  # awkwardness possibly solved by using vctrs to create an S3 class for
  # CellData ... but not pursuing at this time
  needs_flatten <- !map_lgl(x, is_CellData)
  out[needs_flatten] <- purrr::flatten(out[needs_flatten])
  out
}

#' @export
as_CellData.googlesheets4_formula <- function(x, .na = NULL) {
  cell_data(vec_data(x), val_type = "formulaValue", .na = .na)
}

add_format <- function(x, fmt) {
  x[["userEnteredFormat"]] <- list(numberFormat = list2(!!!fmt))
  x
}

#' @export
as_CellData.Date <- function(x, .na = NULL) {
  # 25569 = DATEVALUE("1970-01-01), i.e. Unix epoch as a serial date, when the
  # date origin is December 30th 1899
  x <- unclass(x) + 25569
  x <- cell_data(x, val_type = "numberValue", .na = .na)
  map(x, add_format, fmt = list(type = "DATE", pattern = "yyyy-mm-dd"))
}

#' @export
as_CellData.POSIXct <- function(x, .na = NULL) {
  # 86400 = 60 * 60 * 24 = number of seconds in a day
  x <- (unclass(x) / 86400) + 25569
  x <- cell_data(x, val_type = "numberValue", .na = .na)
  map(
    x,
    add_format,
    # I decided that going with R's default format was more important than
    # a militant stance re: ISO 8601
    # the space (vs. a 'T') between date and time is "blessed" in RFC 3339
    # https://tools.ietf.org/html/rfc3339#section-5.6
    fmt = list(type = "DATE_TIME", pattern = "yyyy-mm-dd hh:mm:ss")
  )
}

# Currently (overly) focused on userEnteredValue, because I am thinking about
# writing. But with a reading focus, one would want to see effectiveValue.
format.googlesheets4_schema_CellData <- function(x, ...) {
  # TODO: convey something about userEnteredFormat?
  user_entered_value <- pluck(x, "userEnteredValue")
  if (is.null(user_entered_value) || is.na(user_entered_value)) {
    return("--no userEnteredValue --")
  }
  nm <- pluck(user_entered_value, names)
  fval <- format(user_entered_value)
  as.character(glue("{nm}: {fval}"))
}

print.googlesheets4_schema_CellData <- function(x, ...) {
  header <- as.character(glue("<CellData>"))
  cat(c(header, format(x)), sep = "\n")
  invisible(x)
}
