# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#Sheet
new_Sheet <- function(properties = NULL,
                      data = NULL) {
  # a Sheet object has MANY more elements, so I'm just starting with the ones
  # I plan to use soon
  x <- list(
    properties = properties,
    data = data
  )
  structure(validate_Sheet(x), class = "Sheet")
}

validate_Sheet <- function(x) {
  if (!is.null(x$properties)) {
    validate_SheetProperties(x)
  }

  # data is an instance of GridData

  x
}

Sheet <- function(...) {
  x <- new_Sheet(...)
  compact(x)
}

