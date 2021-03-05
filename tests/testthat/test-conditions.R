test_that("gs4_abort() throws classed condition", {
  expect_error(gs4_abort("oops"), class = "gs4_error")
  expect_gs4_error(gs4_abort("oops"))
  expect_error(gs4_abort("oops", class = "gs4_foo"), class = "gs4_error")
  expect_error(gs4_abort("oops", class = "gs4_foo"), class = "gs4_foo")
})

test_that("gs4_abort() glues data in", {
  x <- "this"
  expect_gs4_error(gs4_abort("`x` is {sq(x)}"), "`x` is 'this'", fixed = TRUE)
})
