test_that("gs4_quiet() falls back to NA if googlesheets4_quiet is unset", {
  withr::with_options(
    list(googlesheets4_quiet = NULL),
    expect_true(is.na(gs4_quiet()))
  )
})
