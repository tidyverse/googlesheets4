test_that("gs4_quiet() falls back to NA if googlesheets4_quiet is unset", {
  withr::with_options(
    list(googlesheets4_quiet = NULL),
    expect_true(is.na(gs4_quiet()))
  )
})

test_that("gs4_abort() throws classed condition", {
  expect_error(gs4_abort("oops"), class = "googlesheets4_error")
  expect_gs4_error(gs4_abort("oops"))
  expect_gs4_error(gs4_abort("oops", class = "googlesheets4_foo"))
  expect_error(
    gs4_abort("oops", class = "googlesheets4_foo"),
    class = "googlesheets4_foo"
  )
})

test_that("abort_unsupported_conversion() works", {
  x <- structure(1, class = c("a", "b", "c"))
  expect_snapshot_error(
    abort_unsupported_conversion(x, "target_class")
  )
})
