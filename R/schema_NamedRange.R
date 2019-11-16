# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#NamedRange
NamedRange <- function(namedRangeId,
                       name,
                       range) {
  x <- list(
    namedRangeId = namedRangeId,
    name = name,
    range = range
  )
  structure(x, class = "NamedRange")
}
