# ---- nm_fun ----
me_ <- nm_fun("TEST-range_write")

# ---- tests ----
test_that("range_write() works", {
  skip_if_offline()
  skip_if_no_token()

  n <- 3
  m <- 5
  data <- suppressMessages( # silence messages about name repair
    tibble::as_tibble(
      matrix(head(letters, n * m), nrow = n , ncol = m), .name_repair = "unique"
    )
  )

  ss <- local_ss(me_(), sheets = list(foo = data))
  # this is intentional below: refer to sheet in various ways

  # write into existing cells --> no size change
  range_write(ss, data[3:2, ])
  props <- sheet_properties(ss)
  expect_equal(props$grid_rows, n + 1)
  expect_equal(props$grid_columns, m)
  df <- read_sheet(ss)
  expect_identical(df[1, ], df[3, ])

  # write into non-existing cells --> sheet must grow
  range_write(ss, data, range = "foo!F5")
  props <- sheet_properties(ss)
  expect_equal(props$grid_rows, (5 - 1) + n + 1)
  expect_equal(props$grid_columns, (which(LETTERS == "F") - 1) + m)
  df <- read_sheet(ss, range = cell_cols(c("F", NA)))
  expect_equal(df, data)

  # write into existing and non-existing cells --> need new columns
  range_write(ss, data[1:3], sheet = "foo", range = "I2:K5")
  props <- sheet_properties(ss)
  expect_equal(props$grid_columns, (which(LETTERS == "K")))
  df <- read_sheet(ss, range = "I2:K5")
  expect_equal(df, data[1:3])
})

# https://github.com/tidyverse/googlesheets4/issues/203
test_that("we can write a hole-y tibble containing NULLs", {
  skip_if_offline()
  skip_if_no_token()

  dat_write <- tibble::tibble(A = list(NULL, "HI"), B = month.abb[1:2])

  ss <- local_ss(me_("write-NULL"), sheets = dat_write)
  write_sheet(dat_write, ss, sheet = 1)

  dat_read <- read_sheet(ss)
  expect_equal(dat_read$A, c(NA, "HI"))
  expect_equal(dat_read$B, dat_write$B)

  dat_read <- read_sheet(ss, col_types = "Lc")
  expect_equal(dat_read$A, dat_write$A)
  expect_equal(dat_read$B, dat_write$B)
})

# ---- helpers ----
test_that("prepare_loc() makes the right call re: `start` vs. `range`", {
  expect_loc <- function(x, loc) {
    sheets_df <- tibble::tibble(name = "Sheet1", index = 0, id = 123)
    out <- prepare_loc(as_range_spec(x, sheets_df = sheets_df))
    expect_named(out, loc)
  }

  expect_loc(NULL,     "start")
  expect_loc("Sheet1", "start")
  expect_loc("D4",     "start")
  expect_loc("B5:B5",  "start")
  expect_loc(cell_limits(c(5, 2), c(5, 2)), "start")

  expect_loc("B4:G9", "range")
  expect_loc("A2:F",  "range")
  expect_loc("A2:5",  "range")
  expect_loc("C:E",   "range")
  expect_loc("5:7",   "range")
  expect_loc(cell_limits(c(2, 4), c(NA, NA)), "range")
})

test_that("prepare_dims() works when write_loc is a `start` (a GridCoordinate)", {
  n <- 3
  m <- 5
  data <- suppressMessages( # silence messages about name repair
    tibble::as_tibble(
      matrix(head(letters, n * m), nrow = n , ncol = m), .name_repair = "unique"
    )
  )

  expect_dims <- function(loc, col_names, dims) {
    expect_equal(prepare_dims(loc, data, col_names = col_names), dims)
  }

  # no row or column info --> default offset is 0 (remember these are 0-indexed)
  loc <- list(start = new("GridCoordinate", sheetId = 123))
  expect_dims(loc, col_names = TRUE,  list(nrow = n + 1, ncol = m))
  expect_dims(loc, col_names = FALSE, list(nrow = n,     ncol = m))

  # row offset
  loc <- list(start = new("GridCoordinate", sheetId = 123, rowIndex = 2))
  expect_dims(loc, col_names = TRUE,  list(nrow = 2 + n + 1, ncol = m))
  expect_dims(loc, col_names = FALSE, list(nrow = 2 + n,     ncol = m))

  # column offset
  loc <- list(start = new("GridCoordinate", sheetId = 123, columnIndex = 3))
  expect_dims(loc, col_names = TRUE,  list(nrow = n + 1, ncol = 3 + m))
  expect_dims(loc, col_names = FALSE, list(nrow = n,     ncol = 3 + m))

  # row and column offset
  loc <- list(
    start = new("GridCoordinate", sheetId = 123, rowIndex = 2, columnIndex = 3)
  )
  expect_dims(loc, col_names = TRUE,  list(nrow = 2 + n + 1, ncol = 3 + m))
  expect_dims(loc, col_names = FALSE, list(nrow = 2 + n,     ncol = 3 + m))
})

test_that("prepare_dims() works when write_loc is a `range` (a GridRange)", {
  n <- 3
  m <- 5
  data <- suppressMessages( # silence messages about name repair
    tibble::as_tibble(
      matrix(head(letters, n * m), nrow = n , ncol = m), .name_repair = "unique"
    )
  )

  expect_dims <- function(x, col_names, dims) {
    sheets_df <- tibble::tibble(name = "Sheet1", index = 0)
    loc <- prepare_loc(as_range_spec(x, sheets_df = sheets_df))
    expect_equal(prepare_dims(loc, data, col_names = col_names), dims)
  }

  # fully specified range; lower right cell is all that matters
  expect_dims("B4:G9", col_names = TRUE,  list(nrow = 9, ncol = which(LETTERS == "G")))
  expect_dims("B4:G9", col_names = FALSE, list(nrow = 9, ncol = which(LETTERS == "G")))

  # range is open on the bottom
  # get row extent from upper left of range + data, column extent from range
  expect_dims("B3:D", col_names = TRUE,  list(nrow = 2 + n + 1, ncol = which(LETTERS == "D")))
  expect_dims("B3:D", col_names = FALSE, list(nrow = 2 + n ,    ncol = which(LETTERS == "D")))

  # range is open on the right
  # get row extent from range, column extent from range + data
  expect_dims("C3:5", col_names = TRUE,  list(nrow = 5, ncol = which(LETTERS == "C") + m - 1))
  expect_dims("C3:5", col_names = FALSE, list(nrow = 5, ncol = which(LETTERS == "C") + m - 1))

  # range is open on left (trivially) and on the right
  # get row extent from range, column extent from the data
  expect_dims("5:7", col_names = TRUE,  list(nrow = 7, ncol = m))
  expect_dims("5:7", col_names = FALSE, list(nrow = 7, ncol = m))

  # range is open on the top (trivially) and bottom
  # get row extent from data, column extent from range
  expect_dims("B:H", col_names = TRUE,  list(nrow = n + 1, ncol = which(LETTERS == "H")))
  expect_dims("B:H", col_names = FALSE, list(nrow = n,     ncol = which(LETTERS == "H")))

  # range is open on the bottom and right
  # get row extent from range + data, column extent from range + data
  expect_dims(
    cell_limits(c(2, 4), c(NA, NA)), col_names = TRUE,
                                    list(nrow = 2 + n + 1 - 1, ncol = 4 + m - 1)
  )
  expect_dims(
    cell_limits(c(2, 4), c(NA, NA)), col_names = FALSE,
                                    list(nrow = 2 + n - 1,     ncol = 4 + m - 1)
  )
})
