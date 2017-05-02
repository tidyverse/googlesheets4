context("Credentials")

test_that("API key is produced on demand", {
  ## fallback to built-in key
  expect_identical(api_key(), getOption("googlesheets.api.key"))
  ## env var overrides fallback
  withr::with_envvar(
    new = c("GOOGLESHEETS_API_KEY" = "abc"),
    expect_identical(api_key(), "abc")
  )
})
