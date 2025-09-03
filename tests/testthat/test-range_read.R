test_that("read_sheet() works and discovers reasonable types", {
  skip_if_offline()
  skip_if_no_token()

  dat <- range_read(
    test_sheet("googlesheets4-col-types"),
    sheet = "lots-of-types"
  )
  expect_type(dat$logical, "logical")
  expect_type(dat$character, "character")
  expect_type(dat$factor, "character")
  expect_type(dat$integer, "double")
  expect_type(dat$double, "double")
  expect_s3_class(dat$date, "POSIXct")
  expect_s3_class(dat$datetime, "POSIXct")
})

test_that("read_sheet() enacts user-specified coltypes", {
  skip_if_offline()
  skip_if_no_token()

  dat <- range_read(
    test_sheet("googlesheets4-col-types"),
    sheet = "lots-of-types",
    col_types = "lccinDT"
  )
  expect_type(dat$logical, "logical")
  expect_type(dat$character, "character")
  expect_type(dat$factor, "character") # TODO: revisit when 'f' means factor
  expect_type(dat$integer, "integer")
  expect_type(dat$double, "double")
  expect_s3_class(dat$date, "Date")
  expect_s3_class(dat$datetime, "POSIXct")
})

test_that("read_sheet() can skip columns", {
  skip_if_offline()
  skip_if_no_token()

  dat <- range_read(
    test_sheet("googlesheets4-col-types"),
    sheet = "lots-of-types",
    col_types = "?-_-_-?"
  )
  expect_equal(ncol(dat), 2)
  expect_type(dat$logical, "logical")
  expect_s3_class(dat$datetime, "POSIXct")
})

# https://github.com/tidyverse/googlesheets4/issues/73
# https://github.com/tidyverse/googlesheets4/issues/174
test_that("read_sheet() honors `na`", {
  skip_if_offline()
  skip_if_no_token()

  # default behaviour
  dat <- read_sheet(
    test_sheet("googlesheets4-col-types"),
    sheet = "NAs"
  )
  expect_true(all(map_lgl(dat, is.character)))
  expect_false(is.na(dat$...NA[2]))
  expect_true(is.na(dat$space[2]))
  expect_true(is.na(dat$empty_string[2]))
  expect_true(is.na(dat$truly_empty[2]))

  # can explicit whitespace survive?
  dat <- read_sheet(
    test_sheet("googlesheets4-col-types"),
    sheet = "NAs",
    trim_ws = FALSE
  )
  expect_equal(dat$space[2], " ")

  # can we request empty string instead of NA?
  dat <- read_sheet(
    test_sheet("googlesheets4-col-types"),
    sheet = "NAs",
    na = character()
  )
  expect_equal(dat$space[2], "")
  expect_equal(dat$empty_string[2], "")
  expect_equal(dat$truly_empty[2], "")

  # explicit whitespace and empty-string-for-NA
  dat <- read_sheet(
    test_sheet("googlesheets4-col-types"),
    sheet = "NAs",
    na = character(),
    trim_ws = FALSE
  )
  expect_equal(dat$space[2], " ")

  # more NA strings
  dat <- read_sheet(
    test_sheet("googlesheets4-col-types"),
    sheet = "NAs",
    na = c("", "NA", "Missing")
  )
  expect_true(is.na(dat$...Missing[2]))
  expect_true(is.na(dat$...NA[2]))
  expect_true(is.na(dat$space[2]))
  expect_true(is.na(dat$empty_string[2]))
  expect_true(is.na(dat$truly_empty[2]))

  # column name that is NA string
  dat <- read_sheet(
    test_sheet("googlesheets4-col-types"),
    sheet = "NAs",
    na = "complete",
    .name_repair = ~ vec_as_names(.x, repair = "unique", quiet = TRUE)
  )
  expect_match(rev(names(dat))[1], "^...")

  # how NA strings interact with column typing
  dat <- read_sheet(
    test_sheet("googlesheets4-col-types"),
    sheet = "NAs",
    na = c("one", "three")
  )
  expect_true(is.character(dat$...Missing))
  expect_true(is.character(dat$...NA))
  expect_true(is.character(dat$space))
  expect_true(is.character(dat$complete))
  expect_true(is.logical(dat$empty_string))
  expect_true(is.logical(dat$truly_empty))
})

# helpers to check arguments ----
test_that("col_names must be logical or character and have length", {
  wrapper_fun <- function(...) check_col_names(...)
  expect_snapshot(wrapper_fun(1:3), error = TRUE)
  expect_snapshot(wrapper_fun(factor("a")), error = TRUE)
  expect_snapshot(wrapper_fun(character()), error = TRUE)
})

test_that("logical col_names must be TRUE or FALSE", {
  wrapper_fun <- function(...) check_col_names(...)
  expect_snapshot(wrapper_fun(NA), error = TRUE)
  expect_snapshot(wrapper_fun(c(TRUE, FALSE)), error = TRUE)
  expect_identical(check_col_names(TRUE), TRUE)
  expect_identical(check_col_names(FALSE), FALSE)
})

test_that("standardise_ctypes() turns NULL col_types into 'COL_GUESS'", {
  expect_equal(standardise_ctypes(NULL), c("?" = "COL_GUESS"))
})

test_that("standardise_ctypes() errors for only 'COL_SKIP'", {
  errmsg <- "can't request that all columns be skipped"
  expect_error(standardise_ctypes("-"), errmsg)
  expect_error(standardise_ctypes("-_"), errmsg)
})

test_that("standardise_ctypes() understands and requires readr shortcodes", {
  good <- "_-lidnDtTcCL?"
  expect_equal(
    standardise_ctypes(good),
    c(
      `_` = "COL_SKIP",
      `-` = "COL_SKIP",
      l = "CELL_LOGICAL",
      i = "CELL_INTEGER",
      d = "CELL_NUMERIC",
      n = "CELL_NUMERIC",
      D = "CELL_DATE",
      t = "CELL_TIME",
      T = "CELL_DATETIME",
      c = "CELL_TEXT",
      C = "COL_CELL",
      L = "COL_LIST",
      `?` = "COL_GUESS"
    )
  )
  expect_error(standardise_ctypes("abe"), "Unrecognized")
  expect_error(standardise_ctypes("f:"), "Unrecognized")
  expect_error(standardise_ctypes(""), "at least one")
})

test_that("col_types of right length are tolerated", {
  expect_identical(rep_ctypes(1, ctypes = "a"), "a")
  expect_identical(rep_ctypes(2, ctypes = c("a", "b")), c("a", "b"))
  expect_identical(
    rep_ctypes(2, ctypes = c("a", "b", "COL_SKIP")),
    c("a", "b", "COL_SKIP")
  )
})

test_that("a single col_types is repeated to requested length", {
  expect_identical(rep_ctypes(2, ctypes = "a"), c("a", "a"))
})

test_that("col_types with length > 1 and != n throw error", {
  expect_error(rep_ctypes(1, ctypes = rep("a", 2)), "not compatible")
  expect_error(rep_ctypes(3, ctypes = rep("a", 2)), "not compatible")
})

test_that("filter_col_names() removes entries for skipped columns", {
  expect_identical(filter_col_names(letters[1:2], letters[3:4]), letters[1:2])
  expect_identical(
    filter_col_names(letters[1:3], ctypes = c("a", "COL_SKIP", "c")),
    letters[c(1, 3)]
  )
})
