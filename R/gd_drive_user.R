#' Retrieve Google Drive user data
#'
#' Unexported workhorse function.
#'
#' @template return-drive_user
#'
#' @keywords internal
drive_user <- function() {

  ## require pre-existing token, to avoid recursion that would arise if
  ## this function called gs_auth()
  if (!token_available(verbose = FALSE)) {
    return(NULL)
  }

  ## https://developers.google.com/drive/v3/reference/about
  url <- file.path(.state$gd_base_url, "drive/v3/about")
  req <- rGET(url, google_token(), query = list(fields = "user")) %>%
    httr::stop_for_status()
  rc <- content_as_json_UTF8(req)
  rc$date <- req$headers$date %>% httr::parse_http_date()
  structure(rc, class = c("drive_user", "list"))

}

#' Retrieve information about the current Google user
#'
#' Retrieve information about the Google user that has authorized googlesheets
#' to call the Drive and Sheets APIs on their behalf. Returns info from [the
#' "about" endpoint](https://developers.google.com/drive/v2/reference/about/get)
#' of the Drive API:
#' * User's display name
#' * User's email
#' * Datetime of the API call
#' * User's permission ID
#'
#' @template verbose
#'
#' @template return-drive_user
#' @family auth functions
#' @export
#' @examples
#' \dontrun{
#' ## these are synonyms: gd = Google Drive, gs = Google Sheets
#' gd_user()
#' gs_user()
#' }
#'
#' @export
gd_user <- function(verbose = TRUE) {

  if (!token_available(verbose = verbose) || !is_legit_token(.state$token)) {
    if (verbose) {
      message("To retrieve user info, please call gs_auth() explicitly.")
    }
    return(invisible(NULL))
  }

  drive_user()
}

#' @export
#' @rdname gd_user
gs_user <- gd_user

#' @export
print.drive_user <- function(x, ...) {
  cpf("          displayName: %s", x$user$displayName)
  cpf("         emailAddress: %s", x$user$emailAddress)
  cpf("                 date: %s", format(x$date, usetz = TRUE))
  cpf("         permissionId: %s", x$user$permissionId)
  invisible(x)
}
