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
  PREFIX      = "sheets",
  AUTH_CONFIG_SOURCE = "tidyverse"
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
#' \dontrun{
#' ## load/refresh existing credentials, if available
#' ## otherwise, go to browser for authentication and authorization
#' sheets_auth()
#'
#' ## force use of a token associated with a specific email
#' sheets_auth(email = "jenny@example.com")
#'
#' ## use a 'read only' scope, so it's impossible to edit or delete Sheets
#' sheets_auth(
#'   scopes = "https://www.googleapis.com/auth/spreadsheets.readonly"
#' )
#'
#' ## use a service account token
#' sheets_auth(path = "foofy-83ee9e7c9c48.json")
#' }
sheets_auth <- function(email = NULL,
                        path = NULL,
                        scopes = "https://www.googleapis.com/auth/spreadsheets",
                        cache = gargle::gargle_oauth_cache(),
                        use_oob = gargle::gargle_oob_default(),
                        token = NULL) {
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
      call. = FALSE
    )
  }
  .auth$set_cred(cred)
  .auth$set_auth_active(TRUE)

  invisible()
}

#' Suspend authorization
#'
#' @eval gargle:::PREFIX_deauth_description(gargle_lookup_table)
#'
#' @family auth functions
#' @export
#' @examples
#' \dontrun{
#' sheets_deauth()
#' sheets_email()
#'
#' # get metadata on the public 'deaths' spreadsheet
#' sheets_get("1ESTf_tH08qzWwFYRC1NVWJjswtLdZn9EGw5e3Z5wMzA")
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
#' \dontrun{
#' req <- request_generate(
#'   "sheets.spreadsheets.get",
#'   list(spreadsheetId = "abc"),
#'   token = sheets_token()
#' )
#' req
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
#' Reports whether googlesheets4 has stored a token, ready for use in downstream
#' requests. Exists mostly for protecting examples that won't work in the
#' absence of a token.
#'
#' @return Logical.
#' @export
#'
#' @examples
#' sheets_has_token()
sheets_has_token <- function() {
  inherits(.auth$cred, "Token2.0")
}

# TODO(jennybc): update roxygen header below when/if gargle supports
# THING_auth_configure, instead of or in addition to THING_auth_config.

#' Edit and view auth configuration
#'
#' @description
#' These functions give more control over and visibility into the auth
#' configuration than [sheets_auth()] does. `sheets_auth_configure()` lets the
#' user specify their own:
#' * OAuth app, which is used when obtaining a user token.
#' * API key. If googlesheets4 is deauthorized via [sheets_deauth()], all
#'   requests are sent with an API key in lieu of a token.
#'
#' See the vignette [How to get your own API
#' credentials](https://gargle.r-lib.org/articles/get-api-credentials.html) for
#' more. If the user does not configure these settings, internal defaults are
#' used.
#'
#' @param app OAuth app, in the sense of [httr::oauth_app()].
#' @inheritParams gargle::oauth_app_from_json
#' @param api_key API key.
#'
#' @return
#' * `sheets_auth_configure()`: An object of R6 class [gargle::AuthState],
#'   invisibly.
#' * `sheets_oauth_app()`: the current user-configured [httr::oauth_app()].
#' * `sheets_api_key()`: the current user-configured API key.
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
#'     key = "123456789.apps.googleusercontent.com",
#'     secret = "abcdefghijklmnopqrstuvwxyz"
#'   )
#'   google_key <- "the-key-I-got-for-a-google-API"
#'   sheets_auth_configure(app = google_app, api_key = google_key)
#'
#'   # confirm the changes
#'   sheets_oauth_app()
#'   sheets_api_key()
#' }
#'
#' \dontrun{
#' ## bring your own app via JSON downloaded from Google Developers Console
#' sheets_auth_configure(
#'   path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
#' )
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
    .auth$app <- app
  }

  if (!missing(api_key)) {
    .auth$api_key <- api_key
  }

  invisible(.auth)

  # switch to these once this is resolved and released
  # https://github.com/r-lib/gargle/issues/82#issuecomment-502343745
  #.auth$set_app(app)
  #.auth$set_api_key(api_key)
}

#' @export
#' @rdname sheets_auth_configure
sheets_api_key <- function() .auth$api_key

#' @export
#' @rdname sheets_auth_configure
sheets_oauth_app <- function() .auth$app
