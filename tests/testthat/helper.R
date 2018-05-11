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

## use from testthat once > 2.0.0 is on CRAN
skip_if_offline <- function(host = "r-project.org") {
  skip_if_not_installed("curl")
  has_internet <- !is.null(curl::nslookup(host, error = FALSE))
  if (!has_internet) {
    skip("offline")
  }
}
