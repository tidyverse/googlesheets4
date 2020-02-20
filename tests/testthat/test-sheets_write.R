# ---- nm_fun ----
me_ <- nm_fun("TEST-sheets_write")

# ---- tests ----
test_that("sheets_write() writes what it should", {
  skip_if_offline()
  skip_if_no_token()

  dat <- sheets_read(
    test_sheet("googlesheets4-col-types"),
    sheet = "lots-of-types",
    col_types = "lccinDT" # TODO: revisit when 'f' means factor
  )
  dat$factor <- factor(dat$factor)

  ss <- scoped_temporary_ss(me_())
  sheets_write(dat, ss)
  x <- sheets_read(ss, sheet = "dat", col_types = "C")

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
