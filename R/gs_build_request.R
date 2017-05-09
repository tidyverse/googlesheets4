#' Generate a request for the Sheets v4 API
#'
#' Generate a request, using some knowledge of the [Sheets v4
#' API](https://developers.google.com/sheets/api/reference/rest/). Most users
#' should, instead, use higher-level wrappers that facilitate common tasks, such
#' as reading the contents of a sheet. The functions here are intended for
#' internal use and for programming around the Sheets API.
#'
#' There are two functions:
#' * `gs_generate_request()` is a wrapper around `gs_build_request()`. It takes
#' a nickname for an endpoint and uses the API spec to look up the `path` and
#' `method`. The `params` are checked for validity and completeness with respect
#' to the endpoint. It then passes things along to `gs_build_request()`.
#' * `gs_build_request()` builds a request from explicit parts. It is quite
#' dumb, only doing URL endpoint substitution and URL formation. It's up to the
#' caller to make sure the `path`, `method`, and `params` are valid.
#'
#' @param endpoint `character(1)`\cr Nickname for one of the documented Sheets
#'   v4 API endpoints. *to do: list or link, once I've auto-generated those
#'   docs*
#' @param params `named list()`\cr Parameters destined for endpoint URL
#'   substitution or, otherwise, the query.
#' @param .api_key `character(1)`\cr A valid [API
#'   key](https://developers.google.com/sheets/api/guides/authorizing#APIKey).
#'   Defaults to a key built into the googlesheets package.
#'

#' @return `list()`\cr Components are `method`, `path`, `query`, and `url`,
#'   suitable as input for [gs_make_request()]. The `path` is post-substitution
#'   and the `query` is a named list of all the input `params` that were not
#'   used during this substitution. `url` is the full URL after prepending the
#'   base URL for the Sheets v4 API and appending an API key to the query.
#' @export
#' @examples
#' req <- gs_generate_request(
#'   "spreadsheets.values.append",
#'   list(
#'     spreadsheetId = "abc",
#'     range = "Sheet1!A1:B2",
#'     responseValueRenderOption = "FORMULA"
#'   )
#' )
#' req
gs_generate_request <- function(endpoint = character(),
                                params = list(),
                                .api_key = api_key()) {
  ept <- .endpoints[[endpoint]]
  if (is.null(ept)) {
    stop("Endpoint not recognized:\n", endpoint, call. = FALSE)
  }

  ## use the spec to vet and rework request parameters
  params <-  match_params(params, ept$parameters)
  params <- handle_repeats(params, ept$parameters)
  check_enums(params, ept$parameters)
  params <- partition_params(params, keep_path_param_names(ept$parameters))

  gs_build_request(
    path = glue::glue_data(params$path_params, ept$path),
    method = ept$method,
    params = params$query_params,
    .api_key = .api_key
  )
}

#' @param path character, e.g.,
#'   `"v4/spreadsheets/{spreadsheetId}/values/{range}:append"`. It can include
#'   variables inside curly brackets, as the example does, which are substituted
#'   using named parameters found in the `params` argument.
#' @param method character, should match an HTTP verb, e.g., `GET`, `POST`, or
#'   `PUT`
#' @rdname gs_generate_request
#' @export
#' @examples
#' req <- gs_build_request(
#'   path = "v4/spreadsheets/{spreadsheetId}/values/{range}:append",
#'   method = "POST",
#'   list(
#'     spreadsheetId = "abc",
#'     range = "Sheet1!A1:B2",
#'     responseValueRenderOption = "FORMULA"
#'   )
#' )
#' req
gs_build_request <- function(path,
                             method,
                             params = list(),
                             .api_key = api_key()) {
  params <- partition_params(params, extract_param_names(path))
  out <- list(
    method = method,
    path = glue::glue_data(params$path_params, path),
    query = c(params$query_params, list(key = .api_key))
  )
  ## yes it is redundant to store the parts and the url
  ## but it is helpful to me, so it shall be this way
  out$url <- httr::modify_url(
    url = .state$gs_base_url,
    path = out$path,
    query = out$query
  )
  out
}

