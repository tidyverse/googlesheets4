# as_range_spec() ----
test_that("as_range_spec() rejects hopeless input", {
  expect_error(as_range_spec(3), "Can't make a range")
})

test_that("as_range_spec() can deal with nothingness", {
  spec <- as_range_spec(NULL)
  expect_true(all(map_lgl(spec, ~ is.null(.x) || isFALSE(.x))))
})

test_that("as_range_spec() partitions 'Sheet1!A1:B2'", {
  sheets_df <- tibble::tibble(name = "Sheet1")

  spec <- as_range_spec("Sheet1!A1:B2", sheets_df = sheets_df)
  expect_identical(spec$sheet_name, "Sheet1")
  expect_identical(spec$cell_range, "A1:B2")
  expect_true(spec$shim)

  spec <- as_range_spec("'Sheet1'!A5:A", sheets_df = sheets_df)
  # make sure we store unescaped name in range_spec
  expect_identical(spec$sheet_name, "Sheet1")
  expect_identical(spec$cell_range, "A5:A")
  expect_true(spec$shim)
})

test_that("as_range_spec() seeks a named range, then a sheet name", {
  nr_df <- tibble::tibble(name = c("a", "thingy", "z"))

  spec <- as_range_spec("thingy", nr_df = nr_df)
  expect_null(spec$sheet_name)
  expect_identical(spec$named_range, "thingy")
  expect_false(spec$shim)

  spec <- as_range_spec("thingy", nr_df = nr_df, sheets_df = nr_df)
  expect_null(spec$sheet_name)
  expect_identical(spec$named_range, "thingy")
  expect_false(spec$shim)

  spec <- as_range_spec(
    "thingy",
    nr_df = tibble::tibble(name = letters[1:3]),
    sheets_df = nr_df
  )
  expect_null(spec$named_range)
  expect_identical(spec$sheet_name, "thingy")
  expect_false(spec$shim)
})

test_that("A1 range is detected, w/ or w/o sheet", {
  spec <- as_range_spec("1:2")
  expect_identical(spec$cell_range, "1:2")
  expect_true(spec$shim)

  sheets_df <- tibble::tibble(name = LETTERS[1:3])
  spec <- as_range_spec("1:2", sheet = 3, sheets_df = sheets_df)
  expect_identical(spec$sheet_name, "C")
  expect_identical(spec$cell_range, "1:2")
  expect_true(spec$shim)

  spec <- as_range_spec("1:2", sheet = "B", sheets_df = sheets_df)
  expect_identical(spec$sheet_name, "B")
  expect_identical(spec$cell_range, "1:2")
  expect_true(spec$shim)
})

test_that("skip is converted to equivalent cell limits", {
  spec <- as_range_spec(x = NULL, skip = 1)
  expect_equal(spec$cell_limits, cell_rows(c(2, NA)))
})

test_that("cell_limits input works, w/ or w/o sheet", {
  spec <- as_range_spec(cell_rows(1:2))
  expect_equal(spec$cell_limits, cell_rows(1:2))
  expect_true(spec$shim)

  sheets_df <- tibble::tibble(name = LETTERS[1:3])

  spec <- as_range_spec(cell_rows(1:2), sheet = 3, sheets_df = sheets_df)
  expect_equal(spec$sheet_name, "C")
  expect_equal(spec$cell_limits, cell_rows(1:2))
  expect_true(spec$shim)

  spec <- as_range_spec(cell_rows(1:2), sheet = "B", sheets_df = sheets_df)
  expect_equal(spec$sheet_name, "B")
  expect_equal(spec$cell_limits, cell_rows(1:2))
  expect_true(spec$shim)
})

test_that("invalid range is rejected", {
  # no named ranges or sheet names for lookup --> interpret as A1
  expect_error(
    as_range_spec("thingy"),
    "doesn't appear to be"
  )

  expect_error(
    as_range_spec("thingy", nr_names = "nope", sheet_names = "nah"),
    "doesn't appear to be"
  )
})

test_that("unresolvable sheet raises error", {
  expect_gs4_error(as_range_spec("A5:A", sheet = 3), "Can't look up")
  expect_gs4_error(as_range_spec(x = NULL, sheet = 3), "Can't look up")
  sheets_df <- tibble::tibble(name = LETTERS[1:3])
  expect_error(
    as_range_spec(x = NULL, sheet = "nope", sheets_df = sheets_df),
    class = "googlesheets4_error_sheet_not_found"
  )
  expect_error(
    as_range_spec("A5:A", sheet = "nope", sheets_df = sheets_df),
    class = "googlesheets4_error_sheet_not_found"
  )
  expect_error(
    as_range_spec("nope!A5:A", sheets_df = sheets_df),
    class = "googlesheets4_error_sheet_not_found"
  )
})

# as_A1_range() ----
test_that("as_A1_range() works", {
  expect_null(as_A1_range(new_range_spec()))

  expect_equal(as_A1_range(new_range_spec(sheet_name = "Sheet1")), "'Sheet1'")

  expect_equal(as_A1_range(new_range_spec(named_range = "abc")), "abc")

  expect_equal(as_A1_range(new_range_spec(cell_range = "B3:D9")), "B3:D9")
  expect_equal(
    as_A1_range(new_range_spec(sheet_name = "Sheet1", cell_range = "A1")),
    "'Sheet1'!A1"
  )

  rs <- new_range_spec(cell_limits = cell_cols(3:5))
  expect_equal(as_A1_range(rs), "C:E")

  rs <- new_range_spec(sheet_name = "Sheet1", cell_limits = cell_rows(2:3))
  expect_equal(as_A1_range(rs), "'Sheet1'!2:3")
})
