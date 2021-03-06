test_that("ctype() errors for unanticipated inputs", {
  expect_error(ctype(NULL))
  expect_error(ctype(data.frame(cell = "cell")))
})

test_that("ctype() works on a SHEET_CELL, when it should", {
  expect_identical(
    ctype(structure(1, class = c("wut", "SHEETS_CELL"))),
    NA_character_
  )
  expect_identical(
    ctype(structure(1, class = c("CELL_NUMERIC", "SHEETS_CELL"))),
    "CELL_NUMERIC"
  )
})

test_that("ctype() works on shortcodes, when it should", {
  expect_equal(
    unname(ctype(c("?", "-", "n", "z", "D"))),
    c("COL_GUESS", "COL_SKIP", "CELL_NUMERIC", NA, "CELL_DATE")
  )
})

test_that("ctype() works on lists, when it should", {
  list_of_cells <- list(
    structure(1, class = c("CELL_NUMERIC", "SHEETS_CELL")),
    "nope",
    NULL,
    structure(1, class = c("wut", "SHEETS_CELL")),
    structure(1, class = c("CELL_TEXT", "SHEETS_CELL"))
  )
  expect_equal(
    ctype(list_of_cells),
    c("CELL_NUMERIC", NA, NA, NA, "CELL_TEXT")
  )
})

test_that("effective_cell_type() doesn't just pass ctype through", {
  ## neither the API nor JSON has a proper way to convey integer-ness
  expect_equal(unname(effective_cell_type("CELL_INTEGER")), "CELL_NUMERIC")
  ## conversion to date or time is lossy, so never guess that
  expect_equal(unname(effective_cell_type("CELL_DATE")), "CELL_DATETIME")
  expect_equal(unname(effective_cell_type("CELL_TIME")), "CELL_DATETIME")
})

test_that("consensus_col_type() implements our type coercion DAG", {
  expect_identical(
    consensus_col_type(c("CELL_TEXT", "CELL_TEXT")),
    "CELL_TEXT"
  )
  expect_identical(
    consensus_col_type(c("CELL_LOGICAL", "CELL_NUMERIC")),
    "CELL_NUMERIC"
  )
  expect_identical(
    consensus_col_type(c("CELL_LOGICAL", "CELL_DATE")),
    "COL_LIST"
  )
  expect_identical(
    consensus_col_type(c("CELL_DATE", "CELL_DATETIME")),
    "CELL_DATETIME"
  )
  expect_identical(
    consensus_col_type(c("CELL_TEXT", "CELL_BLANK")),
    "CELL_TEXT"
  )
  expect_identical(consensus_col_type("CELL_TEXT"), "CELL_TEXT")
  expect_identical(consensus_col_type("CELL_BLANK"), "CELL_LOGICAL")
})
