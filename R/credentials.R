# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Produce the API key
#'
#' If a request doesn't require authorization, such as reading public data, it
#' is sufficient to call the Sheets API with only an API key, as opposed to an
#' OAuth2.0 token. Therefore, googlesheets ships with an API key and sends it
#' with every request. The user can override this default by defining the
#' `GOOGLESHEETS_API_KEY` environment variable or by specifying the key
#' directly in a function call.
#'
#' To override for the length of an R session, use [Sys.setenv()]:
#'
#' ```
#' Sys.setenv(GOOGLESHEETS_API_KEY = "YOUR_KEY_GOES_HERE")
#' ```
#'
#' To override more persistently, define the env var in a `.Renviron` file that
#' will be consulted at startup. Include a line like this:
#'
#' ```
#' GOOGLESHEETS_API_KEY=YOUR_KEY_GOES_HERE
#' ```
#'
#' See [Startup] for possible locations for this file and the implications
#' thereof.
#'
#' @return an API key, as a length-one character vector
#' @export
#'
#' @examples
#' ## the built-in fallback key
#' api_key()
#'
#' ## we use withr::with_envvar() to temporarily set GOOGLESHEETS_API_KEY
#' if (requireNamespace("withr", quietly = TRUE)) {
#'   withr::with_envvar(
#'     new = c("GOOGLESHEETS_API_KEY" = "abc"),
#'     api_key()
#'   )
#' }
api_key <- function() {
  key <- Sys.getenv("GOOGLESHEETS_API_KEY", "")
  if (key == "") getOption("googlesheets.api.key") else key
}

#' Produce Google token
#'
#' If token is not already available, call [gs_auth()] to either load from cache
#' or initiate OAuth2.0 flow. Return the token -- not "bare" but, rather,
#' prepared for inclusion in downstream requests. Use the unexported function
#' `access_token()`` to reveal the actual access token, suitable for use with
#' `curl`.
#'
#' @return a `httr::request-class` object (an S3 class provided by httr)
#'
#' @keywords internal
google_token <- function(verbose = FALSE) {
  if (!token_available(verbose = verbose)) gs_auth(verbose = verbose)
  httr::config(token = .state$token)
}

#' @rdname google_token
include_token_if <- function(cond) if (cond) google_token() else NULL
#' @rdname google_token
omit_token_if <- function(cond) if (cond) NULL else google_token()

#' Check token availability
#'
#' Check if a token is available in googlesheets' internal `.state` environment.
#'
#' @return logical
#'
#' @keywords internal
token_available <- function(verbose = TRUE) {

  if (is.null(.state$token)) {
    if (verbose) {
      if (file.exists(".httr-oauth")) {
        message("A .httr-oauth file exists in current working ",
                "directory.\nWhen/if needed, the credentials cached in ",
                ".httr-oauth will be used for this session.\nOr run gs_auth() ",
                "for explicit authentication and authorization.")
      } else {
        message("No .httr-oauth file exists in current working directory.\n",
                "When/if needed, googlesheets will initiate authentication ",
                "and authorization.\nOr run gs_auth() to trigger this ",
                "explicitly.")
      }
    }
    return(FALSE)
  }

  TRUE

}

## useful when debugging
access_token <- function() {
  if (!token_available(verbose = TRUE)) return(NULL)
  .state$token$credentials$access_token
}
