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
