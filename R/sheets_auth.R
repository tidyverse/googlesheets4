## This file is the interface between googlesheets4 and the
## auth functionality in gargle.

.auth <- gargle::AuthState$new(
  package     = "googlesheets4",
  auth_active = TRUE
)

## The roxygen comments for these functions are mostly generated from data
## in this list and template text maintained in gargle.
gargle_lookup_table <- list(
  PACKAGE     = "googlesheets4",
  YOUR_STUFF  = "your Google Sheets",
  PRODUCT     = "Google Sheets",
  API         = "Sheets API",
  PREFIX      = "sheets"
)

#' Authorize googlesheets4
#'
#' @eval gargle:::PREFIX_auth_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_details(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_params()
#'
#' @family auth functions
#' @export
#'
#' @examples
#' if (interactive()) {
#'   # load/refresh existing credentials, if available
#'   # otherwise, go to browser for authentication and authorization
#'   sheets_auth()
#'
#'   # force use of a token associated with a specific email
#'   sheets_auth(email = "jenny@example.com")
#'
#'   # use a 'read only' scope, so it's impossible to edit or delete Sheets
#'   sheets_auth(
#'     scopes = "https://www.googleapis.com/auth/spreadsheets.readonly"
#'   )
#'
#'   # use a service account token
#'   sheets_auth(path = "foofy-83ee9e7c9c48.json")
#' }
sheets_auth <- function(email = gargle::gargle_oauth_email(),
                        path = NULL,
                        scopes = "https://www.googleapis.com/auth/spreadsheets",
                        cache = gargle::gargle_oauth_cache(),
                        use_oob = gargle::gargle_oob_default(),
                        token = NULL) {
  # I have called `sheets_auth(token = drive_token())` multiple times now,
  # without attaching googledrive. Expose this error noisily, before it gets
  # muffled by the `tryCatch()` treatment of `token_fetch()`.
  force(token)

  cred <- gargle::token_fetch(
    scopes = scopes,
    app = sheets_oauth_app() %||% gargle::tidyverse_app(),
    email = email,
    path = path,
    package = "googlesheets4",
    cache = cache,
    use_oob = use_oob,
    token = token
  )
  if (!inherits(cred, "Token2.0")) {
    stop(
      "Can't get Google credentials.\n",
      "Are you running googlesheets4 in a non-interactive session? Consider:\n",
      "  * `sheets_deauth()` to prevent the attempt to get credentials.\n",
      "  * Call `sheets_auth()` directly with all necessary specifics.\n",
      "See gargle's \"Non-interactive auth\" vignette for more details:\n",
      "https://gargle.r-lib.org/articles/non-interactive-auth.html",
      call. = FALSE
    )
  }
  .auth$set_cred(cred)
  .auth$set_auth_active(TRUE)

  invisible()
}

#' Suspend authorization
#'
#' @eval gargle:::PREFIX_deauth_description_with_api_key(gargle_lookup_table)
#'
#' @family auth functions
#' @export
#' @examples
#' if (interactive()) {
#'   sheets_deauth()
#'   sheets_user()
#'
#'   # get metadata on the public 'deaths' spreadsheet
#'   sheets_get(sheets_example("deaths"))
#' }
sheets_deauth <- function() {
  .auth$set_auth_active(FALSE)
  .auth$clear_cred()
  invisible()
}

#' Produce configured token
#'
#' @eval gargle:::PREFIX_token_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_token_return()
#'
#' @family low-level API functions
#' @export
#' @examples
#' if (sheets_has_token()) {
#'   req <- request_generate(
#'     "sheets.spreadsheets.get",
#'     list(spreadsheetId = "abc"),
#'     token = sheets_token()
#'   )
#'   req
#' }
sheets_token <- function() {
  if (isFALSE(.auth$auth_active)) {
    return(NULL)
  }
  if (!sheets_has_token()) {
    sheets_auth()
  }
  httr::config(token = .auth$cred)
}

#' Is there a token on hand?
#'
#' @eval gargle:::PREFIX_has_token_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_has_token_return()
#'
#' @family low-level API functions
#' @export
#'
#' @examples
#' sheets_has_token()
sheets_has_token <- function() {
  inherits(.auth$cred, "Token2.0")
}

