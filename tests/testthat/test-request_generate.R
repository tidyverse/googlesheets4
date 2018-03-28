context("test-request_generate.R")

test_that("can generate a basic request", {
  req <- request_generate(
    "spreadsheets.get",
    list(spreadsheetId = "abc123")
  )
  expect_identical(req$method, "GET")
  expect_match(
    req$url,
    "^https://sheets.googleapis.com/v4/spreadsheets/abc123\\?key=.+"
  )
  expect_null(req$token)
})
