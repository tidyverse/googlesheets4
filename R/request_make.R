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
#' @param encode If the body is a named list, how should it be encoded? This has
#'   the same meaning as `encode` in all the [httr::VERB()]s, such as
#'   [httr::POST()]. Note, however, that we default to `encode = "json"`, which
#'   is what you want most of the time when calling the Sheets API. The httr
#'   default is `"multipart"`. Other acceptable values are `"form"` and `"raw"`.
#'
#' @return Object of class `response` from [httr].
#' @export
#' @family low-level API functions
request_make <- function(x, ..., encode = "json") {
  gargle::request_retry(
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
