test_that("sheets_find() works", {
  skip_if_offline()
  skip_if_no_token()

  df <- sheets_find(n_max = 5)
  expect_is(df, "dribble")
})
