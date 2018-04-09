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

test_that("standardise_range() selects first visible sheet as last resort", {
  sdf <- tibble::tribble(
     ~ name, ~ visible,
    "alpha",     FALSE,
     "beta",     TRUE
  )
  expect_identical(
    standardise_range(sheet = NULL, range = NULL, sheet_df = sdf),
    "'beta'"
  )
})

test_that("standardise_range() passes bare range through as range (no sheet)", {
  expect_identical(
    standardise_range(sheet = NULL, range = "A1"),
    "A1"
  )
  expect_identical(
    standardise_range(sheet = NULL, range = "A5:A"),
    "A5:A"
  )
})

test_that("standardise_range() returns sheet, by name or number (no range)", {
  expect_identical(
    standardise_range(sheet = "beta", range = NULL),
    "'beta'"
  )

  sdf <- tibble::tribble(
    ~ name,  ~ visible,
    "alpha",      TRUE,
    "beta",      FALSE,
    "gamma",     FALSE,
    "delta",      TRUE
  )
  expect_identical(
    standardise_range(sheet = 1, range = NULL, sheet_df = sdf),
    "'alpha'"
  )
  expect_identical(
    standardise_range(sheet = 2, range = NULL, sheet_df = sdf),
    "'delta'"
  )
})

test_that("standardise_range() adds a sheet (name or number) to a bare range", {
  expect_identical(
    standardise_range(sheet = "a['!", range = "A5:A"),
    "'a[''!'!A5:A"
  )
  sdf <- tibble::tribble(
    ~ name, ~ visible,
    "alpha",     FALSE,
     "beta",     TRUE
  )
  expect_identical(
    standardise_range(sheet = 1, range = "A5:A", sheet_df = sdf),
    "'beta'!A5:A"
  )
})

test_that("standardise_range() prefers the sheet in `range` to `sheet`", {
  expect_identical(
    standardise_range(sheet = "nope", range = "yes!A5:A"),
    "'yes'!A5:A"
  )
})

test_that("standardise_range() passes a named range through from `range`", {
  ## if range has 3 or fewer characters, this will still fail (A, AA, AAA)
  ## TODO in code
  expect_identical(
    standardise_range(sheet = NULL, range = "beta", sheet_df = sdf),
    "'beta'"
  )
  expect_identical(
    standardise_range(sheet = "nope", range = "beta", sheet_df = sdf),
    "'beta'"
  )
})

test_that("standardise_range() errors impossible numeric `sheet` input", {
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
