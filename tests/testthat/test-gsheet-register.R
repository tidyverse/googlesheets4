context("gsheet get")

test_that("we can get a public sheet", {
  skip_if_not(hit_api())
  ## this is the id of the public Gapminder sheet
  id <- "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ"
  ss <- as_gsheet(id)
  expect_is(ss, "gsheet")
  expect_match(ss$name, "gapminder")
  expect_identical(ss$n_ws, 5L)
})

test_that("we can get a private sheet", {
  skip_if_not(use_auth())
  expect_true(FALSE)
})
