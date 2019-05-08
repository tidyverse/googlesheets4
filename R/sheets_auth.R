## This file is the interface between googlesheets4 and the
## auth functionality in gargle.

.auth <- gargle::AuthState$new(
  package     = "googlesheets4",
  app         = gargle::tidyverse_app(),
  api_key     = gargle::tidyverse_api_key(),
  auth_active = TRUE,
  cred        = NULL
)

## The roxygen comments for these functions are mostly generated from data
## in this list and template text maintained in gargle.
gargle_lookup_table <- list(
  PACKAGE     = "googlesheets4",
  YOUR_STUFF  = "your Google Sheets",
  PRODUCT     = "Google Sheets",
  API         = "Sheets API",
  PREFIX      = "sheets",
  AUTH_CONFIG_SOURCE = "tidyverse",
  SCOPES_LINK = "https://developers.google.com/identity/protocols/googlescopes#sheetsv4"
)

#' Authorize googlesheets4
#'
#' @eval gargle:::PREFIX_auth_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_details(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_params_email()
#' @eval gargle:::PREFIX_auth_params_path()
#' @eval gargle:::PREFIX_auth_params_scopes(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_params_cache_use_oob()
#'
#' @family auth functions
#' @export
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
                        cache = getOption("gargle.oauth_cache"),
                        use_oob = getOption("gargle.oob_default")) {
  cred <- gargle::token_fetch(
    scopes = scopes,
    app = .auth$app,
    email = email,
    path = path,
    package = "googlesheets4",
    cache = cache,
    use_oob = use_oob
  )
  if (!inherits(cred, "Token2.0")) {
    stop(
      "Can't get Google credentials.\n",
      "Are you running googlesheets4 in a non-interactive session? Consider:\n",
      "  * sheets_deauth() to prevent the attempt to get credentials.\n",
      "  * Call sheets_auth() directly with all necessary specifics.\n",
      call. = FALSE
    )
  }
  .auth$set_cred(cred)
  .auth$set_auth_active(TRUE)

  return(invisible())
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
#' sheets_get("1ESTf_tH08qzWwFYRC1NVWJjswtLdZn9EGw5e3Z5wMzA")
#' }
sheets_deauth <- function() {
  .auth$set_auth_active(FALSE)
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
#'
#' ## get a bare access token for use with, e.g., curl on the command line
#' sheets_token()$auth_token$credentials$access_token
#' }
sheets_token <- function() {
  if (isFALSE(.auth$auth_active)) {
    return(NULL)
  }
  if (is.null(.auth$cred)) {
    sheets_auth()
  }
  httr::config(token = .auth$cred)
}

#' View or edit auth config
#'
#' @eval gargle:::PREFIX_auth_config_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_config_params_except_key()
#' @eval gargle:::PREFIX_auth_config_params_key()
#' @eval gargle:::PREFIX_auth_config_return_with_key(gargle_lookup_table)
#'
#' @family auth functions
#' @export
#' @examples
#' ## retrieve current config
#' sheets_auth_config()
#'
#' if (require(httr)) {
#'   ## bring your own app via client id (aka key) and secret
#'   google_app <- httr::oauth_app(
#'     "my-awesome-google-api-wrapping-package",
#'     key = "123456789.apps.googleusercontent.com",
#'     secret = "abcdefghijklmnopqrstuvwxyz"
#'   )
#'   sheets_auth_config(app = google_app)
#' }
#'
#' \dontrun{
#' ## bring your own app via JSON downloaded from Google Developers Console
#' sheets_auth_config(
#'   path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
#' )
#'
#' sheets_api_key()
#' sheets_oauth_app()
#'
#' sheets_auth_config(api_key = "123")
#' sheets_api_key()
#' }
sheets_auth_config <- function(app = NULL,
                               path = NULL,
                               api_key = NULL) {
  stopifnot(is.null(app) || inherits(app, "oauth_app"))
  stopifnot(is.null(path) || is_string(path))
  stopifnot(is.null(api_key) || is_string(api_key))

  if (!is.null(app) && !is.null(path)) {
    stop_glue("Don't provide both 'app' and 'path'. Pick one.")
  }

  if (is.null(app) && !is.null(path)) {
    app <- gargle::oauth_app_from_json(path)
  }
  if (!is.null(app)) {
    .auth$set_app(app)
  }

  if (!is.null(api_key)) {
    .auth$set_api_key(api_key)
  }

  .auth
}

#' @export
#' @rdname sheets_auth_config
sheets_api_key <- function() .auth$api_key

#' @export
#' @rdname sheets_auth_config
sheets_oauth_app <- function() .auth$app
