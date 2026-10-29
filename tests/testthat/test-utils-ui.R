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

test_that("range styling: no redundant quotes, double quotes without color", {
  local_gs4_loud()
  qualified <- qualified_A1("Sheet1", "A1:B3")
  bare <- "F"
  expect_snapshot({
    gs4_bullets(c(v = "Range {.range {qualified}}."))
    gs4_bullets(c(v = "Range {.range {bare}}."))
  })
  withr::local_options(cli.num_colors = 256)
  expect_snapshot({
    gs4_bullets(c(v = "Range {.range {qualified}}."))
    gs4_bullets(c(v = "Range {.range {bare}}."))
  })
})

test_that("abort_unsupported_conversion() works", {
  x <- structure(1, class = c("a", "b", "c"))
  expect_snapshot_error(
    abort_unsupported_conversion(x, "target_class")
  )
})
