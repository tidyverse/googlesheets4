test_that("we can make a GridCoordinate from a range_spec, simplest case", {
  sheets_df <- tibble::tibble(name = "abc", id = 123)

  spec <- new_range_spec(sheet_name = "abc", sheets_df = sheets_df)
  out <- as_GridCoordinate(spec)
  expect_equal(out$sheetId, 123)
  expect_length(out, 1)

  spec <- new_range_spec(
    sheet_name = "abc", cell_range = "G3", sheets_df = sheets_df
  )
  out <- as_GridCoordinate(spec)
  expect_equal(out$rowIndex, 2)
  expect_equal(out$columnIndex, 6)
})

test_that("we can (or won't) make a GridCoordinate from a mutli-cell range", {
  sheets_df <- tibble::tibble(name = "abc", id = 123)

  spec <- new_range_spec(
    sheet_name = "abc", cell_range = "A3:B4", sheets_df = sheets_df
  )
  expect_error(as_GridCoordinate(spec), "Invalid cell range")

  spec2 <- new_range_spec(
    sheet_name = "abc", cell_range = "A3", sheets_df = sheets_df
  )
  expect_equal(
    as_GridCoordinate(spec, strict = FALSE),
    as_GridCoordinate(spec2)
  )

  spec <- new_range_spec(
    sheet_name = "abc", cell_range = "A:B", sheets_df = sheets_df
  )
  out <- as_GridCoordinate(spec, strict = FALSE)
  expect_null(out$rowIndex)
  expect_equal(out$columnIndex, 0)

  spec <- new_range_spec(
    sheet_name = "abc", cell_range = "2:4", sheets_df = sheets_df
  )
  out <- as_GridCoordinate(spec, strict = FALSE)
  expect_equal(out$rowIndex, 1)
  expect_null(out$columnIndex)
})
