context("test-utils.R")

test_that("vlookup() works", {
  df <- tibble::tibble(
    i = 1:3,
    letters = letters[i],
    dupes = c("a", "c", "c"),
    fctr = factor(letters)
  )

  ## internal function, does not support unquoted variable names
  expect_error(vlookup("c", df, letters, i), "not found")

  expect_identical(vlookup("c", df, "letters", "i"), 3L)
  expect_identical(vlookup(c("a", "c"), df, "letters", "i"), c(1L, 3L))

  ## match() returns position of *first* match
  expect_identical(vlookup("c", df, "dupes", "i"), 2L)
  expect_identical(vlookup(c("c", "c"), df, "dupes", "i"), c(2L, 2L))

  expect_identical(vlookup("b", df, "fctr", "i"), 2L)
  expect_identical(vlookup(c("b", "c", "a"), df, "fctr", "i"), c(2L, 3L, 1L))
})
