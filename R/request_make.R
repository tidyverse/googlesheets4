#' Make a Google Sheets API request
#'
#' @description Low-level function to execute a Sheets API request. Most users
#'   should, instead, use higher-level wrappers that facilitate common tasks,
#'   such as reading or writing worksheets or cell ranges. The functions here
#'   are intended for internal use and for programming around the Sheets API.
#'
#' @description `make_request()` does very, very little: it calls an HTTP
#'   method, only adding the googlesheets4 user agent. Typically the input has
#'   been created with [request_generate()] or [gargle::request_build()] and the
#'   output is processed with `process_response()`.
#'
#' @param x List. Holds the components for an HTTP request, presumably created
#'   with [request_generate()] or [gargle::request_build()]. Must contain a
#'   `method` and `url`. If present, `body` and `token` are used.
#' @param ... Optional arguments passed through to the HTTP method.
#' @param encode If the body is a named list, how should it be encoded? This is
#'   essentially the same as `encode` in all the [`httr::VERB()`]s, except we
#'   choose a different default: a default of `encode = "json"` is much more
#'   useful when calling Google APIs.
#'
#' @return Object of class `response` from [httr].
#' @export
#' @family low-level API functions
request_make <- function(x,
                         ...,
                         encode = c("json", "multipart", "form", "raw")) {
  # TODO: remove this if I implement it in gargle instead
  # https://github.com/r-lib/gargle/issues/124
  encode <- match.arg(encode)
  gargle::request_make(
    x, ..., encode = encode, user_agent = gs4_user_agent()
  )
}

gs4_user_agent <- function() {
  httr::user_agent(paste0(
    "googlesheets4/", utils::packageVersion("googlesheets4"), " ",
    "(GPN:RStudio; )", " ",
    "gargle/", utils::packageVersion("gargle"), " ",
    "httr/", utils::packageVersion("httr")
  ))
}
