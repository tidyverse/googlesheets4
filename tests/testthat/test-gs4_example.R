test_that("gs4_examples() lists all examples", {
  examples <- gs4_examples()
  expect_true(is.character(examples))
  expect_true(length(examples) > 0)
  expect_true(is.character(names(examples)))
  expect_s3_class(examples, "drive_id")
})

test_that("gs4_examples() requires a match if `matches` is supplied", {
  expect_error(gs4_examples("nope"), "Can't find")
})

test_that("gs4_example() requires `matches`", {
  expect_error(gs4_example(), "missing")
})

test_that("`matches` works in gs4_examples()", {
  examples <- gs4_examples("gap")
  expect_true(length(examples) > 0)
  expect_s3_class(examples, "drive_id")
})

test_that("`matches` works in gs4_example()", {
  expect_error_free(
    example <- gs4_example("gapminder")
  )
  expect_length(example, 1)
  expect_s3_class(example, "drive_id")
  expect_s3_class(example, "sheets_id")
})

test_that("gs4_example() requires a unique match", {
  expect_error(gs4_example("gap"), "multiple")
})
