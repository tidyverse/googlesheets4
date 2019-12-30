test_that("sheets_examples() lists all examples", {
  examples <- sheets_examples()
  expect_true(is.character(examples))
  expect_true(length(examples) > 0)
  expect_true(is.character(names(examples)))
  expect_s3_class(examples, "drive_id")
})

test_that("sheets_examples() requires a match if `matches` is supplied", {
  expect_error(sheets_examples("nope"), "Can't find")
})

test_that("sheets_example() requires `matches`", {
  expect_error(sheets_example(), "missing")
})

test_that("`matches` works in sheets_examples()", {
  examples <- sheets_examples("gap")
  expect_true(length(examples) > 0)
  expect_s3_class(examples, "drive_id")
})

test_that("`matches` works in sheets_example()", {
  expect_error_free(
    example <- sheets_example("gapminder")
  )
  expect_length(example, 1)
  expect_s3_class(example, "drive_id")
  expect_s3_class(example, "sheets_id")
})

test_that("sheets_example() requires a unique match", {
  expect_error(sheets_example("gap"), "multiple")
})
