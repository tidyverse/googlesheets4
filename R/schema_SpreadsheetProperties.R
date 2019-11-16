# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#SpreadsheetProperties
SpreadsheetProperties <- function(title,
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
  structure(x, class = "SpreadsheetProperties")
}
