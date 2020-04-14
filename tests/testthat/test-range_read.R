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
test_that("read_sheet() honors `na`", {
  skip_if_offline()
  skip_if_no_token()

  df <- read_sheet(
    test_sheet("googlesheets4-col-types"),
    sheet = "NAs",
    na = c("", "NA", "Missing")
  )
  expect_true(all(vapply(df, is.double, logical(1))))
  expect_true(is.na(df$A[2]))
  expect_true(is.na(df$B[2]))
  expect_true(is.na(df$C[2]))
})
