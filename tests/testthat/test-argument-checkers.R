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

test_that("NULL or length zero col_types become '?'", {
  expect_identical(standardise_col_types(NULL), "?")
  expect_identical(standardise_col_types(character()), "?")
})

test_that("col_types understands and requires readr shortcodes", {
  good <- "-_?lidncTDt"
  expect_identical(standardise_col_types(good), good)
  expect_error(standardise_col_types("abc"), "must be .* shortcodes")
  expect_error(standardise_col_types(""), "must be .* shortcodes")
})

test_that("compatible col_names and col_types are tolerated", {
  expect_error_free(check_col_names_and_types(TRUE, NULL))
  expect_error_free(check_col_names_and_types(FALSE, NULL))
  expect_error_free(check_col_names_and_types(TRUE, "c"))
  expect_error_free(check_col_names_and_types(TRUE, "cc"))
  expect_error_free(check_col_names_and_types(c("a", "b"), NULL))
  expect_error_free(check_col_names_and_types(c("a", "b"), "c"))
  expect_error_free(check_col_names_and_types(c("a", "b"), "cc"))
  expect_error_free(check_col_names_and_types(c("a", "b"), "-c_c"))
})

test_that("incompatible col_names and col_types throw error", {
  expect_error(
    check_col_names_and_types(c("a", "b"), "ccc"),
    "must be one name for each"
  )
  expect_error(
    check_col_names_and_types(c("a", "b", "c"), "ii"),
    "must be one name for each"
  )
  expect_error(
    check_col_names_and_types(c("a", "b", "c"), "i_i"),
    "must be one name for each"
  )
})
