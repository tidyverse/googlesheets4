test_that("sheets_list() works", {
  skip_if_no_token()
  skip_if_offline()

  df <- sheets_list(n_max = 5)
  expect_is(df, "dribble")
})
