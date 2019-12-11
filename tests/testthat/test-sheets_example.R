test_that("sheets_examples() lists all examples", {
  examples <- sheets_examples()
  expect_true(is.character(examples))
  expect_true(length(examples) > 0)
  expect_true(is.character(names(examples)))
  expect_s3_class(examples, "drive_id")
})

test_that("a single example works", {
  gapminder <- sheets_example("gapminder")
  expect_s3_class(gapminder, "sheets_id")
})

test_that("an unrecognized or empty nickname errors", {
  expect_error(sheets_example("nope"), "be one of")
  expect_error(sheets_example(), "required")
})
