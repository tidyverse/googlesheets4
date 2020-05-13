# ---- nm_fun ----
me_ <- nm_fun("TEST-range_autofit")

# ---- tests ----
test_that("range_autofit() works", {
  skip_if_offline()
  skip_if_no_token()

  dat <- tibble::tribble(
        ~x,     ~y,     ~z,     ~a,     ~b,     ~c,
    "abcd", "efgh", "ijkl", "mnop", "qrst", "uvwx"
  )
  ss <- local_ss(me_(), sheets = list(dat = dat))
  ssid <- as_sheets_id(ss)

  range_autofit(ss)
  before <- gs4_get_impl_(
    ssid, fields = "sheets.data.columnMetadata.pixelSize"
  )

  dat2 <- purrr::modify(dat, ~ paste0(.x, "_", .x))
  dat4 <- purrr::modify(dat2, ~ paste0(.x, "_", .x))
  sheet_append(ss, dat4)
  range_autofit(ss)

  after <- gs4_get_impl_(
    ssid, fields = "sheets.data.columnMetadata.pixelSize"
  )

  before <- pluck(before, "sheets", 1, "data", 1, "columnMetadata")
  after <- pluck(after, "sheets", 1, "data", 1, "columnMetadata")
  expect_true(all(unlist(before) < unlist(after)))
})

# ---- helpers ----
test_that("A1-style ranges can be turned into a request", {
  req <- prepare_auto_resize_request(123, as_range_spec("D:H"))
  req <- pluck(req, 1, "autoResizeDimensions", "dimensions")
  expect_equal(req$dimension, "COLUMNS")
  expect_equal(req$startIndex, cellranger::letter_to_num("D") - 1)
  expect_equal(req$endIndex, cellranger::letter_to_num("H"))

  req <- prepare_auto_resize_request(123, as_range_spec("3:7"))
  req <- pluck(req, 1, "autoResizeDimensions", "dimensions")
  expect_equal(req$dimension, "ROWS")
  expect_equal(req$startIndex, 3 - 1)
  expect_equal(req$endIndex, 7)
})

test_that("cell_limits can be turned into a request", {
  req <- prepare_auto_resize_request(
    123,
    as_range_spec(cell_limits())
  )
  req <- pluck(req, 1, "autoResizeDimensions", "dimensions")
  expect_equal(req$dimension, "COLUMNS")
  expect_null(req$startIndex)
  expect_null(req$endIndex)

  req <- prepare_auto_resize_request(
    123,
    as_range_spec(cell_cols(c(3, NA)))
  )
  req <- pluck(req, 1, "autoResizeDimensions", "dimensions")
  expect_equal(req$dimension, "COLUMNS")
  expect_equal(req$startIndex, 3 - 1)
  expect_null(req$endIndex)

  req <- prepare_auto_resize_request(
    123,
    as_range_spec(cell_cols(c(NA, 5)))
  )
  req <- pluck(req, 1, "autoResizeDimensions", "dimensions")
  expect_equal(req$dimension, "COLUMNS")
  expect_equal(req$endIndex, 5)
})

test_that("an invalid range is rejected", {
  expect_error(
    prepare_auto_resize_request(123, as_range_spec("D3:H")),
    "only columns or only rows"
  )
})