#' Edit and view auth configuration
#'
#' @eval gargle:::PREFIX_auth_configure_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_configure_params()
#' @eval gargle:::PREFIX_auth_configure_return(gargle_lookup_table)
#'
#' @family auth functions
#' @export
#' @examples
#' # see and store the current user-configured OAuth app (probaby `NULL`)
#' (original_app <- sheets_oauth_app())
#'
#' # see and store the current user-configured API key (probaby `NULL`)
#' (original_api_key <- sheets_api_key())
#'
#' if (require(httr)) {
#'   # bring your own app via client id (aka key) and secret
#'   google_app <- httr::oauth_app(
#'     "my-awesome-google-api-wrapping-package",
#'     key = "YOUR_CLIENT_ID_GOES_HERE",
#'     secret = "YOUR_SECRET_GOES_HERE"
#'   )
#'   google_key <- "YOUR_API_KEY"
#'   sheets_auth_configure(app = google_app, api_key = google_key)
#'
#'   # confirm the changes
#'   sheets_oauth_app()
#'   sheets_api_key()
#'
#'   # bring your own app via JSON downloaded from Google Developers Console
#'   # this file has the same structure as the JSON from Google
#'   app_path <- system.file(
#'     "extdata", "fake-oauth-client-id-and-secret.json",
#'     package = "googlesheets4"
#'   )
#'   sheets_auth_configure(path =app_path)
#'
#'   # confirm the changes
#'   sheets_oauth_app()
#' }
#'
#' # restore original auth config
#' sheets_auth_configure(app = original_app, api_key = original_api_key)
sheets_auth_configure <- function(app, path, api_key) {
  if (!missing(app) && !missing(path)) {
    stop("Must supply exactly one of `app` and `path`", call. = FALSE)
  }
  stopifnot(missing(api_key) || is.null(api_key) || is_string(api_key))

  if (!missing(path)) {
    stopifnot(is_string(path))
    app <- gargle::oauth_app_from_json(path)
  }
  stopifnot(missing(app) || is.null(app) || inherits(app, "oauth_app"))

  if (!missing(app) || !missing(path)) {
    .auth$set_app(app)
  }

  if (!missing(api_key)) {
    .auth$set_api_key(api_key)
  }

  invisible(.auth)
}

#' @export
#' @rdname sheets_auth_configure
sheets_api_key <- function() .auth$api_key

#' @export
#' @rdname sheets_auth_configure
sheets_oauth_app <- function() .auth$app

#' Get info on current user
#'
#' @eval gargle:::PREFIX_user_description()
#' @eval gargle:::PREFIX_user_seealso()
#' @eval gargle:::PREFIX_user_return()
#'
#' @export
#' @examples
#' sheets_user()
sheets_user <- function() {
  if (sheets_has_token()) {
    gargle::token_email(sheets_token())
  } else {
    message("Not logged in as any specific Google user.")
    invisible()
  }
}

# unexported helpers that are nice for internal use ----
sheets_auth_internal <- function(account = c("docs", "testing"),
                                 scopes = NULL,
                                 drive = TRUE) {
  stopifnot(gargle:::secret_can_decrypt("googlesheets4"))
  account <- match.arg(account)
  filename <- glue("googlesheets4-{account}.json")
  # TODO: revisit when I do PKG_scopes()
  # https://github.com/r-lib/gargle/issues/103
  scopes <- scopes %||% "https://www.googleapis.com/auth/drive"
  json <- gargle:::secret_read("googlesheets4", filename)
  sheets_auth(scopes = scopes, path = rawToChar(json))
  print(sheets_user())
  if (drive) {
    googledrive::drive_auth(token = sheets_token())
    print(googledrive::drive_user())
  }
  invisible(TRUE)
}

sheets_auth_docs <- function(scopes = NULL, drive = TRUE) {
  sheets_auth_internal("docs", scopes = scopes, drive = drive)
}

sheets_auth_testing <- function(scopes = NULL, drive = TRUE) {
  sheets_auth_internal("testing", scopes = scopes, drive = drive)
}
