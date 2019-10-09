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

test_that("resolve_sheet() errors if number > length of names", {
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

# as_range_spec() ----
test_that("as_range_spec() rejects hopeless input", {
  expect_error(as_range_spec(3), "Don't know how")
})

test_that("as_range_spec() can deal with nothingness", {
  spec <- as_range_spec(NULL)
  expect_null(spec$api_range)
})

test_that("as_range_spec() partitions 'Sheet1!A1:B2'", {
  spec <- as_range_spec("Sheet1!A1:B2")
  # we always escape sheet names before sending to API
  expect_identical(spec$api_range, "'Sheet1'!A1:B2")
  expect_identical(spec$sheet_name, "Sheet1")
  expect_identical(spec$A1_range, "A1:B2")
  expect_true(spec$shim)

  spec <- as_range_spec("'Sheet2'!A5:A")
  expect_identical(spec$api_range, "'Sheet2'!A5:A")
  # we always store unescaped name in range_spec
  expect_identical(spec$sheet_name, "Sheet2")
  expect_identical(spec$A1_range, "A5:A")
  expect_true(spec$shim)
})

test_that("as_range_spec() seeks a named range, then a sheet name", {
  nms <- c("a", "thingy", "z")

  spec <- as_range_spec("thingy", nr_names = nms)
  expect_identical(spec$api_range, "thingy")
  expect_null(spec$sheet_name)
  expect_identical(spec$named_range, "thingy")
  expect_false(spec$shim)

  spec <- as_range_spec("thingy", nr_names = nms, sheet_names = nms)
  expect_identical(spec$api_range, "thingy")
  expect_null(spec$sheet_name)
  expect_identical(spec$named_range, "thingy")
  expect_false(spec$shim)

  spec <- as_range_spec("thingy", nr_names = letters[1:3], sheet_names = nms)
  expect_identical(spec$api_range, "'thingy'")
  expect_null(spec$named_range)
  expect_identical(spec$sheet_name, "thingy")
  expect_false(spec$shim)
})

test_that("A1 range is detected, w/ or w/o sheet", {
  spec <- as_range_spec("1:2")
  expect_identical(spec$A1_range, "1:2")
  expect_identical(spec$api_range, "1:2")
  expect_true(spec$shim)

  spec <- as_range_spec("1:2", sheet = 3, sheet_names = LETTERS[1:3])
  expect_identical(spec$sheet_name, "C")
  expect_identical(spec$A1_range, "1:2")
  expect_identical(spec$api_range, "'C'!1:2")
  expect_true(spec$shim)

  spec <- as_range_spec("1:2", sheet = "B", sheet_names = LETTERS[1:3])
  expect_identical(spec$sheet_name, "B")
  expect_identical(spec$A1_range, "1:2")
  expect_identical(spec$api_range, "'B'!1:2")
  expect_true(spec$shim)
})

test_that("invalid range is rejected", {
  # no named ranges or sheet names for lookup --> interpret as A1
  expect_error(
    as_range_spec("thingy"),
    "doesn't appear to be"
  )

  expect_error(
    as_range_spec("thingy", nr_names = "nope", sheet_names = "nah"),
    "doesn't appear to be"
  )
})

test_that("unresolvable sheet raises error", {
  expect_error(as_range_spec("A5:A", sheet = 3), "no sheet names")
  expect_error(as_range_spec(x = NULL, sheet = 3), "no sheet names")
  expect_error(
    as_range_spec(x = NULL, sheet = "nope", sheet_names = LETTERS[1:3]),
    "No sheet found"
  )
  expect_error(
    as_range_spec("A5:A", sheet = "nope", sheet_names = LETTERS[1:3]),
    "No sheet found"
  )
  expect_error(
    as_range_spec("nope!A5:A", sheet_names = LETTERS[1:3]),
    "No sheet found"
  )
})

