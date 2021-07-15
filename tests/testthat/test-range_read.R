test_that("read_sheet() works and discovers reasonable types", {
  skip_if_offline()
  skip_if_no_token()

  dat <- range_read(
    test_sheet("googlesheets4-col-types"),
    sheet = "lots-of-types"
  )
  expect_type(    dat$logical,   "logical")
  expect_type(    dat$character, "character")
  expect_type(    dat$factor,    "character")
  expect_type(    dat$integer,   "double")
  expect_type(    dat$double,    "double")
  expect_s3_class(dat$date,      "POSIXct")
  expect_s3_class(dat$datetime,  "POSIXct")
})

test_that("read_sheet() enacts user-specified coltypes", {
  skip_if_offline()
  skip_if_no_token()

  dat <- range_read(
    test_sheet("googlesheets4-col-types"),
    sheet = "lots-of-types",
    col_types = "lccinDT"
  )
  expect_type(    dat$logical,   "logical")
  expect_type(    dat$character, "character")
  expect_type(    dat$factor,    "character") # TODO: revisit when 'f' means factor
  expect_type(    dat$integer,   "integer")
  expect_type(    dat$double,    "double")
  expect_s3_class(dat$date,      "Date")
  expect_s3_class(dat$datetime,  "POSIXct")
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
  expect_type(    dat$logical,   "logical")
  expect_s3_class(dat$datetime,  "POSIXct")
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
    na = character(), trim_ws = FALSE
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
