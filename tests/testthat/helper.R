if (gargle:::secret_can_decrypt("googlesheets4")) {
  capture.output(
    sheets_auth_testing(drive = TRUE)
  )
} else {
  sheets_deauth()
}

skip_if_no_token <- function() {
  testthat::skip_if_not(sheets_has_token(), "No Sheets token")
}

expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

.test_sheets <- c(
  "googlesheets4-cell-tests" = "1vDfXo-16OhUilaG_EwvDd1Dm4_NI0UKORwSLLpycSS0"
)

test_sheet <- function(name = "googlesheets4-cell-tests") {
  stopifnot(is_string(name))
  m <- match(name, names(.test_sheets))
  if (is.na(m)) {
    stop_glue("Unrecognized test sheet: {sq('name')}")
  }
  new_sheets_id(.test_sheets[[m]])
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
