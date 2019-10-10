test_that("read_sheet() does same old, same old", {
  skip_on_cran()
  skip_if_offline()

  expect_known_output(
    read_sheet(test_sheet("googlesheets4-cell-tests")),
    ref("googlesheets4-cell-tests.rds")
  )
})
