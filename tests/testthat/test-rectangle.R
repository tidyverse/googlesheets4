test_that("glean_lgl() works", {
  expect_identical(glean_lgl(list(a = TRUE), "a"),  TRUE)
  expect_identical(glean_lgl(list(b = TRUE), "a"), NA)
  expect_identical(glean_lgl(list(),         "a"), NA)
  expect_identical(glean_lgl(list(b = TRUE), "a", .default = FALSE), FALSE)
  expect_error(glean_lgl(list(a = "a"), "a"), "Can't coerce")
})

test_that("glean_chr() works", {
  expect_identical(glean_chr(list(a = "hi"),  "a"),  "hi")
  expect_identical(glean_chr(list(b = "bye"), "a"), NA_character_)
  expect_identical(glean_chr(list(),          "a"), NA_character_)
  expect_identical(glean_chr(list(b = "bye"), "a", .default = "huh"), "huh")
})

test_that("glean_int() works", {
  expect_identical(glean_int(list(a = 1L), "a"),   1L)
  expect_identical(glean_int(list(b = 1L), "a"),   NA_integer_)
  expect_identical(glean_int(list(),         "a"), NA_integer_)
  expect_identical(glean_int(list(b = 1L), "a", .default = 2L), 2L)
  expect_error(glean_int(list(a = "a"), "a"), "Can't coerce")
})
