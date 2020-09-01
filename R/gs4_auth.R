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
  PREFIX      = "gs4"
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
#'   gs4_auth()
#'
#'   # force use of a token associated with a specific email
#'   gs4_auth(email = "jenny@example.com")
#'
#'   # use a 'read only' scope, so it's impossible to edit or delete Sheets
#'   gs4_auth(
#'     scopes = "https://www.googleapis.com/auth/spreadsheets.readonly"
#'   )
#'
#'   # use a service account token
#'   gs4_auth(path = "foofy-83ee9e7c9c48.json")
#' }
gs4_auth <- function(email = gargle::gargle_oauth_email(),
                     path = NULL,
                     scopes = "https://www.googleapis.com/auth/spreadsheets",
                     cache = gargle::gargle_oauth_cache(),
                     use_oob = gargle::gargle_oob_default(),
                     token = NULL) {
  # I have called `gs4_auth(token = drive_token())` multiple times now,
  # without attaching googledrive. Expose this error noisily, before it gets
  # muffled by the `tryCatch()` treatment of `token_fetch()`.
  force(token)

  cred <- gargle::token_fetch(
    scopes = scopes,
    app = gs4_oauth_app() %||% gargle::tidyverse_app(),
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
      "  * `gs4_deauth()` to prevent the attempt to get credentials.\n",
      "  * Call `gs4_auth()` directly with all necessary specifics.\n",
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
#'   gs4_deauth()
#'   gs4_user()
#'
#'   # get metadata on the public 'deaths' spreadsheet
#'   gs4_example("deaths") %>%
#'     gs4_get()
#' }
gs4_deauth <- function() {
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
#' if (gs4_has_token()) {
#'   req <- request_generate(
#'     "sheets.spreadsheets.get",
#'     list(spreadsheetId = "abc"),
#'     token = gs4_token()
#'   )
#'   req
#' }
gs4_token <- function() {
  if (isFALSE(.auth$auth_active)) {
    return(NULL)
  }
  if (!gs4_has_token()) {
    gs4_auth()
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
#' gs4_has_token()
gs4_has_token <- function() {
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
#' (original_app <- gs4_oauth_app())
#'
#' # see and store the current user-configured API key (probaby `NULL`)
#' (original_api_key <- gs4_api_key())
#'
#' if (require(httr)) {
#'   # bring your own app via client id (aka key) and secret
#'   google_app <- httr::oauth_app(
#'     "my-awesome-google-api-wrapping-package",
#'     key = "YOUR_CLIENT_ID_GOES_HERE",
#'     secret = "YOUR_SECRET_GOES_HERE"
#'   )
#'   google_key <- "YOUR_API_KEY"
#'   gs4_auth_configure(app = google_app, api_key = google_key)
#'
#'   # confirm the changes
#'   gs4_oauth_app()
#'   gs4_api_key()
#'
#'   # bring your own app via JSON downloaded from Google Developers Console
#'   # this file has the same structure as the JSON from Google
#'   app_path <- system.file(
#'     "extdata", "fake-oauth-client-id-and-secret.json",
#'     package = "googlesheets4"
#'   )
#'   gs4_auth_configure(path = app_path)
#'
#'   # confirm the changes
#'   gs4_oauth_app()
#' }
#'
#' # restore original auth config
#' gs4_auth_configure(app = original_app, api_key = original_api_key)
gs4_auth_configure <- function(app, path, api_key) {
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
#' @rdname gs4_auth_configure
gs4_api_key <- function() .auth$api_key

#' @export
#' @rdname gs4_auth_configure
gs4_oauth_app <- function() .auth$app

#' Get info on current user
#'
#' @eval gargle:::PREFIX_user_description()
#' @eval gargle:::PREFIX_user_seealso()
#' @eval gargle:::PREFIX_user_return()
#'
#' @export
#' @examples
#' gs4_user()
gs4_user <- function() {
  if (gs4_has_token()) {
    gargle::token_email(gs4_token())
  } else {
    message("Not logged in as any specific Google user.")
    invisible()
  }
}

# use this as a guard whenever a googlesheets4 function calls a
# googledrive function that can make an API call
# goal is to expose (most) cases of being auth'ed as 2 different users
# which can lead to very puzzling failures
check_gs4_email_is_drive_email <- function() {
  if (googledrive::drive_has_token() && gs4_has_token()) {
    drive_email <- googledrive::drive_user()[["emailAddress"]]
    gs4_email <- gs4_user()
    if (drive_email != gs4_email) {
      message_glue("
        Authenticated as 2 different users with googledrive and googlesheets4:
          * googledrive: {drive_email}
          * googlesheets4: {gs4_email}
        If you get a puzzling result, this is probably why.
        See the article \"Using googlesheets4 with googledrive\" for tips:
        https://googlesheets4.tidyverse.org/articles/articles/drive-and-sheets.html
      ")
    }
  }
}

# unexported helpers that are nice for internal use ----
gs4_auth_internal <- function(account = c("docs", "testing"),
                              scopes = NULL,
                              drive = TRUE) {
  stopifnot(gargle:::secret_can_decrypt("googlesheets4"))
  account <- match.arg(account)
  filename <- glue("googlesheets4-{account}.json")
  # TODO: revisit when I do PKG_scopes()
  # https://github.com/r-lib/gargle/issues/103
  scopes <- scopes %||% "https://www.googleapis.com/auth/drive"
  json <- gargle:::secret_read("googlesheets4", filename)
  gs4_auth(scopes = scopes, path = rawToChar(json))
  print(gs4_user())
  if (drive) {
    googledrive::drive_auth(token = gs4_token())
    print(googledrive::drive_user())
  }
  invisible(TRUE)
}

gs4_auth_docs <- function(scopes = NULL, drive = TRUE) {
  gs4_auth_internal("docs", scopes = scopes, drive = drive)
}

gs4_auth_testing <- function(scopes = NULL, drive = TRUE) {
  gs4_auth_internal("testing", scopes = scopes, drive = drive)
}
