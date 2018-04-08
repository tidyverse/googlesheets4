context("test-utils-cell-ranges.R")

test_that("sq_escape() does nothing if string already single-quoted", {
  x <- c("'abc'", "'ab'c'", "''")
  expect_identical(sq_escape(x), x)
})

test_that("sq_escape() duplicates single quotes and adds to start, end", {
  expect_identical(
    sq_escape(c(  "abc",    "'abc",    "abc'",     "'a'bc",    "'")),
              c("'abc'", "'''abc'", "'abc'''", "'''a''bc'", "''''")
  )
})

test_that("sq_unescape() does nothing if string is not single-quoted", {
  x <- c("abc", "'abc", "abc'", "a'bc", "'a'bc")
  expect_identical(sq_unescape(x), x)
})

test_that("sq_unescape() strips outer single quotes, de-duplicates inner", {
  expect_identical(
    sq_unescape(c("'abc'", "'''abc'", "'abc'''", "'''a''bc'", "''''")),
                c(  "abc",    "'abc",    "abc'",     "'a'bc",    "'")
  )
})

test_that("standardise_range() works", {
  sdf <- tibble::tribble(
     ~ name, ~ visible,
    "alpha",      TRUE,
     "beta",     FALSE,
    "gamma",      TRUE
  )
  expect_identical(
    standardise_range(sheet = NULL, range = NULL, sheet_df = sdf),
    "alpha"
  )
  expect_identical(
    standardise_range(sheet = NULL, range = "A1", sheet_df = sdf),
    "A1"
  )
  standardise_range(sheet = "beta", range = NULL, sheet_df = sdf)
  standardise_range(sheet = "gamma", range = NULL, sheet_df = sdf)
  standardise_range(sheet = "delta", range = NULL, sheet_df = sdf)
  standardise_range(sheet = -1, range = NULL, sheet_df = sdf)
  standardise_range(sheet = 2, range = NULL, sheet_df = sdf)
})
