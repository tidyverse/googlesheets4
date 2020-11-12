# ---- nm_fun ----
me_ <- nm_fun("TEST-range_format_pattern")

# ---- tests ----
test_that("range_format_pattern() works", {
  skip_if_offline()
  skip_if_no_token()

  example_num <- 0.1234
  example_date <- as.Date("2020-01-01")
  dat <- tibble::tribble(
    ~small_number, ~date,
    example_num, example_date,
  )
  ss <- local_ss(me_(), sheets = list(dat = dat))
  ssid <- as_sheets_id(ss)

  sheet_t0 <- range_speedread(ss)

  range_format_pattern(ss, "0.0%", range = "A")
  sheet_t1 <- range_speedread(ss)

  range_format_pattern(ss, "dd\"-\"mmmm")
  sheet_t2 <- range_speedread(ss)

  expect_equal(sheet_t0$small_number, example_num)
  expect_equal(sheet_t0$date, example_date)

  expect_equal(sheet_t1$small_number, "12.3%")
  expect_equal(sheet_t1$date, example_date)

  expect_equal(sheet_t2$small_number, "12.3%")
  expect_equal(sheet_t2$date, "01-January")
})
