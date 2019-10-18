test_that("read_sheet() does same old, same old", {
  skip_if_offline()
  skip_if_no_token()

  expect_known_value(
    # https://github.com/tidyverse/dplyr/issues/2751
    as.data.frame(read_sheet(test_sheet("googlesheets4-cell-tests"))),
    ref("googlesheets4-cell-tests.rds")
  )
})