## match params provided by user to spec
##   * error if required params are missing
##   * message and drop unknown params
match_params <- function(provided, spec) {
  ## .endpoints %>% map("parameters") %>% flatten() %>% map_lgl("required")
  required <- spec %>% purrr::keep("required") %>% names()
  missing <- setdiff(required, names(provided))
  if (length(missing)) {
    stop("Required parameter(s) are missing:\n", missing, call. = FALSE)
  }

  unknown <- setdiff(names(provided), names(spec))
  if (length(unknown)) {
    m <- names(provided) %in% unknown
    msgs <- c(
      "Ignoring these unrecognized parameters:",
      glue::glue_data(tibble::enframe(provided[m]), "{name}: {value}")
    )
    message(paste(msgs, collapse = "\n"))
    provided <- provided[!m]
  }
  return(provided)
}

## certain params can be repeated on specific endpoints, e.g., ranges
##   * replicate as needed in the query params
##   * detect and error for any other repetition
handle_repeats <- function(provided, spec) {

  if (length(provided) == 0) {
    return(provided)
  }
  can_repeat <- spec[names(provided)] %>%
    purrr::map_lgl("repeated") %>%
    purrr::map_lgl(isTRUE)
  too_long <- lengths(provided) > 1 & !can_repeat
  if (any(too_long)) {
    stop(
      "These parameter(s) are not allowed to have length > 1:\n",
      names(provided)[too_long],
      call. = FALSE
    )
  }

  is_a_repeat <- duplicated(names(provided))
  too_many <- is_a_repeat & !can_repeat
  if (any(too_many)) {
    stop(
      "These parameter(s) are not allowed to appear more than once:\n",
      names(provided)[too_many],
      call. = FALSE
    )
  }

  ## replicate anything with length > 1
  n <- lengths(provided)
  nms <- names(provided)
  ## this thwarts protection from urlencoding via I() ... revisit if needed
  provided <- provided %>% purrr::flatten() %>% purrr::set_names(rep(nms, n))

  return(provided)
}

## a few parameters have fixed lists of possible values -- a.k.a the "enums"
check_enums <- function(provided, spec) {
  values <- spec %>% purrr::map("enum")
  if (length(provided) == 0 | length(values) == 0) {
    return(provided)
  }
  check_it <- tibble::tibble(
    pname = names(provided),
    pdata = purrr::flatten_chr(provided)
  )
  check_it$values = values[check_it$pname]
  not_an_enum <- check_it$values %>% purrr::map(is.na) %>% purrr::map_lgl(all)
  check_it <- check_it[!not_an_enum, ]
  ok <- purrr::map2_lgl(check_it$pdata, check_it$values, ~ .x %in% .y)
  if (any(!ok)) {
    problems <- check_it[!ok, ]
    problems$values <- problems$values %>% purrr::map_chr(paste, collapse = " | ")
    template <- paste0("Parameter '{pname}' has value '{pdata}', ",
                       "but it must be one of these:\n{values}\n\n")
    msgs <- glue::glue_data(problems, template)
    msgs %>% purrr::walk(message)
    stop("Invalid parameter value(s).", call. = FALSE)
  }
  return(provided)
}

## extract the path params by name and put the leftovers in query
## why is this correct?
## if the endpoint was specified, we have already matched against spec
## if the endpoint was unspecified, we have no choice
partition_params <- function(provided, path_param_names) {
  query_params <- provided
  path_params <- NULL
  if (length(path_param_names) && length(query_params)) {
    m <- names(provided) %in% path_param_names
    path_params <- query_params[m]
    query_params <- query_params[!m]
  }
  ## if no query_params, NULL is preferred to list() for the sake of
  ## downstream URLs, though the API key will generally imply there are
  ## no empty queries
  if (length(query_params) == 0) {
    query_params <- NULL
  }
  return(list(
    path_params = path_params,
    query_params = query_params
  ))
}

## names of parameters declared in spec to be in path vs query
keep_path_param_names <- function(spec) {
  spec %>%
    purrr::keep(~.x$location == "path") %>%
    names()
}

##  input: /v4/spreadsheets/{spreadsheetId}/sheets/{sheetId}:copyTo
## output: spreadsheetId, sheetId
extract_param_names <- function(path) {
  m <- gregexpr("\\{[^/]*\\}", path)
  path_param_names <- regmatches(path, m)[[1]]
  gsub("[\\{\\}]", "", path_param_names)
}
