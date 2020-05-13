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

local_ss <- function(name, ..., env = parent.frame()) {
  existing <- gs4_find(name)
  if (nrow(existing) > 0) {
    stop_glue("A spreadsheet named {sq(name)} already exists.")
  }

  withr::defer({
    trash_me <- gs4_find(name)
    if (nrow(trash_me) < 1) {
      warning_glue("The spreadsheet named {sq(name)} already seems to be deleted.")
    } else {
      googledrive::drive_trash(trash_me)
    }
  }, envir = env)
  gs4_create(name, ...)
}

toggle_rlang_interactive <- function() {
  before <- getOption("rlang_interactive")
  after <- if (identical(before, FALSE)) TRUE else FALSE
  options(rlang_interactive = after)
  ui_line(glue::glue("rlang_interactive: {before %||% '<unset>'} --> {after}"))
  invisible()
}
