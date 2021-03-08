# sq_escape() and sq_unescape() ----
test_that("sq_escape() and sq_unescape() pass NULL through", {
  expect_null(sq_escape(NULL))
  expect_null(sq_unescape(NULL))
})

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
  expect_null(qualified_A1())
  expect_identical(qualified_A1("foo"), "'foo'")
  expect_identical(qualified_A1("foo", "A1"), "'foo'!A1")
  expect_identical(qualified_A1("'foo'"), "'foo'")
  expect_identical(qualified_A1(cell_range = "A1"), "A1")
})

# lookup_sheet_name() ----
test_that("lookup_sheet_name() requires sheet to be length-1 character or numeric", {
  expect_error(lookup_sheet_name(c("a", "b")), "length 1")
  expect_error(lookup_sheet_name(1:2), "length 1")
  expect_error(lookup_sheet_name(TRUE), "must be either")
})

test_that("lookup_sheet_name() errors if number is incompatible with sheet names", {
  sheets_df <- tibble::tibble(name = c("a", "foo", "z"))
  expect_error(lookup_sheet_name(4, sheets_df), "out-of-bounds")
  expect_error(lookup_sheet_name(0, sheets_df), "out-of-bounds")
})

test_that("lookup_sheet_name() consults sheet names, if given", {
  sheets_df <- tibble::tibble(name = c("a", "foo", "z"))
  expect_identical(lookup_sheet_name("foo", sheets_df), "foo")
  expect_error(
    lookup_sheet_name("nope", sheets_df),
    class = "googlesheets4_error_sheet_not_found"
  )
})

test_that("lookup_sheet_name() works with a number", {
  sheets_df <- tibble::tibble(name = c("a", "foo", "z"))
  expect_identical(lookup_sheet_name(2, sheets_df), "foo")
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

# as_sheets_range ----

## "case numbers" refer to output produced by:
# tidyr::crossing(
#   start_row = c(NA, "start_row"), start_col = c(NA, "start_col"),
#   end_row = c(NA, "end_row"), end_col = c(NA, "end_col")
# )

test_that("as_sheets_range() works when all limits are given", {
  #  1 start_row start_col end_row end_col
  expect_identical(
    as_sheets_range(cell_limits(c(2, 2), c(3, 3))),
    "B2:C3"
  )
})

test_that("as_sheets_range() returns NULL when all limits are NA", {
  # 16 NA        NA        NA      NA
  expect_null(as_sheets_range(cell_limits()))
})

test_that("as_sheets_range() deals with row-only range", {
  #  6 start_row NA        end_row NA
  expect_identical(
    as_sheets_range(cell_limits(c(2, NA), c(3, NA))),
    "2:3"
  )
})

test_that("as_sheets_range() deals with column-only range", {
  # 11 NA        start_col NA      end_col
  expect_identical(
    as_sheets_range(cell_limits(c(NA, 2), c(NA, 3))),
    "B:C"
  )
})

test_that("as_sheets_range() deals when one of lr limits is missing", {
  #  2 start_row start_col end_row NA
  #  3 start_row start_col NA      end_col
  expect_identical(
    as_sheets_range(cell_limits(c(2, 2), c(3, NA))),
    "B2:3"
  )
  expect_identical(
    as_sheets_range(cell_limits(c(2, 2), c(NA, 3))),
    "B2:C"
  )
})

# TODO: I disabled this when switching to testthat 3e
# removing the mock of cellranger::cell_limits() didn't seem to hurt anything,
# which seems odd
#
# I have to think about cellranger soon, so revisit this when that happens
#
# commenting out, not skipping, because this is the only with_mock()

#test_that("as_sheets_range() errors for limits that should be fixed by resolve_limits()", {
  # I think cellranger::cell_limits() should do much less.
  # Already planning here for such a change there.
  # Here's a very crude version of what I have in mind.
  # cl <- function(ul, lr) {
  #   structure(
  #     list(ul = as.integer(ul), lr = as.integer(lr), sheet = NA_character_),
  #     class = c("cell_limits", "list")
  #   )
  # }
#   with_mock(
#     resolve_limits = function(x) x,
#     `cellranger:::cell_limits` = function(ul, lr, sheet) cl(ul, lr), {
#       #  5 start_row NA        end_row end_col
#       expect_error(as_sheets_range(cell_limits(c(2, NA), c(3, 3))))
#       #  9 NA        start_col end_row end_col
#       expect_error(as_sheets_range(cell_limits(c(NA, 2), c(3, 3))))
#       # 13 NA        NA        end_row end_col
#       expect_error(as_sheets_range(cell_limits(c(NA, NA), c(3, 3))))
#       #  8 start_row NA        NA      NA
#       expect_error(as_sheets_range(cell_limits(c(2, NA), c(NA, NA))))
#       # 14 NA        NA        end_row NA
#       expect_error(as_sheets_range(cell_limits(c(NA, NA), c(2, NA))))
#       # 12 NA        start_col NA      NA
#       expect_error(as_sheets_range(cell_limits(c(NA, 2), c(NA, NA))))
#       # 15 NA        NA        NA      end_col
#       expect_error(as_sheets_range(cell_limits(c(NA, NA), c(NA, 3))))
#       # 10 NA        start_col end_row NA
#       expect_error(as_sheets_range(cell_limits(c(NA, 2), c(3, NA))))
#       #  7 start_row NA        NA      end_col
#       expect_error(as_sheets_range(cell_limits(c(2, NA), c(NA, 3))))
#       #  4 start_row start_col NA      NA
#       expect_error(as_sheets_range(cell_limits(c(2, 2), c(NA, NA))))
#     }
#   )
# })
