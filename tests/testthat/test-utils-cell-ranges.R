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

test_that("form_range_spec() can handle only a sheet / named range", {
  expect_identical(
    form_range_spec(sheet = "sheet")[["api_range"]],
    "'sheet'"
  )
  expect_identical(
    form_range_spec(range = "whatever")[["api_range"]],
    "'whatever'"
  )
})

test_that("form_range_spec() can handle cellranger input", {
  expect_identical(
    form_range_spec(sheet = "a", range = cell_rows(1:3))[["api_range"]],
    "'a'!1:3"
  )
})

test_that("form_range_spec() prefers the sheet in `range` to `sheet`", {
  expect_identical(
    form_range_spec(sheet = "nope", range = "yes!A5:A7")[["sheet"]],
    "yes"
  )
})

test_that("form_range_spec() moves a named range from `range` to `sheet`", {
  ## if range has 3 or fewer characters, this will still fail (A, AA, AAA)
  ## TODO in code
  expect_identical(
    form_range_spec(sheet = NULL, range = "beta")[["sheet"]],
    "beta"
  )
  expect_identical(
    form_range_spec(sheet = "nope", range = "beta")[["sheet"]],
    "beta"
  )
})

test_that("as_sheets_range() works when it should and vice versa", {
  # numbering comes from
  # tidyr::crossing(
  #   start_row = c(NA, "start_row"), start_col = c(NA, "start_col"),
  #   end_row = c(NA, "end_row"), end_col = c(NA, "end_col")
  # )

  ## nothing is specified
  # 16 NA        NA        NA      NA
  expect_null(as_sheets_range(cell_limits()))

  ## end_row and end_col are specified --> lower right cell is fully specified
  #  1 start_row start_col end_row end_col
  #  5 start_row NA        end_row end_col
  #  9 NA        start_col end_row end_col
  # 13 NA        NA        end_row end_col
  expect_identical(as_sheets_range(cell_limits(c(2, 2), c(3, 4))), "B2:D3")
  expect_identical(as_sheets_range(cell_limits(c(2, NA), c(3, 4))), "A2:D3")
  expect_identical(as_sheets_range(cell_limits(c(NA, 2), c(3, 4))), "B1:D3")
  expect_identical(as_sheets_range(cell_limits(c(NA, NA), c(3, 4))), "A1:D3")

  ## no cols specified, but end_row is
  #  6 start_row NA        end_row NA
  # 14 NA        NA        end_row NA
  expect_identical(as_sheets_range(cell_limits(c(2, NA), c(5, NA))), "2:5")
  expect_identical(as_sheets_range(cell_limits(c(NA, NA), c(5, NA))), "1:5")
  ## no rows specified, but end_col is
  # 11 NA        start_col NA      end_col
  # 15 NA        NA        NA      end_col
  expect_identical(as_sheets_range(cell_limits(c(NA, 2), c(NA, 5))), "B:E")
  expect_identical(as_sheets_range(cell_limits(c(NA, NA), c(NA, 5))), "A:E")

  #  2 start_row start_col end_row NA
  #  3 start_row start_col NA      end_col
  #  4 start_row start_col NA      NA
  expect_error(as_sheets_range(cell_limits(c(1, 2), c(3, NA))), "Can't express")
  expect_error(as_sheets_range(cell_limits(c(1, 2), c(NA, 3))), "Can't express")
  expect_error(as_sheets_range(cell_limits(c(1, 2), c(NA, NA))), "Can't express")
  #  7 start_row NA        NA      end_col
  #  8 start_row NA        NA      NA
  # 10 NA        start_col end_row NA
  # 12 NA        start_col NA      NA
  expect_error(as_sheets_range(cell_limits(c(1, NA), c(NA, 3))), "Can't express")
  expect_error(as_sheets_range(cell_limits(c(1, NA), c(NA, NA))), "Can't express")
  expect_error(as_sheets_range(cell_limits(c(NA, 2), c(3, NA))), "Can't express")
  expect_error(as_sheets_range(cell_limits(c(NA, 2), c(NA, NA))), "Can't express")
})

test_that("resolve_limits() populates max row/col when min is specified", {
  ## cell_limits that require no modification
  unchanged <- list(
    # 16 NA        NA        NA      NA
    cell_limits(),
    #  1 start_row start_col end_row end_col
    #  5 start_row NA        end_row end_col
    #  9 NA        start_col end_row end_col
    # 13 NA        NA        end_row end_col
    cell_limits(c(2, 2), c(3, 4)),
    cell_limits(c(2, NA), c(3, 4)),
    cell_limits(c(NA, 2), c(3, 4)),
    cell_limits(c(NA, NA), c(3, 4)),
    #  6 start_row NA        end_row NA
    # 14 NA        NA        end_row NA
    cell_limits(c(2, NA), c(5, NA)),
    cell_limits(c(NA, NA), c(5, NA)),
    ## no rows specified, but end_col is
    # 11 NA        start_col NA      end_col
    # 15 NA        NA        NA      end_col
    cell_limits(c(NA, 2), c(NA, 5)),
    cell_limits(c(NA, NA), c(NA, 5))
  )
  expect_identical(unchanged, map(unchanged, resolve_limits))

  se <- list(grid_rows = 3, grid_columns = 3)
  ref <- cell_limits(c(1, 2), c(3, 3))
  #  2 start_row start_col end_row NA
  #  3 start_row start_col NA      end_col
  #  4 start_row start_col NA      NA
  expect_identical(resolve_limits(cell_limits(c(1, 2), c(3, NA)), se), ref)
  expect_identical(resolve_limits(cell_limits(c(1, 2), c(NA, 3)), se), ref)
  expect_identical(resolve_limits(cell_limits(c(1, 2), c(NA, NA)), se), ref)
  #  7 start_row NA        NA      end_col
  #  8 start_row NA        NA      NA
  # 10 NA        start_col end_row NA
  # 12 NA        start_col NA      NA
  expect_identical(
    resolve_limits(cell_limits(c(1, NA), c(NA, 3)), se),
    cell_limits(c(1, NA), c(3, 3))
  )
  expect_identical(
    resolve_limits(cell_limits(c(1, NA), c(NA, NA)), se),
    cell_limits(c(1, NA), c(3, NA))
  )
  expect_identical(
    resolve_limits(cell_limits(c(NA, 2), c(3, NA)), se),
    cell_limits(c(NA, 2), c(3, 3))
  )
  expect_identical(
    resolve_limits(cell_limits(c(NA, 2), c(NA, NA)), se),
    cell_limits(c(NA, 2), c(NA, 3))
  )
})
