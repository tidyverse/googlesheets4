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

test_that("resolve_sheet() errors for NULL or numeric sheet, if no sheet data", {
  expect_error(resolve_sheet(), "no sheet metadata")
  expect_error(resolve_sheet(sheet = 3), "no sheet metadata")
})

test_that("resolve_sheet() falls back to first visible sheet", {
  sdf <- tibble::tribble(
     ~ name, ~ visible,
    "alpha",     FALSE,
     "beta",     TRUE
  )
  expect_identical(resolve_sheet(sheet = NULL, sheet_df = sdf), "beta")
})

test_that("resolve_sheet() can look up a sheet by number", {
  sdf <- tibble::tribble(
    ~ name,  ~ visible,
    "alpha",      TRUE,
     "beta",     FALSE,
    "gamma",     FALSE,
    "delta",      TRUE
  )
  expect_identical(resolve_sheet(sheet = 1, sheet_df = sdf), "alpha")
  expect_identical(resolve_sheet(sheet = 2, sheet_df = sdf), "delta")
})

test_that("resolve_sheet() errors for impossible numeric `sheet` input", {
  sdf <- tibble::tibble(name = "a", visible = TRUE)
  expect_error(
    resolve_sheet(sheet = -1, sheet_df = sdf),
    "Requested sheet number is -1"
  )
  expect_error(
    resolve_sheet(sheet = 2, sheet_df = sdf),
    "Requested sheet number is 2"
  )
})

test_that("form_range_spec() prefers the sheet in `range` to `sheet`", {
  expect_identical(
    form_range_spec(sheet = "nope", range = "yes!A5:A7"),
    list(sheet = "yes", range = "A5:A7")
  )
})

test_that("form_range_spec() moves a named range from `range` to `sheet`", {
  ## if range has 3 or fewer characters, this will still fail (A, AA, AAA)
  ## TODO in code
  expect_identical(
    form_range_spec(sheet = NULL, range = "beta"),
    list(sheet = "beta", range = NULL)
  )
  expect_identical(
    form_range_spec(sheet = "nope", range = "beta"),
    list(sheet = "beta", range = NULL)
  )
})
