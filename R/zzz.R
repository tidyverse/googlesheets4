.onLoad <- function(libname, pkgname) {

  # .auth is created in R/gs4_auth.R
  # this is to insure we get an instance of gargle's AuthState using the
  # current, locally installed version of gargle
  utils::assignInMyNamespace(
    ".auth",
    gargle::init_AuthState(package = "googlesheets4", auth_active = TRUE)
  )

  if (identical(Sys.getenv("IN_PKGDOWN"), "true")) {
    tryCatch(
      gs4_auth_docs(),
      googlesheets4_auth_internal_error = function(e) NULL
    )
  }

  invisible()
}
