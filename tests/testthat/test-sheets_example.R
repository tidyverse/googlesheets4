context("test-sheets_example.R")

test_that("NULL lists all examples", {
  examples <- sheets_example()
  expect_true(is.character(examples))
  expect_true(length(examples) > 0)
  expect_true(is.character(names(examples)))
})

test_that("a single example works", {
  gapminder <- sheets_example("gapminder")
  expect_s3_class(gapminder, "sheets_id")
})

test_that("an unrecognized nickname errors", {
  expect_error(sheets_example("nope"), "'name' must be one of these")
})
