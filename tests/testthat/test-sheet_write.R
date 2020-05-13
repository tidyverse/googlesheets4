# ---- nm_fun ----
me_ <- nm_fun("TEST-sheet_write")

# ---- tests ----
test_that("sheet_write() writes what it should", {
  skip_if_offline()
  skip_if_no_token()

  dat <- range_read(
    test_sheet("googlesheets4-col-types"),
    sheet = "lots-of-types",
    col_types = "lccinDT" # TODO: revisit when 'f' means factor
  )
  dat$factor <- factor(dat$factor)

  ss <- local_ss(me_("datetimes"))
  sheet_write(dat, ss)
  x <- range_read(ss, sheet = "dat", col_types = "C")

  # the main interesting bit to test is whether we successfully sent
  # correct value for the date and datetime, with a sane (= ISO 8601) format
  expect_equal(
    purrr::pluck(x, "date", 1, "formattedValue"), format(dat$date[1])
  )
  expect_equal(
    purrr::pluck(x, "date", 1, "effectiveFormat", "numberFormat", "type"),
    "DATE"
  )
  expect_equal(
    purrr::pluck(x, "date", 1, "effectiveFormat", "numberFormat", "pattern"),
    "yyyy-mm-dd"
  )

  expect_equal(
    purrr::pluck(x, "datetime", 1, "formattedValue"), format(dat$datetime[1])
  )
  expect_equal(
    purrr::pluck(x, "datetime", 1, "effectiveFormat", "numberFormat", "type"),
    "DATE_TIME"
  )
  expect_equal(
    purrr::pluck(x, "datetime", 1, "effectiveFormat", "numberFormat", "pattern"),
    "yyyy-mm-dd hh:mm:ss"
  )
})

test_that("sheet_write() can figure out (work)sheet name", {
  skip_if_offline()
  skip_if_no_token()

  foofy <- data.frame(x = 1:3, y = letters[1:3])

  ss <- local_ss(me_("sheetnames"))

  # get (work)sheet name from data frame's name
  sheet_write(foofy, ss)
  expect_equal(tail(sheet_names(ss), 1), "foofy")

  # we don't clobber existing (work)sheet if name was inferred
  sheet_write(foofy, ss)
  expect_equal(tail(sheet_names(ss), 1), "Sheet2")

  # we do write into existing (work)sheet if name is explicitly given
  sheet_write(foofy, ss, sheet = "foofy")
  expect_setequal(sheet_names(ss), c("Sheet1", "Sheet2", "foofy"))

  # we do write into existing (work)sheet if position is explicitly given
  sheet_write(foofy, ss, sheet = 2)
  expect_setequal(sheet_names(ss), c("Sheet1", "Sheet2", "foofy"))
})
