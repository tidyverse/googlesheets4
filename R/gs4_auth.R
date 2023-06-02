# This file is the interface between googlesheets4 and the
# auth functionality in gargle.

# Initialization happens in .onLoad
.auth <- NULL

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
#' @examplesIf rlang::is_interactive()
#' # load/refresh existing credentials, if available
#' # otherwise, go to browser for authentication and authorization
#' gs4_auth()
#'
#' # indicate the specific identity you want to auth as
#' gs4_auth(email = "jenny@example.com")
#'
#' # force a new browser dance, i.e. don't even try to use existing user
#' # credentials
#' gs4_auth(email = NA)
#'
#' # use a 'read only' scope, so it's impossible to edit or delete Sheets
#' gs4_auth(
#'   scopes = "https://www.googleapis.com/auth/spreadsheets.readonly"
#' )
#'
#' # use a service account token
#' gs4_auth(path = "foofy-83ee9e7c9c48.json")
gs4_auth <- function(email = gargle::gargle_oauth_email(),
                     path = NULL,
                     scopes = "https://www.googleapis.com/auth/spreadsheets",
                     cache = gargle::gargle_oauth_cache(),
                     use_oob = gargle::gargle_oob_default(),
                     token = NULL) {
  gargle::check_is_service_account(path, hint = "gs4_auth_configure")

  # I have called `gs4_auth(token = drive_token())` multiple times now,
  # without attaching googledrive. Expose this error noisily, before it gets
  # muffled by the `tryCatch()` treatment of `token_fetch()`.
  force(token)

  cred <- gargle::token_fetch(
    scopes = scopes,
    client = gs4_oauth_client() %||% gargle::tidyverse_client(),
    email = email,
    path = path,
    package = "googlesheets4",
    cache = cache,
    use_oob = use_oob,
    token = token
  )
  if (!inherits(cred, "Token2.0")) {
    gs4_abort(c(
      "Can't get Google credentials.",
      "i" = "Are you running {.pkg googlesheets4} in a non-interactive \\
             session? Consider:",
      "*" = "Call {.fun gs4_deauth} to prevent the attempt to get credentials.",
      "*" = "Call {.fun gs4_auth} directly with all necessary specifics.",
      "i" = "See gargle's \"Non-interactive auth\" vignette for more details:",
      "i" = "{.url https://gargle.r-lib.org/articles/non-interactive-auth.html}"
    ))
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
#' @examplesIf rlang::is_interactive()
#' gs4_deauth()
#' gs4_user()
#'
#' # get metadata on the public 'deaths' spreadsheet
#' gs4_example("deaths") %>%
#'   gs4_get()
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
#' @examplesIf gs4_has_token()
#' req <- request_generate(
#'   "sheets.spreadsheets.get",
#'   list(spreadsheetId = "abc"),
#'   token = gs4_token()
#' )
#' req
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
#' # see and store the current user-configured OAuth client (probably `NULL`)
#' (original_client <- gs4_oauth_client())
#'
#' # see and store the current user-configured API key (probably `NULL`)
#' (original_api_key <- gs4_api_key())
#'
#' # the preferred way to configure your own client is via a JSON file
#' # downloaded from Google Developers Console
#' # this example JSON is indicative, but fake
#' path_to_json <- system.file(
#'   "extdata", "client_secret_installed.googleusercontent.com.json",
#'   package = "gargle"
#' )
#' gs4_auth_configure(path = path_to_json)
#'
#' # this is also obviously a fake API key
#' gs4_auth_configure(api_key = "the_key_I_got_for_a_google_API")
#'
#' # confirm the changes
#' gs4_oauth_client()
#' gs4_api_key()
#'
#' # restore original auth config
#' gs4_auth_configure(client = original_client, api_key = original_api_key)
gs4_auth_configure <- function(client, path, api_key, app = deprecated()) {
  if (lifecycle::is_present(app)) {
    lifecycle::deprecate_warn(
      "1.1.0",
      "gs4_auth_configure(app)",
      "gs4_auth_configure(client)"
    )
    gs4_auth_configure(client = app, path = path, api_key = api_key)
  }

  if (!missing(client) && !missing(path)) {
    gs4_abort("Must supply exactly one of {.arg client} and {.arg path}, not both.")
  }
  stopifnot(missing(api_key) || is.null(api_key) || is_string(api_key))

  if (!missing(path)) {
    stopifnot(is_string(path))
    client <- gargle::gargle_oauth_client_from_json(path)
  }
  stopifnot(missing(client) || is.null(client) || inherits(client, "gargle_oauth_client"))

  if (!missing(client) || !missing(path)) {
    .auth$set_client(client)
  }

  if (!missing(api_key)) {
    .auth$set_api_key(api_key)
  }

  invisible(.auth)
}

#' @export
#' @rdname gs4_auth_configure
gs4_api_key <- function() {
  .auth$api_key
}

#' @export
#' @rdname gs4_auth_configure
gs4_oauth_client <- function() {
  .auth$client
}

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
  if (!gs4_has_token()) {
    gs4_bullets(c(i = "Not logged in as any specific Google user."))
    return(invisible())
  }

  email <- gargle::token_email(gs4_token())
  gs4_bullets(c(i = "Logged in to {.pkg googlesheets4} as {.email {email}}."))
  invisible(email)
}

# use this as a guard whenever a googlesheets4 function calls a
# googledrive function that can make an API call
# goal is to expose (most) cases of being auth'ed as 2 different users
# which can lead to very puzzling failures
check_gs4_email_is_drive_email <- function() {
  if (googledrive::drive_has_token() && gs4_has_token()) {
    drive_email <- googledrive::drive_user()[["emailAddress"]]
    gs4_email <- with_gs4_quiet(gs4_user())
    if (drive_email != gs4_email) {
      gs4_bullets(c(
        "!" = "Authenticated as 2 different users with googledrive and \\
               googlesheets4:",
        " " = "googledrive: {.email {drive_email}}",
        " " = "googlesheets4: {.email {gs4_email}}",
        " " = "If you get a puzzling result, this is probably why.",
        "i" = "See the article \"Using googlesheets4 with googledrive\" \\
               for tips:",
        " " = "{.url https://googlesheets4.tidyverse.org/articles/articles/drive-and-sheets.html}"
      ))
    }
  }
}

# unexported helpers that are nice for internal use ----
gs4_auth_internal <- function(account = c("docs", "testing"),
                              scopes = NULL,
                              drive = TRUE) {
  account <- match.arg(account)
  can_decrypt <- gargle:::secret_can_decrypt("googlesheets4")
  online <- !is.null(curl::nslookup("sheets.googleapis.com", error = FALSE))
  if (!can_decrypt || !online) {
    gs4_abort(
      message = c(
        "Auth unsuccessful:",
        if (!can_decrypt) {
          c("x" = "Can't decrypt the {.field {account}} service account token.")
        },
        if (!online) {
          c("x" = "We don't appear to be online. Or maybe the Sheets API is down?")
        }
      ),
      class = "googlesheets4_auth_internal_error",
      can_decrypt = can_decrypt, online = online
    )
  }

  if (!is_interactive()) local_gs4_quiet()
  filename <- glue("googlesheets4-{account}.json")
  # TODO: revisit when I do PKG_scopes()
  # https://github.com/r-lib/gargle/issues/103
  scopes <- scopes %||% "https://www.googleapis.com/auth/drive"
  json <- gargle:::secret_read("googlesheets4", filename)
  gs4_auth(scopes = scopes, path = rawToChar(json))
  gs4_user()
  if (drive) {
    googledrive::drive_auth(token = gs4_token())
    gs4_bullets(c(i = "Authed also with {.pkg googledrive}."))
  }
  invisible(TRUE)
}

gs4_auth_docs <- function(scopes = NULL, drive = TRUE) {
  gs4_auth_internal("docs", scopes = scopes, drive = drive)
}

gs4_auth_testing <- function(scopes = NULL, drive = TRUE) {
  gs4_auth_internal("testing", scopes = scopes, drive = drive)
}

local_deauth <- function(env = parent.frame()) {
  original_cred <- .auth$get_cred()
  original_auth_active <- .auth$auth_active
  gs4_bullets(c(i = "Going into deauthorized state."))
  withr::defer(
    gs4_bullets(c("i" = "Restoring previous auth state.")),
    envir = env
  )
  withr::defer(
    {
      .auth$set_cred(original_cred)
      .auth$set_auth_active(original_auth_active)
    },
    envir = env
  )
  gs4_deauth()
}

# deprecated functions ----

#' Get currently configured OAuth app (deprecated)
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' In light of the new [gargle::gargle_oauth_client()] constructor and class of
#' the same name, `gs4_oauth_app()` is being replaced by
#' [gs4_oauth_client()].
#' @keywords internal
#' @export
gs4_oauth_app <- function() {
  lifecycle::deprecate_warn(
    "1.1.0", "gs4_oauth_app()", "gs4_oauth_client()"
  )
  gs4_oauth_client()
}

