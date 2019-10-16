# sq_escape() and sq_unescape() ----
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

# qualified_A1() ----
test_that("qualified_A1 works", {
  expect_identical(qualified_A1(), "")
  expect_identical(qualified_A1("foo"), "'foo'")
  expect_identical(qualified_A1("foo", "A1"), "'foo'!A1")
  expect_identical(qualified_A1("'foo'"), "'foo'")
  expect_identical(qualified_A1(A1_range = "A1"), "A1")
})

# resolve_sheet() ----
test_that("resolve_sheet() is NULL in, NULL out", {
  expect_null(resolve_sheet())
})

test_that("resolve_sheet() requires sheet to be length-1 character or numeric", {
  expect_error(resolve_sheet(c("a", "b")), "length 1")
  expect_error(resolve_sheet(1:2), "length 1")
  expect_error(resolve_sheet(TRUE), "must be either")
})

test_that("resolve_sheet() requires sheet names if given sheet number", {
  expect_error(resolve_sheet(1), "no sheet names")
})

test_that("resolve_sheet() errors if number is incompatible with sheet names", {
  nms <- c("a", "foo", "z")
  expect_error(resolve_sheet(4, nms), "out-of-bounds")
  expect_error(resolve_sheet(0, nms), "out-of-bounds")
})

test_that("resolve_sheet() does not require sheet names for character input", {
  expect_identical(resolve_sheet("foo"), "foo")
})

test_that("resolve_sheet() consults sheet names, if given", {
  nms <- c("a", "foo", "z")
  expect_identical(resolve_sheet("foo", nms), "foo")
  expect_error(resolve_sheet("nope", nms), "No sheet found")
})

test_that("resolve_sheet() works with a number", {
  nms <- c("a", "foo", "z")
  expect_identical(resolve_sheet(2, nms), "foo")
})

# resolve_limits() ----
test_that("resolve_limits() leaves these cases unchanged", {
  expect_no_change <- function(cl) expect_identical(resolve_limits(cl), cl)

  expect_no_change(cell_limits(c(2, 2), c(3, 3)))
  expect_no_change(cell_limits(c(NA, NA), c(NA, NA)))
  expect_no_change(cell_limits(c(2, NA), c(3, NA)))
  expect_no_change(cell_limits(c(NA, 2), c(NA, 3)))
  expect_no_change(cell_limits(c(2, 2), c(3, NA)))
  expect_no_change(cell_limits(c(2, 2), c(NA, 3)))
})

test_that("resolve_limits() completes a row- or column-only range", {
  expect_identical(
    resolve_limits(cell_limits(c(2, NA), c(     NA, NA))),
                   cell_limits(c(2, NA), c(5000000, NA))
  )
  expect_identical(
    # I now think it's a bug that cell_limits() fills in this start row
    resolve_limits(cell_limits(c(NA, NA), c(3, NA))),
                   cell_limits(c(1, NA), c(3, NA))
  )
  expect_identical(
    resolve_limits(cell_limits(c(NA, 2), c(NA, NA))),
                   cell_limits(c(NA, 2), c(NA, 18278))
  )
  expect_identical(
    # I now think it's a bug that cell_limits() fills in this start column
    resolve_limits(cell_limits(c(NA, NA), c(NA, 3))),
                   cell_limits(c(NA, 1),  c(NA, 3))
  )
})

test_that("resolve_limits() completes upper left cell", {
  expect_identical(
    resolve_limits(cell_limits(c(2, NA), c(NA, 3))),
                   cell_limits(c(2, 1),  c(NA, 3))
  )
  expect_identical(
    resolve_limits(cell_limits(c(NA, 2), c(3, NA))),
                   cell_limits(c( 1, 2), c(3, NA))
  )
  expect_identical(
    resolve_limits(cell_limits(c(NA, NA), c(3, 3))),
                   cell_limits(c( 1,  1), c(3, 3))
  )
  expect_identical(
    resolve_limits(cell_limits(c(2, NA), c(3, 3))),
                   cell_limits(c(2,  1), c(3, 3))
  )
  expect_identical(
    resolve_limits(cell_limits(c(NA, 2), c(3, 3))),
                   cell_limits(c( 1, 2), c(3, 3))
  )
})

test_that("resolve_limits() populates column of lower right cell", {
  expect_identical(
    resolve_limits(cell_limits(c(2, 2), c(NA, NA))),
                   cell_limits(c(2, 2), c(NA, 18278))
  )
})
