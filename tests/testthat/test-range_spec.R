# as_range_spec() ----
test_that("as_range_spec() rejects hopeless input", {
  expect_error(as_range_spec(3), "Can't make a range")
})

test_that("as_range_spec() can deal with nothingness", {
  spec <- as_range_spec(NULL)
  expect_null(spec$A1_range)
})

test_that("as_range_spec() partitions 'Sheet1!A1:B2'", {
  spec <- as_range_spec("Sheet1!A1:B2")
  # we always escape sheet names before sending to API
  expect_identical(spec$A1_range, "'Sheet1'!A1:B2")
  expect_identical(spec$sheet_name, "Sheet1")
  expect_identical(spec$cell_range, "A1:B2")
  expect_true(spec$shim)

  spec <- as_range_spec("'Sheet2'!A5:A")
  expect_identical(spec$A1_range, "'Sheet2'!A5:A")
  # we always store unescaped name in range_spec
  expect_identical(spec$sheet_name, "Sheet2")
  expect_identical(spec$cell_range, "A5:A")
  expect_true(spec$shim)
})

test_that("as_range_spec() seeks a named range, then a sheet name", {
  nms <- c("a", "thingy", "z")

  spec <- as_range_spec("thingy", nr_names = nms)
  expect_identical(spec$A1_range, "thingy")
  expect_null(spec$sheet_name)
  expect_identical(spec$named_range, "thingy")
  expect_false(spec$shim)

  spec <- as_range_spec("thingy", nr_names = nms, sheet_names = nms)
  expect_identical(spec$A1_range, "thingy")
  expect_null(spec$sheet_name)
  expect_identical(spec$named_range, "thingy")
  expect_false(spec$shim)

  spec <- as_range_spec("thingy", nr_names = letters[1:3], sheet_names = nms)
  expect_identical(spec$A1_range, "'thingy'")
  expect_null(spec$named_range)
  expect_identical(spec$sheet_name, "thingy")
  expect_false(spec$shim)
})

test_that("A1 range is detected, w/ or w/o sheet", {
  spec <- as_range_spec("1:2")
  expect_identical(spec$cell_range, "1:2")
  expect_identical(spec$A1_range, "1:2")
  expect_true(spec$shim)

  spec <- as_range_spec("1:2", sheet = 3, sheet_names = LETTERS[1:3])
  expect_identical(spec$sheet_name, "C")
  expect_identical(spec$cell_range, "1:2")
  expect_identical(spec$A1_range, "'C'!1:2")
  expect_true(spec$shim)

  spec <- as_range_spec("1:2", sheet = "B", sheet_names = LETTERS[1:3])
  expect_identical(spec$sheet_name, "B")
  expect_identical(spec$cell_range, "1:2")
  expect_identical(spec$A1_range, "'B'!1:2")
  expect_true(spec$shim)
})

test_that("skip is honored", {
  spec <- as_range_spec(x = NULL, skip = 1)
  expect_match(spec$A1_range, "^2:[0-9]+$")
  expect_s3_class(spec$cell_limits, "cell_limits")
})

test_that("cell_limits input works, w/ or w/o sheet", {
  spec <- as_range_spec(cell_rows(1:2))
  expect_identical(spec$A1_range, "1:2")
  expect_true(spec$shim)

  spec <- as_range_spec(cell_rows(1:2), sheet = 3, sheet_names = LETTERS[1:3])
  expect_identical(spec$A1_range, "'C'!1:2")

  spec <- as_range_spec(cell_rows(1:2), sheet = "B", sheet_names = LETTERS[1:3])
  expect_identical(spec$A1_range, "'B'!1:2")
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
  expect_error(as_range_spec("A5:A", sheet = 3), "no sheet names")
  expect_error(as_range_spec(x = NULL, sheet = 3), "no sheet names")
  expect_error(
    as_range_spec(x = NULL, sheet = "nope", sheet_names = LETTERS[1:3]),
    "No sheet found"
  )
  expect_error(
    as_range_spec("A5:A", sheet = "nope", sheet_names = LETTERS[1:3]),
    "No sheet found"
  )
  expect_error(
    as_range_spec("nope!A5:A", sheet_names = LETTERS[1:3]),
    "No sheet found"
  )
})
