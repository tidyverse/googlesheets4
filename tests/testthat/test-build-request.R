context("Build requests")

test_that("path and method are required", {
  expect_error(
    gs_build_request(),
    "argument \"path\" is missing, with no default"
  )
  expect_error(
    gs_build_request(path = "v4/spreadsheets/{spreadsheetId}"),
    "argument \"method\" is missing, with no default"
  )
})

test_that("path parameters are substituted, all leftovers go in query", {
  req <- gs_build_request(
    path = "v4/spreadsheets/{spreadsheetId}/sheets/{sheetId}:copyTo",
    method = "POST",
    list(spreadsheetId = "abc", sheetId = "def", vegetable = "cabbage")
  )
  expect_match(
    req$url,
    "https://sheets.googleapis.com/v4/spreadsheets/abc/sheets/def:copyTo?vegetable=cabbage",
    fixed = TRUE
  )
})

test_that("built-in API key is sent by default", {
  req <- gs_build_request("v4/spreadsheets", "POST")
  expect_match(
    req$url,
    paste0(
      "https://sheets.googleapis.com/v4/spreadsheets?key=",
      getOption("googlesheets.api.key")
    ),
    fixed = TRUE
  )
})

test_that("API key can be specified directly", {
  req <- gs_build_request("v4/spreadsheets", "POST", .api_key = "abc")
  expect_identical(
    req$url,
    "https://sheets.googleapis.com/v4/spreadsheets?key=abc"
  )
})
