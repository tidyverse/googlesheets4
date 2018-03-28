context("test-sheets_endpoints.R")

test_that("endpoints can be retrieved en masse", {
  endpoints <- sheets_endpoints()
  expect_true(length(endpoints) >= 14)
  expect_match(names(endpoints), "^spreadsheets\\.")
})

test_that("a single endpoint can be retrieved", {
  nm <- "spreadsheets.values.batchClear"
  endpoint <- sheets_endpoints(nm)[[1]]
  expect_true(length(endpoint) == 6)
  expect_true(
    all(c("id", "method", "path", "parameters") %in% names(endpoint))
  )
})
