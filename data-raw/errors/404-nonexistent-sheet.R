#' ---
#' output: github_document
#' ---

#+ error = TRUE

devtools::load_all(".")

req <- request_generate(
  "spreadsheets.get",
  ## ID of 'googlesheets4-design-exploration', but replaced last 2 chars w/ '-'
  list(spreadsheetId = "1xTUxWGcFLtDIHoYJ1WsjQuLmpUtBf--8Bcu5lQ302--"),
  token = NULL
)
raw_resp <- request_make(req)
response_process(raw_resp)

ct <- httr::content(raw_resp)
str(ct)
