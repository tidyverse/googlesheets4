# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#Sheet
Sheet <- function(properties = NULL,
                  data = NULL) {
  # an instance of Sheet potentially has MANY more fields
  # I'm just starting with the ones I plan to use soon
  x <- list(
    properties = properties,
    data = data
  )
  structure(x, class = "Sheet")
}
