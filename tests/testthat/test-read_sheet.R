test_that("read_sheet() does same old, same old", {
  skip("broken until I restore the test Sheet :(")
  skip_if_offline()
  skip_if_no_token()

  expect_known_value(
    # https://github.com/tidyverse/dplyr/issues/2751
    as.data.frame(read_sheet(test_sheet("googlesheets4-cell-tests"))),
    ref("googlesheets4-cell-tests.rds")
  )
})

# https://github.com/tidyverse/googlesheets4/issues/73
test_that("read_sheet() honors `na`", {
  skip_if_offline()
  skip_if_no_token()

  df <- read_sheet(
    test_sheet("googlesheets4-col-types"),
    na = c("", "NA", "Missing")
  )
  expect_true(all(vapply(df, is.double, logical(1))))
  expect_true(is.na(df$A[2]))
  expect_true(is.na(df$B[2]))
  expect_true(is.na(df$C[2]))
})
