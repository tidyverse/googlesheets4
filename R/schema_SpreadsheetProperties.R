# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#SpreadsheetProperties
new_SpreadsheetProperties <- function(title,
                                      locale = NULL,
                                      autoRecalc = NULL,
                                      timeZone = NULL,
                                      defaultFormat = NULL,
                                      iterativeCalculationSettings = NULL) {
  x <- list(
    title = title,
    locale = locale,
    autoRecalc = autoRecalc,
    timeZone = timeZone,
    defaultFormat = defaultFormat,
    iterativeCalculationSettings = iterativeCalculationSettings
  )
  structure(
    validate_SpreadsheetProperties(x),
    class = "SpreadsheetProperties"
  )
}

validate_SpreadsheetProperties <- function(x) {
  check_string(x$title, "title")

  maybe_string(x$locale, "locale")
  maybe_string(x$locale, "autoRecalc") # enum
  maybe_string(x$timeZone, "timeZone")

  # defaultFormat is an instance of CellFormat
  # iterativeCalculationSettings is an instance of IterativeCalculationSettings

  x
}

SpreadsheetProperties <- function(title, ...) {
  x <- new_SpreadsheetProperties(title = title, ...)
  compact(x)
}
