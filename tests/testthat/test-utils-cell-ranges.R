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

test_that("standardise_range() falls back to first visible sheet (no range)", {
  sdf <- tibble::tribble(
     ~ name, ~ visible,
    "alpha",     FALSE,
     "beta",     TRUE
  )
  expect_identical(
    standardise_range(sheet = NULL, range = NULL, sheet_df = sdf),
    list(sheet = "beta", range = NULL)
  )
})

test_that("standardise_range() can look up a sheet by number", {
  sdf <- tibble::tribble(
    ~ name,  ~ visible,
    "alpha",      TRUE,
    "beta",      FALSE,
    "gamma",     FALSE,
    "delta",      TRUE
  )
  expect_identical(
    standardise_range(sheet = 1, range = NULL, sheet_df = sdf),
    list(sheet = "alpha", range = NULL)
  )
  expect_identical(
    standardise_range(sheet = 2, range = NULL, sheet_df = sdf),
    list(sheet = "delta", range = NULL)
  )
})

test_that("standardise_range() passes bare range through as range (no sheet)", {
  expect_identical(
    standardise_range(sheet = NULL, range = "A1"),
    list(sheet = NULL, range = "A1")
  )
  expect_identical(
    standardise_range(sheet = NULL, range = "A5:A"),
    list(sheet = NULL, range = "A5:A")
  )
})

test_that("standardise_range() prefers the sheet in `range` to `sheet`", {
  expect_identical(
    standardise_range(sheet = "nope", range = "yes!A5:A"),
    list(sheet = "yes", range = "A5:A")
  )
})

test_that("standardise_range() moves a named range from `range` to `sheet`", {
  ## if range has 3 or fewer characters, this will still fail (A, AA, AAA)
  ## TODO in code
  expect_identical(
    standardise_range(sheet = NULL, range = "beta"),
    list(sheet = "beta", range = NULL)
  )
  expect_identical(
    standardise_range(sheet = "nope", range = "beta"),
    list(sheet = "beta", range = NULL)
  )
})

test_that("standardise_range() errors for impossible numeric `sheet` input", {
  sdf <- tibble::tibble(name = "a", visible = TRUE)
  expect_error(
    standardise_range(sheet = -1, range = NULL, sheet_df = sdf),
    "Requested sheet number is -1"
  )
  expect_error(
    standardise_range(sheet = 2, range = NULL, sheet_df = sdf),
    "Requested sheet number is 2"
  )
})

test_that("standardise_range() errors for numeric sheet, if no sheet data", {
  expect_error(
    standardise_range(sheet = 1, range = NULL, sheet_df = NULL),
    "specified by number in the absence of"
  )
})

test_that("standardise_range() warns for numeric sheet, if only has range", {
  expect_warning(
    rg <- standardise_range(sheet = 2, range = "A1", sheet_df = NULL),
    "Ignoring"
  )
  expect_identical(
    rg,
    list(sheet = NULL, range = "A1")
  )
})
