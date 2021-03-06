test_that("gs4_abort() throws classed condition", {
  expect_error(gs4_abort("oops"), class = "gs4_error")
  expect_gs4_error(gs4_abort("oops"))
  expect_gs4_error(gs4_abort("oops", class = "gs4_foo"))
  expect_error(gs4_abort("oops", class = "gs4_foo"), class = "gs4_foo")
})

test_that("gs4_abort() glues data in", {
  x <- "this"
  expect_gs4_error(gs4_abort("`x` is {sq(x)}"), "`x` is 'this'", fixed = TRUE)

  # message has length > 1, named bullets
  expect_snapshot_error(
    gs4_abort(c("`x` is {sq(x)}", i = "{sq(x)} is in `x`", x = "oops"))
  )
})

test_that("abort_unsupported_conversion() works", {
  x <- structure(1, class = c("a", "b", "c"))
  expect_snapshot_error(
    abort_unsupported_conversion(x, "d")
  )
})
