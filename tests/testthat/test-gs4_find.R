test_that("gs4_find() works", {
  skip_if_offline()
  skip_if_no_token()

  df <- gs4_find(n_max = 5)
  expect_s3_class(df, "dribble")
})
