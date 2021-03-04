test_that("we can make a GridRange from a range_spec", {
  sheets_df <- tibble::tibble(name = "abc", id = 123)

  # test cases are taken from examples given for GridRange schema
  # https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/other#GridRange
  spec <- new_range_spec(sheet_name = "abc", sheets_df = sheets_df)
  out <- as_GridRange(spec)
  expect_equal(out$sheetId, 123)

  spec <- new_range_spec(
    sheet_name = "abc", cell_range = "A3:B4", sheets_df = sheets_df
  )
  out <- as_GridRange(spec)
  expect_equal(out$sheetId, 123)
  expect_equal(out$startRowIndex, 2)
  expect_equal(out$endRowIndex, 4)
  expect_equal(out$startColumnIndex, 0)
  expect_equal(out$endColumnIndex, 2)

  spec <- new_range_spec(
    sheet_name = "abc", cell_range = "A5:B", sheets_df = sheets_df
  )
  out <- as_GridRange(spec)
  expect_equal(out$sheetId, 123)
  expect_equal(out$startRowIndex, 4)
  expect_null(out$endRowIndex)
  expect_equal(out$startColumnIndex, 0)
  expect_equal(out$endColumnIndex, 2)

  spec <- new_range_spec(
    sheet_name = "abc", cell_range = "A:B", sheets_df = sheets_df
  )
  out <- as_GridRange(spec)
  expect_equal(out$sheetId, 123)
  expect_null(out$startRowIndex)
  expect_null(out$endRowIndex)
  expect_equal(out$startColumnIndex, 0)
  expect_equal(out$endColumnIndex, 2)

  spec <- new_range_spec(
    sheet_name = "abc", cell_range = "A1:A1", sheets_df = sheets_df
  )
  out <- as_GridRange(spec)
  expect_equal(out$sheetId, 123)
  expect_equal(out$startRowIndex, 0)
  expect_equal(out$endRowIndex, 1)
  expect_equal(out$startColumnIndex, 0)
  expect_equal(out$endColumnIndex, 1)

  spec1 <- new_range_spec(
    sheet_name = "abc", cell_range = "C3:C3", sheets_df = sheets_df
  )
  spec2 <- new_range_spec(
    sheet_name = "abc", cell_range = "C3", sheets_df = sheets_df
  )
  expect_equal(as_GridRange(spec1), as_GridRange(spec2))
})

test_that("we refuse to make a GridRange from a named_range", {
  spec <- new_range_spec(named_range = "thingy")
  expect_error(as_GridRange(spec), "does not accept a named range")
})
