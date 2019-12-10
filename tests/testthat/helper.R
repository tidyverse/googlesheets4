if (gargle:::secret_can_decrypt("googlesheets4") &&
    !is.null(curl::nslookup("sheets.googleapis.com", error = FALSE))) {
  capture.output(
    sheets_auth_testing(drive = TRUE)
  )
} else {
  sheets_deauth()
}

skip_if_no_token <- function() {
  testthat::skip_if_not(sheets_has_token())
}

expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

ref <- function(pattern, ...) {
  x <- list.files(testthat::test_path("ref"), pattern = pattern, ...)
  if (length(x) < 1) {
    return(testthat::test_path("ref", pattern))
  } else if (length(x) == 1) {
    return(testthat::test_path("ref", x))
  }
  stop_glue(
    "`pattern` identifies more than one test reference file:\n",
    paste0("* ", x, collapse = "\n")
  )
}
