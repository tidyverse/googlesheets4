test_that("empty_cell() ignores dots", {
  expect_identical(empty_cell(1, 2, blah = "BLAH"), empty_cell())
})

test_that("empty_cell() passes non-NULL `.na` value through", {
  expect_identical(empty_cell(.na = "a"), "a")
})

test_that("cell_data() works", {
  expect_identical(
    cell_data(TRUE, val_type = "boolValue"),
    list(list(userEnteredValue = list(boolValue = TRUE)))
  )
})

test_that("cell_data() passes `.na` along", {
  expect_identical(
    cell_data(NA, val_type = "boolValue", "NA value"),
    list("NA value")
  )
})

test_that("add_format() works", {
  fmt <- list(b = "b")
  out <- add_format(list(a = "a"), fmt)
  expect_identical(out$a, "a")
  expect_identical(out$userEnteredFormat, list(numberFormat = fmt))
})
