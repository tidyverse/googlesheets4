stop_for_content_type <- function(resp, expected) {
  actual <- resp$headers$`Content-Type`
  if (actual != expected) {
    stop(
      glue::glue(
        "Expected content-type:\n{expected}\n",
        "Actual content-type:\n{actual}")
    )
  }
  invisible(resp)
}

content_as_json_UTF8 <- function(resp) {
  resp %>%
    stop_for_content_type("application/json; charset=UTF-8") %>%
    httr::content(resp, as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON(simplifyVector = FALSE)
}

## http://www.iana.org/assignments/http-status-codes/http-status-codes-1.csv

VERB_n <- function(VERB, n = 5) {
  function(...) {
    for (i in seq_len(n)) {
      out <- VERB(...)
      status <- httr::status_code(out)
      if (status < 500 || i == n) break
      backoff <- stats::runif(n = 1, min = 0, max = 2 ^ i - 1)
      ## TO DO: honor a verbose argument or option
      mess <- paste("HTTP error %s on attempt %d ...\n",
                    "  backing off %0.2f seconds, retrying")
      mpf(mess, status, i, backoff)
      Sys.sleep(backoff)
    }
    out
  }
}

rGET <- VERB_n(httr::GET)
