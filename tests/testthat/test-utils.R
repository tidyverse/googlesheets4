test_that("check_length_one() works", {
  expect_error_free(check_length_one(1))
  expect_error(check_length_one(1:2), "must have length 1")
  expect_error(check_length_one(letters), "letters")
})

test_that("check_character() works", {
  expect_error_free(check_character(letters))
  expect_error(check_character(1:2), "integer")
})


test_that("vlookup() works", {
  df <- tibble::tibble(
    i = 1:3,
    letters = letters[i],
    dupes = c("a", "c", "c"),
    fctr = factor(letters)
  )

  ## internal function, therefore it does not support unquoted variable names
  ## R <= 3.4.4 error msg is "object 'i' not found"
  ## R devel error msg is "is_string(key) is not TRUE"
  expect_error(vlookup("c", df, letters, i))

  expect_identical(vlookup("c", df, "letters", "i"), 3L)
  expect_identical(vlookup(c("a", "c"), df, "letters", "i"), c(1L, 3L))

  ## match() returns position of *first* match
  expect_identical(vlookup("c", df, "dupes", "i"), 2L)
  expect_identical(vlookup(c("c", "c"), df, "dupes", "i"), c(2L, 2L))

  expect_identical(vlookup("b", df, "fctr", "i"), 2L)
  expect_identical(vlookup(c("b", "c", "a"), df, "fctr", "i"), c(2L, 3L, 1L))
})

test_that("enforce_na() works", {
  expect_error(enforce_na(1), "is.character(x) is not TRUE", fixed = TRUE)
  expect_error(enforce_na("a", 1), "is.character(na) is not TRUE", fixed = TRUE)

  expect_identical(enforce_na(character()), character())

  expect_identical(
    enforce_na(c("a", "", "c")),
               c("a", NA, "c")
  )
  expect_identical(
    enforce_na(c("a", "", "c"), na = "c"),
               c("a", "", NA)
  )
  expect_identical(
    enforce_na(c("abc", "", "cab"), na = c("abc", "")),
               c(   NA, NA, "cab")
  )
  expect_identical(
    enforce_na(c("a", "", "c"), na = character()),
               c("a", "", "c")
  )
})
