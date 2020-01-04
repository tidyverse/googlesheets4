.onLoad <- function(libname, pkgname) {

  if (identical(Sys.getenv("IN_PKGDOWN"), "true") &&
      gargle:::secret_can_decrypt("googlesheets4") &&
      !is.null(curl::nslookup("sheets.googleapis.com", error = FALSE))) {
    capture.output(sheets_auth_docs(drive = TRUE))
  }

  invisible()
}
