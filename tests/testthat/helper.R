auth_success <- tryCatch(
  gs4_auth_testing(),
  googlesheets4_auth_internal_error = function(e) NULL
)

if (!isTRUE(auth_success)) {
  gs4_bullets(c(
    "!" = "Internal auth failed; calling {.fun gs4_deauth}."
  ))
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

local_ss <- function(name, ..., env = parent.frame()) {
  existing <- gs4_find(name)
  if (nrow(existing) > 0) {
    gs4_abort("A spreadsheet named {.s_sheet name} already exists.")
  }

  withr::defer({
    trash_me <- gs4_find(name)
    if (nrow(trash_me) < 1) {
      cli::cli_warn("
        The spreadsheet named {.s_sheet name} already seems to be deleted.")
    } else {
      quiet <- gs4_quiet() %|% is_testing()
      if (quiet) googledrive::local_drive_quiet()
      googledrive::drive_trash(trash_me)
    }
  }, envir = env)
  gs4_create(name, ...)
}
