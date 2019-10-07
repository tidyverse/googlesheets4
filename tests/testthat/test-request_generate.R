test_that("can generate a basic request", {
  req <- request_generate(
    "sheets.spreadsheets.get",
    list(spreadsheetId = "abc123"),
    token = NULL
  )
  expect_identical(req$method, "GET")
  expect_match(
    req$url,
    "^https://sheets.googleapis.com/v4/spreadsheets/abc123\\?key=.+"
  )
  expect_null(req$token)
})
