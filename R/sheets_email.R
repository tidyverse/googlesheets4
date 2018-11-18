#' Get email of current user
#'
#' Reveals email associated with the Google credential currently being used by
#' googlesheets4 (if there is one). This is semi experimental, inspired by
#' [googledrive::drive_user()]. The fate of this function to be determined by
#' how scopes shake out and whether we create a way for googledrive and
#' googlesheets4 to share a token.
#'
#' @return An email address or `NULL`.
#' @export
#' @examples
#' sheets_email()
sheets_email <- function() {
  if (!auth_active()) {
    message("googlesheets4: auth is inactive.")
    return(invisible())
  }

  if (is.null(access_cred())) {
    message("Not logged in as any specific Google user.")
    return(invisible())
  }
  access_cred()$email
}
