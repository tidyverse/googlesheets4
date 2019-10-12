.onLoad <- function(libname, pkgname) {

  if (identical(Sys.getenv("IN_PKGDOWN"), "true") &&
      gargle:::secret_can_decrypt("googlesheets4") &&
      !is.null(curl::nslookup("sheets.googleapis.com", error = FALSE))) {
    sheets_auth_testing(drive = TRUE)
  }

  invisible()
}
