if (gargle:::secret_can_decrypt("googlesheets4")) {
  json <- gargle:::secret_read("googlesheets4", "googlesheets4-testing.json")
  sheets_auth(path = rawToChar(json))
}

skip_if_no_token <- function() {
  testthat::skip_if_not(sheets_has_token(), "No Sheets token")
}

expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

.test_sheets <- c(
  "googlesheets4-cell-tests" = "1cm4yJpHDmypXyJgvS9jRRRBI5f5GxctwLx5I-k2goxU"
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
