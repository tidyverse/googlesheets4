if (gargle:::secret_can_decrypt("googlesheets4") &&
    !is.null(curl::nslookup("sheets.googleapis.com", error = FALSE))) {
  capture.output(
    sheets_auth_testing(drive = TRUE)
  )
} else {
  sheets_deauth()
}

skip_if_no_token <- function() {
  Sys.sleep(2)
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

nm_fun <- function(context, user = Sys.info()["user"]) {
  y <- purrr::compact(list(context, user))
  function(x = NULL) as.character(glue::glue_collapse(c(x, y), sep = "-"))
}

scoped_temporary_ss <- function(name, ..., env = parent.frame()) {
  existing <- sheets_find(name)
  if (nrow(existing) > 0) {
    stop_glue("A spreadsheet named {sq(name)} already exists.")
  }

  if (identical(env, globalenv())) {
    message_glue(
      "Creating a scratch Sheet called {sq(name)}.
       Remove with {bt('googledrive::drive_trash(ss)')}"
    )
  } else {
    withr::defer({
      trash_me <- sheets_find(name)
      if (nrow(trash_me) < 1) {
        warning_glue("The spreadsheet named {sq(name)} already seems to be deleted.")
      } else {
        googledrive::drive_trash(trash_me)
      }
    }, envir = env)
  }
  sheets_create(name, ...)
}
