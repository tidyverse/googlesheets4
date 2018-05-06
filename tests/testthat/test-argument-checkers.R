context("argument checkers")

test_that("col_names must be logical or character", {
  expect_error(check_col_names(1:3), "must be character")
  expect_error(check_col_names(factor("a")), "must be character")
})

test_that("logical col_names must be TRUE or FALSE", {
  expect_error(check_col_names(NA), "must be either TRUE or FALSE")
  expect_error(check_col_names(c(TRUE, FALSE)), "must be either TRUE or FALSE")
  expect_identical(check_col_names(TRUE), TRUE)
  expect_identical(check_col_names(FALSE), FALSE)
})

test_that("NULL col_types becomes 'COL_GUESS'", {
  expect_equivalent(standardise_ctypes(NULL), "COL_GUESS")
})

test_that("standardise_col_types() understands and requires readr shortcodes", {
  good <- "-_?lidncTDt"
  expect_equivalent(
    standardise_ctypes(good),
    c(`-` = "COL_SKIP", `_` = "COL_SKIP", `?` = "COL_GUESS", l = "CELL_LOGICAL",
      i = "CELL_INTEGER", d = "CELL_NUMERIC", n = "CELL_NUMERIC",
      c = "CELL_TEXT", T = "CELL_DATETIME", D = "CELL_DATE", t = "CELL_TIME")
  )
  expect_error(standardise_ctypes("abc"), "Unrecognized codes")
  expect_error(standardise_ctypes(""), "at least one")
})

test_that("compatible col_names and types are tolerated", {
  skip("fix this")
  expect_error_free(check_col_names_and_types(TRUE, NULL))
  expect_error_free(check_col_names_and_types(FALSE, NULL))
  expect_error_free(check_col_names_and_types(TRUE, "c"))
  expect_error_free(check_col_names_and_types(TRUE, c("c", "c")))
  expect_error_free(check_col_names_and_types(c("a", "b"), NULL))
  expect_error_free(check_col_names_and_types(c("a", "b"), "c"))
  expect_error_free(check_col_names_and_types(c("a", "b"), c("c", "c")))
  expect_error_free(check_col_names_and_types(c("a", "b"), c("_", "c", "_", "c")))
})

test_that("incompatible col_names and types throw error", {
  skip("fix this")
  expect_error(
    check_col_names_and_types(c("a", "b"), c("c", "c", "c")),
    "must be one name for each"
  )
  expect_error(
    check_col_names_and_types(c("a", "b", "c"), c("i","i")),
    "must be one name for each"
  )
  expect_error(
    check_col_names_and_types(c("a", "b", "c"), c("i", "_", "i")),
    "must be one name for each"
  )
})
