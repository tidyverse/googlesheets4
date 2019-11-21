test_that("new_from_schema() errors for non-existing id", {
  expect_error(new_from_schema("I_don't_exist"), "Can't find")
})

test_that("new_from_schema() works (and doesn't require data)", {
  out <- new_from_schema("Spreadsheet")
  expect_length(out, 0)
  expect_s3_class(out, "googlesheets4_Spreadsheet")
  expect_s3_class(out, "googlesheets4_schema")
  expect_s3_class(attr(out, "schema"), "tbl_df")
})

test_that("new_from_schema() accepts data expected for schema", {
  out <- new_from_schema("Spreadsheet", spreadsheetId = "abc")
  expect_identical(out$spreadsheetId, "abc")
})

test_that("new_from_schema() rejects data not expected for schema", {
  expect_error(
    new_from_schema("Spreadsheet", foofy = "blah"),
    "not recognized"
  )
  expect_error(
    new_from_schema("Spreadsheet", foofy = "blah", foo = "bar"),
    "foofy, foo"
  )
})

test_that("patch() fails informatively for non-schema input", {
  expect_error(patch(1), "Don't know how")
})

test_that("patch() with no data passes input through", {
  out <- new_from_schema("Spreadsheet", spreadsheetId = "abc")
  expect_identical(out, patch(out))
})

test_that("patch() accepts data expected for schema", {
  expect_identical(
    new_from_schema("Spreadsheet", spreadsheetId = "abc"),
    new_from_schema("Spreadsheet") %>% patch(spreadsheetId = "abc")
  )
})

test_that("patch() rejects data not expected for schema", {
  x <- new_from_schema("Spreadsheet")
  expect_error(patch(x, foofy = "blah"), "not recognized")
})

test_that("patch() overwrites existing data", {
  x <- new_from_schema("Spreadsheet", spreadsheetId = "abc")
  x <- patch(x, spreadsheetId = "xyz")
  expect_identical(x$spreadsheetId, "xyz")
  expect_length(x, 1)
})

test_that("patch() retains classes", {
  x <- new_from_schema("Spreadsheet")
  classes_in <- class(x)
  x <- patch(x, spreadsheetId = "abc")
  classes_out <- class(x)
  expect_identical(classes_in, classes_out)
})
