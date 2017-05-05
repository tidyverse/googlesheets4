context("Build requests")

test_that("non-existent endpoint errors", {
  expect_error(
    gs_build_request("foo"),
    "Endpoint not recognized:\nfoo"
  )
})

test_that("request with no parameters works", {
  req <- gs_build_request("spreadsheets.create")
  expect_identical(
    req$url,
    "https://sheets.googleapis.com/v4/spreadsheets"
  )
})

test_that("path parameters are required", {
  expect_error(
    gs_build_request("spreadsheets.get"),
    "Required parameter(s) are missing:",
    fixed = TRUE
  )
})

test_that("path parameters are substituted", {
  req <- gs_build_request(
    "spreadsheets.get",
    list(spreadsheetId = "abc")
  )
  expect_identical(
    req$url,
    "https://sheets.googleapis.com/v4/spreadsheets/abc"
  )

  req <- gs_build_request(
    "spreadsheets.sheets.copyTo",
    list(spreadsheetId = "abc", sheetId = "def")
  )
  expect_identical(
    req$url,
    "https://sheets.googleapis.com/v4/spreadsheets/abc/sheets/def:copyTo"
  )
})

test_that("unknown parameters are dropped and messaged", {
  expect_message(
    req <- gs_build_request(
      "spreadsheets.get",
      list(spreadsheetId = "abc", x = "x", y = "y")
    ),
    "Ignoring these unrecognized parameters:\nx: x\ny: y"
  )
  expect_identical(
    req$url,
    "https://sheets.googleapis.com/v4/spreadsheets/abc"
  )
})

test_that("parameters with length > 1 are caught", {
  expect_error(
    req <- gs_build_request(
      "spreadsheets.get",
      list(spreadsheetId = "abc", includeGridData = c(TRUE, FALSE))
    ),
    "These parameter(s) are not allowed to have length > 1:\nincludeGridData",
    fixed = TRUE
  )
})

test_that("repeated parameters are caught", {
  expect_error(
    req <- gs_build_request(
      "spreadsheets.get",
      list(
        spreadsheetId = "abc",
        includeGridData = TRUE,
        includeGridData = FALSE
      )
    ),
    "These parameter(s) are not allowed to appear more than once:\nincludeGridData",
    fixed = TRUE
  )
})

test_that("ranges can have length > 1 and get expanded", {
  expect_silent(
    req <- gs_build_request(
      "spreadsheets.get",
      list(
        spreadsheetId = "abc",
        ranges = c("Sheet1!A1:B2", "Sheet1!D:D")
      )
    )
  )
  expect_identical(
    req$url,
    "https://sheets.googleapis.com/v4/spreadsheets/abc?ranges=Sheet1%21A1%3AB2&ranges=Sheet1%21D%3AD"
  )
})

test_that("ranges can be explicitly repeated", {
  expect_silent(
    req <- gs_build_request(
      "spreadsheets.get",
      list(
        spreadsheetId = "abc",
        ranges = "Sheet1!A1:B2",
        ranges = "Sheet1!D:D"
      )
    )
  )
  expect_identical(
    req$url,
    "https://sheets.googleapis.com/v4/spreadsheets/abc?ranges=Sheet1%21A1%3AB2&ranges=Sheet1%21D%3AD"
  )
})

test_that("valid enum values are accepted", {
  expect_silent(
    req <- gs_build_request(
      "spreadsheets.values.append",
      list(
        spreadsheetId = "abc",
        range = "Sheet1!A1:B2",
        responseValueRenderOption = "FORMULA",
        valueInputOption = "RAW"
      )
    )
  )
  expect_identical(
    req$url,
    "https://sheets.googleapis.com/v4/spreadsheets/abc/values/Sheet1!A1:B2:append?responseValueRenderOption=FORMULA&valueInputOption=RAW"
  )
})

test_that("invalid enum values are detected, messaged, and errored", {
  expect_error(
    expect_message(
      req <- gs_build_request(
        "spreadsheets.values.append",
        list(
          spreadsheetId = "abc",
          range = "Sheet1!A1:B2",
          responseValueRenderOption = "FOO",
          valueInputOption = "FOO"
        )
      ),
      "Parameter '[a-zA-Z]+' has value 'FOO', but it must be one of these"
    ),
    "Invalid parameter value(s).",
    fixed = TRUE
  )
})
