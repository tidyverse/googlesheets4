context("test-ctype")

test_that("ctype() errors for unanticipated inputs", {
  expect_error(ctype(NULL), "Cannot turn")
  expect_error(ctype(data.frame(cell = "cell")), "Don't know how to coerce")
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
  expect_equivalent(
    ctype(c("?", "-", "n", "z", "D")),
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
  expect_equivalent(
    ctype(list_of_cells),
    c("CELL_NUMERIC", NA, NA, NA, "CELL_TEXT")
  )
})

test_that("guess_col_type() doesn't just pass ctype through", {
  ## there is no such thing as a "blank" column --> logical!
  expect_equivalent(guess_col_type("CELL_BLANK"), "CELL_LOGICAL")
  ## neither the API nor JSON has a proper way to convey integer-ness
  expect_equivalent(guess_col_type("CELL_INTEGER"), "CELL_NUMERIC")
  ## conversion to date or time is lossy, so never guess that
  expect_equivalent(guess_col_type("CELL_DATE"), "CELL_DATETIME")
  expect_equivalent(guess_col_type("CELL_TIME"), "CELL_DATETIME")
})

test_that("consensus_col_type() works as promised", {
  ## the only case of X + Y, X != Y that doesn't lead to COL_LIST
  expect_identical(
    consensus_col_type(c("CELL_LOGICAL", "CELL_NUMERIC")),
    "CELL_NUMERIC"
  )
  expect_identical(
    consensus_col_type(c("CELL_NUMERIC", "CELL_LOGICAL")),
    "CELL_NUMERIC"
  )
  ## X + X leads to X
  expect_identical(consensus_col_type(c("CELL_???", "CELL_???")), "CELL_???")
  ## X + Y leads to COL_LIST
  expect_identical(consensus_col_type(c("CELL_X", "CELL_Y")), "COL_LIST")
  ## single input: typical ctype is passed through, special case for CELL_BLANK
  expect_identical(consensus_col_type("CELL_X"), "CELL_X")
  expect_identical(consensus_col_type("CELL_BLANK"), "CELL_LOGICAL")
})
