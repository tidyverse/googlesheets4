test_that("new() errors for non-existing id", {
  expect_error(new("I_don't_exist"), "Can't find")
})

test_that("new() works (and doesn't require data)", {
  out <- new("Spreadsheet")
  expect_length(out, 0)
  expect_s3_class(out, "googlesheets4_schema_Spreadsheet")
  expect_s3_class(out, "googlesheets4_schema")
  expect_s3_class(attr(out, "schema"), "tbl_df")
})

test_that("new() accepts data expected for schema", {
  out <- new("Spreadsheet", spreadsheetId = "abc")
  expect_identical(out$spreadsheetId, "abc")
})

test_that("new() rejects data not expected for schema", {
  expect_snapshot(
    new("Spreadsheet", foofy = "blah"),
    error = TRUE
  )
  expect_snapshot(
    new("Spreadsheet", foofy = "blah", foo = "bar"),
    error = TRUE
  )
})

test_that("new() ignores NULL-valued inputs", {
  out <- new("GridRange", sheetId = 123, startRowIndex = 2, endRowIndex = NULL)
  expect_false(has_name(out, "endRowIndex"))
})

test_that("patch() fails informatively for non-schema input", {
  expect_error(patch(1), "Don't know how")
})

test_that("patch() with no data passes input through", {
  out <- new("Spreadsheet", spreadsheetId = "abc")
  expect_identical(out, patch(out))
})

test_that("patch() accepts data expected for schema", {
  expect_identical(
    new("Spreadsheet", spreadsheetId = "abc"),
    new("Spreadsheet") %>% patch(spreadsheetId = "abc")
  )
})

test_that("patch() rejects data not expected for schema", {
  x <- new("Spreadsheet")
  expect_error(patch(x, foofy = "blah"), "not recognized")
})

test_that("patch() overwrites existing data", {
  x <- new("Spreadsheet", spreadsheetId = "abc")
  x <- patch(x, spreadsheetId = "xyz")
  expect_identical(x$spreadsheetId, "xyz")
  expect_length(x, 1)
})

test_that("patch() retains classes", {
  x <- new("Spreadsheet")
  classes_in <- class(x)
  x <- patch(x, spreadsheetId = "abc")
  classes_out <- class(x)
  expect_identical(classes_in, classes_out)
})

test_that("patch() ignores NULL-valued inputs", {
  out <- new("GridRange", sheetId = 123) %>%
    patch(startRowIndex = 2, endRowIndex = NULL)
  expect_false(has_name(out, "endRowIndex"))
})

test_that("check_against_schema() errors when no schema can be found", {
  x <- structure(
    list(google_thing = "a"),
    class = c("googlesheets4_schema_SomeThing", "googlesheets4_schema", "list")
  )
  expect_snapshot(
    check_against_schema(x),
    error = TRUE
  )
})

test_that("id_from_class() works when schema class is present", {
  x <- structure(
    list(google_thing = "a"),
    class = c("googlesheets4_schema_SomeThing", "googlesheets4_schema", "list")
  )
  expect_equal(id_from_class(x), "SomeThing")
})

test_that("check_against_schema() errors if names aren't unique", {
  expect_error(
    check_against_schema(
      list(spreadsheetId = "abc", spreadsheetId = "def"),
      id = "Spreadsheet"
    ),
    "is_dictionaryish(x) is not TRUE", fixed = TRUE
  )
})

test_that("id_from_class() returns NA when schema class is absent", {
  x <- structure(list(google_thing = "a"), class = "list")
  expect_equal(id_from_class(x), NA_character_)
})
