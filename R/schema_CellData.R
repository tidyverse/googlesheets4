as_CellData <- function(x, .na = NULL) {
  UseMethod("as_CellData")
}

#' @export
as_CellData.default <- function(x, .na = NULL) {
  stop_glue(
    "Don't know how to make an instance of {bt('CellData')} from something of ",
    "class {class_collapse(x)}."
  )
}

# I want to centralize what value we send for NA, even though -- for now, at
# least -- I have not exposed this in user-facing functions. You could imagine
# generalizing to allow user to request we send #N/A instead of an empty cell.
# More about #N/A:
# https://support.google.com/docs/answer/3093359?hl=en
# Currently this is sort of possible:
# as_CellData(c(TRUE, FALSE, NA), .na = list(formulaValue = "=NA()"))
empty_cell <- function(..., .na = NULL) {
  .na %||% list(userEnteredValue = NA)
}

cell_data <- function(x, val_type, .na = NULL) {
  force(val_type)
  f<- function(y, ...) {
    list(userEnteredValue = rlang::list2(!!val_type := y))
  }
  purrr::map_if(x, rlang::is_na, empty_cell, .na = .na, .else = f)
}

# Possibly premature worrying, but I'm not using new("CellData", ...) because
# storing the tidy schema as an attribute for each cell seems excessive.
# That would look something like this for logical:
# map(x, ~ new("CellData", userEnteredValue = list(boolValue = .x)))

#' @export
as_CellData.NULL <- function(x, .na = NULL) {
  empty_cell(.na)
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
as_CellData.numeric <- function(x, .na = NULL) {
  cell_data(x, val_type = "numberValue", .na = .na)
}

#' @export
as_CellData.list <- function(x, .na = NULL) {
  map(x, as_CellData, .na = .na)
}

#' @export
as_CellData.factor <- function(x, .na = NULL) {
  as_CellData(as.character(x), .na = .na)
}

add_format <- function(x, fmt) {
  x[["userEnteredFormat"]] <- list(numberFormat = rlang::list2(!!!fmt))
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
