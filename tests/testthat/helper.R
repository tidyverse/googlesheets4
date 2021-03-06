if (gargle:::secret_can_decrypt("googlesheets4") &&
    !is.null(curl::nslookup("sheets.googleapis.com", error = FALSE))) {
  capture.output(
    gs4_auth_testing(drive = TRUE)
  )
} else {
  gs4_deauth()
}

skip_if_no_token <- function() {
  if (gs4_has_token()) {
    # hack to slow things down in CI
    Sys.sleep(3)
  } else {
    skip("No token")
  }
}

expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

expect_gs4_error <- function(...) {
  expect_error(..., class = "googlesheets4_error")
}

ref <- function(pattern, ...) {
  x <- list.files(testthat::test_path("ref"), pattern = pattern, ...)
  if (length(x) < 1) {
    return(testthat::test_path("ref", pattern))
  } else if (length(x) == 1) {
    return(testthat::test_path("ref", x))
  }
  gs4_abort(c(
    "{bt('pattern')} identifies more than one test reference file:",
    set_names(sq(x), rep_along(x, "x"))
  ))
}

nm_fun <- function(context, user = NULL) {
  if (as.logical(Sys.getenv("GITHUB_ACTIONS", unset = "false"))) {
    user <-
      glue("gha-{Sys.getenv('GITHUB_WORKFLOW')}-{Sys.getenv('GITHUB_RUN_ID')}")
  } else {
    user <- Sys.info()["user"]
  }
  y <- purrr::compact(list(context, user))
  function(x = NULL) as.character(glue::glue_collapse(c(x, y), sep = "-"))
}

local_ss <- function(name, ..., env = parent.frame()) {
  existing <- gs4_find(name)
  if (nrow(existing) > 0) {
    gs4_abort("A spreadsheet named {sq(name)} already exists")
  }

  withr::defer({
    trash_me <- gs4_find(name)
    if (nrow(trash_me) < 1) {
      warn("The spreadsheet named {dq(name)} already seems to be deleted")
    } else {
      quiet <- gs4_quiet() %|% is_testing()
      googledrive::drive_trash(trash_me, verbose = !quiet)
    }
  }, envir = env)
  gs4_create(name, ...)
}
