test_that("cells() returns `row` and `col` as integer", {
  skip_if_offline()
  skip_if_no_token()

  out <- range_read_cells(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!A1:B2"
  )
  expect_true(is.integer(out$row))
  expect_true(is.integer(out$col))
})

test_that("slightly tricky `range`s work", {
  skip_if_offline()
  skip_if_no_token()

  out <- range_read_cells(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!B:D"
  )
  expect_true(all(grepl("^[BCD]", out$loc)))

  out <- range_read_cells(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!2:3"
  )
  expect_true(all(grepl("[23]$", out$loc)))

  out <- range_read_cells(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!B3:C"
  )
  expect_true(all(grepl("^[BC]", out$loc)))
  expect_true(all(grepl("[3-9]$", out$loc)))

  out <- range_read_cells(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!B3:5"
  )
  expect_true(all(grepl("^[BCDE]", out$loc)))
  expect_true(all(grepl("[345]$", out$loc)))
})

# https://github.com/tidyverse/googlesheets4/issues/4
test_that("full cell data and empties are within reach", {
  skip_if_offline()
  skip_if_no_token()

  out <- range_read_cells(
    test_sheet("googlesheets4-cell-tests"),
    sheet = "empties-and-formats",
    cell_data = "full", discard_empty = FALSE
  )

  # B2 is empty; make sure it's here
  expect_true("B2" %in% out$loc)

  # C2 is empty and orange; make sure it's here and format is available
  expect_error_free(
    cell <- out$cell[[which(out$loc == "C2")]]
  )
  expect_true(!is.null(cell$effectiveFormat))

  # C1 bears a note
  expect_error_free(
    cell <- out$cell[[which(out$loc == "C1")]]
  )
  note <- cell$note
  expect_true(!is.null(note))
  expect_match(note, "Note")
})

# https://github.com/tidyverse/googlesheets4/issues/78
test_that("formula cells are parsed based on effectiveValue", {
  skip_if_offline()
  skip_if_no_token()

  out <- range_read_cells(
    test_sheet("googlesheets4-cell-tests"),
    sheet = "formulas",
    range = "B:B",
    cell_data = "full", discard_empty = FALSE
  )

  expect_s3_class(out$cell[[which(out$loc == "B2")]], "CELL_TEXT")
  expect_s3_class(out$cell[[which(out$loc == "B3")]], "CELL_NUMERIC")
  expect_s3_class(out$cell[[which(out$loc == "B4")]], "CELL_BLANK")
  expect_s3_class(out$cell[[which(out$loc == "B5")]], "CELL_TEXT")
  expect_s3_class(out$cell[[which(out$loc == "B6")]], "CELL_BLANK")
})
