test_that("gs4_examples() lists all examples, in a named drive_id object", {
  skip_if_offline()
  skip_on_cran()

  examples <- gs4_examples()
  expect_true(is.character(examples))
  expect_true(length(examples) > 0)
  expect_true(is.character(names(examples)))
  expect_s3_class(examples, "drive_id")
})

test_that("gs4_example() returns a sheets_id", {
  skip_if_offline()
  skip_on_cran()

  expect_s3_class(gs4_example("deaths"), "sheets_id")
})

test_that("gs4_examples() requires a match if `matches` is supplied", {
  skip_if_offline()
  skip_on_cran()

  expect_error(gs4_examples("nope"), "Can't find")
})

test_that("gs4_example() requires `matches`", {
  skip_if_offline()
  skip_on_cran()

  expect_error(gs4_example(), "missing")
})

test_that("`matches` works in gs4_examples()", {
  skip_if_offline()
  skip_on_cran()

  examples <- gs4_examples("gap")
  expect_true(length(examples) > 0)
  expect_s3_class(examples, "drive_id")
})

test_that("`matches` works in gs4_example()", {
  skip_if_offline()
  skip_on_cran()

  expect_error_free(
    example <- gs4_example("gapminder")
  )
  expect_length(example, 1)
  expect_s3_class(example, "drive_id")
  expect_s3_class(example, "sheets_id")
})

test_that("gs4_example() requires a unique match", {
  skip_if_offline()
  skip_on_cran()

  expect_error(gs4_example("gap"), "multiple")
})

test_that("example functions work when deauth'd", {
  skip_if_offline()
  skip_on_cran()

  examples <- gs4_examples()
  gapminder <- gs4_example("gapminder")

  local_deauth()
  env_bind(.googlesheets4, example_and_test_sheets = zap())

  expect_equal(gs4_examples(), examples)
  expect_equal(gs4_example("gapminder"), gapminder)
})
