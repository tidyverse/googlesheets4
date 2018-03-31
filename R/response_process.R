#' Process a response from a Google API
#'
#' Temporarily gestating this in googlesheets4 but it is destined for gargle.
#'
#' @param resp Object of class `response` from [httr].
#'
#' @return List.
#' @export
#' @family low-level API functions
response_process <- function(resp) {
  status <- httr::status_code(resp)

  if (status < 200 || (status >= 300 && status < 400)) {
    stop_glue(
      "HTTP status codes in the 100s and 300s are not handled:\n",
      "  * Status code: {sq(status)}"
    )
  }

  if (status == 204) {
    return(TRUE)
  }

  if (status >= 400) {
    google_error(resp)
  }

  resp %>%
    stop_for_content_type() %>%
    httr::content(as = "parsed", type = "application/json")
}

google_error <- function(resp) {
  type <- httr::parse_media(resp$headers$`Content-type`)

  if (type$complete != "application/json") {
    stop_glue_data(
      list(out = httr::content(resp, as = "text")),
      "HTTP error [{resp$status}] {out}"
    )
  }

  ## I have reason to believe that this differs for Drive, Sheets, BigQuery :(
  error <- purrr::pluck(
    httr::content(resp, as = "parsed", type = "application/json"),
    "error"
  )

  ## lots of unfortunate names here, but I'm following Google's lead for now
  code <- error$code
  message <- error$message
  status <- error$status

  cl <- c(
    "googlesheets4_error", paste0("http_error_", code),
    "error", "condition"
  )
  errmsg <- glue(
    "HTTP error {code}\n",
    "  * message: {sq(message)}\n",
    "  * status: {sq(status)}"
  )
  cond <- structure(list(message = errmsg), class = cl)
  stop(cond)
}

stop_for_content_type <- function(response,
                                  expected = "application/json; charset=UTF-8") {
  actual <- response$headers$`Content-Type`
  if (actual != expected) {
    stop_glue(
      "\n\nExpected content-type:\n  * {expected}\n",
      "Actual content-type:\n  * {actual}"
    )
  }
  response
}

## https://cloud.google.com/apis/design/errors
## https://github.com/googleapis/googleapis/blob/master/google/rpc/error_details.proto
oops <- tibble::tribble(
  ~HTTP,                  ~RPC, ~Description,
    200,                  "OK", "No error.",
    400,    "INVALID_ARGUMENT", "Client specified an invalid argument. Check error message and error details for more information.",
    400, "FAILED_PRECONDITION", "Request can not be executed in the current system state, such as deleting a non-empty directory.",
    400,        "OUT_OF_RANGE", "Client specified an invalid range.",
    401,     "UNAUTHENTICATED", "Request not authenticated due to missing, invalid, or expired OAuth token.",
    403,   "PERMISSION_DENIED", "Client does not have sufficient permission. This can happen because the OAuth token does not have the right scopes, the client doesn't have permission, or the API has not been enabled for the client project.",
    404,           "NOT_FOUND", "A specified resource is not found, or the request is rejected by undisclosed reasons, such as whitelisting.",
    409,             "ABORTED", "Concurrency conflict, such as read-modify-write conflict.",
    409,      "ALREADY_EXISTS", "The resource that a client tried to create already exists.",
    429,  "RESOURCE_EXHAUSTED", "Either out of resource quota or reaching rate limiting. The client should look for google.rpc.QuotaFailure error detail for more information.",
    499,           "CANCELLED", "Request cancelled by the client.",
    500,           "DATA_LOSS", "Unrecoverable data loss or data corruption. The client should report the error to the user.",
    500,             "UNKNOWN", "Unknown server error. Typically a server bug.",
    500,            "INTERNAL", "Internal server error. Typically a server bug.",
    501,     "NOT_IMPLEMENTED", "API method not implemented by the server.",
    503,         "UNAVAILABLE", "Service unavailable. Typically the server is down.",
    504,   "DEADLINE_EXCEEDED", "Request deadline exceeded. This will happen only if the caller sets a deadline that is shorter than the method's default deadline (i.e. requested deadline is not enough for the server to process the request) and the request did not finish within the deadline."
  )
