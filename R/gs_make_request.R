gs_make_request <- function(req) {
  verb_fun <- list("GET" = httr::GET, "POST" = httr::POST, "PATCH" = httr::PATCH,
                   "PUT" = httr::PUT, "DELETE" = httr::DELETE)[[req$verb]]
  if (is.null(verb_fun)) {
    stop("Unknown HTTP verb:\n", req$verb, call. = FALSE)
  }
  raw <- do.call(
    verb_fun,
    list(
      url = req$url,
      query = list(key = api_key())
    )
  )
}
