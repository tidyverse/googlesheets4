test_that("endpoints can be retrieved en masse", {
  endpoints <- sheets_endpoints()
  expect_true(length(endpoints) >= 14)
  expect_match(names(endpoints), "^sheets\\.spreadsheets\\.")
})

test_that("a single endpoint can be retrieved", {
  nm <- "sheets.spreadsheets.values.batchClear"
  endpoint <- sheets_endpoints(nm)[[1]]
  expect_true(
    all(c("id", "path", "parameters", "scopes") %in% names(endpoint))
  )
})
