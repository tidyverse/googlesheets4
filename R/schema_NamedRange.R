# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#NamedRange
new_NamedRange <- function(namedRangeId,
                           name,
                           range) {
  x <- list(
    namedRangeId = namedRangeId,
    name = name,
    range = range
  )
  structure(
    validate_NamedRange(x),
    class = "NamedRange"
  )
}

validate_NamedRange <- function(x) {
  # I think read-only vs. required vs. optional status of these elements
  # depends on what you're trying to do
  maybe_string(x$namedRangeId, "namedRangeId")
  maybe_string(x$name, "name")

  validate_GridRange(x$range)

  x
}

NamedRange <- function(...) {
  x <- new_NamedRange(...)
  compact(x)
}
