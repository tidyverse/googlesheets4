expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}
