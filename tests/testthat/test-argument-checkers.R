test_that("col_names must be logical or character and have length", {
  expect_snapshot(check_col_names(1:3), error = TRUE)
  expect_snapshot(check_col_names(factor("a")), error = TRUE)
  expect_snapshot(check_col_names(character()), error = TRUE)
})

test_that("logical col_names must be TRUE or FALSE", {
  expect_snapshot(check_col_names(NA), error = TRUE)
  expect_snapshot(check_col_names(c(TRUE, FALSE)), error = TRUE)
  expect_identical(check_col_names(TRUE), TRUE)
  expect_identical(check_col_names(FALSE), FALSE)
})

test_that("standardise_ctypes() turns NULL col_types into 'COL_GUESS'", {
  expect_equal(standardise_ctypes(NULL), c("?" = "COL_GUESS"))
})

test_that("standardise_ctypes() errors for only 'COL_SKIP'", {
  errmsg <- "can't request that all columns be skipped"
  expect_error(standardise_ctypes("-"), errmsg)
  expect_error(standardise_ctypes("-_"), errmsg)
})

test_that("standardise_ctypes() understands and requires readr shortcodes", {
  good <- "_-lidnDtTcCL?"
  expect_equal(
    standardise_ctypes(good),
    c(`_` = "COL_SKIP", `-` = "COL_SKIP", l = "CELL_LOGICAL",
      i = "CELL_INTEGER", d = "CELL_NUMERIC", n = "CELL_NUMERIC",
      D = "CELL_DATE", t = "CELL_TIME", T = "CELL_DATETIME", c = "CELL_TEXT",
      C = "COL_CELL", L = "COL_LIST", `?` = "COL_GUESS")
  )
  expect_error(standardise_ctypes("abe"), "Unrecognized")
  expect_error(standardise_ctypes("f:"), "Unrecognized")
  expect_error(standardise_ctypes(""), "at least one")
})

test_that("col_types of right length are tolerated", {
  expect_identical(rep_ctypes(1, ctypes = "a"), "a")
  expect_identical(rep_ctypes(2, ctypes = c("a", "b")), c("a", "b"))
  expect_identical(
    rep_ctypes(2, ctypes = c("a", "b", "COL_SKIP")),
    c("a", "b", "COL_SKIP")
  )
})

test_that("a single col_types is repeated to requested length", {
  expect_identical(rep_ctypes(2, ctypes = "a"), c("a", "a"))
})

test_that("col_types with length > 1 and != n throw error", {
  expect_error(rep_ctypes(1, ctypes = rep("a", 2)), "not compatible")
  expect_error(rep_ctypes(3, ctypes = rep("a", 2)), "not compatible")
})

test_that("filter_col_names() removes entries for skipped columns", {
  expect_identical(filter_col_names(letters[1:2], letters[3:4]), letters[1:2])
  expect_identical(
    filter_col_names(letters[1:3], ctypes = c("a", "COL_SKIP", "c")),
    letters[c(1, 3)]
  )
})
