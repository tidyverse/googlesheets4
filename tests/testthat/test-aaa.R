test_that("token registered with googlesheets4 and googledrive", {
  skip_if_offline()
  skip_if_no_token()

  expect_true(sheets_has_token())
  expect_true(googledrive::drive_has_token())
})
