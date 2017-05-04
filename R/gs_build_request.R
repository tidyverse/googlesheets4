gs_build_request <- function(method = character(), params = list()) {
  endpoint <- .endpoints[[method]]
  if (is.null(endpoint)) {
    stop("Endpoint not recognized:\n", method, call. = FALSE)
  }

  params <- partition_params(params, endpoint)

  require_params(params$path_params, endpoint$path_params)
  require_params(params$query_params, endpoint$query_params)

  handle_repeats(params$path_params, endpoint$path_params)
  params$query_params <-
    handle_repeats(params$query_params, endpoint$query_params)

  ## TO DO: check parameter type
  # .endpoints %>% map("path_params") %>% flatten() %>% map_chr("type")
  # .endpoints %>% map("query_params") %>% flatten() %>% map_chr("type")

  ## TO DO: check enums

  out <- list(
    method = method,
    verb = endpoint$verb,
    path = glue::glue_data(params$path_params, endpoint$path),
    query = params$query_params
  )
  out$url <- httr::modify_url(
    url = .state$gs_base_url,
    path = out$path,
    query = out$query
  )
  out
}

## simply partitions -- no checks for completeness, length, or type
partition_params <- function(params, endpoint) {
  path_params <- query_params <- NULL
  if (length(endpoint$path_params) && length(params)) {
    m <- names(params) %in% names(endpoint$path_params)
    path_params <- params[m]
    params <- params[-m]
  }
  if (length(endpoint$query_params) && length(params)) {
    m <- names(params) %in% names(endpoint$query_params)
    ## leave query_params as NULL vs list() if no matches
    if (any(m)) {
      query_params <- params[m]
      params <- params[!m]
    }
  }
  if (length(params)) {
    message(
      "Ignoring these unrecognized parameters:\n",
      paste(names(params), params, sep = ": ", collapse = "\n")
    )
  }
  return(list(
    path_params = path_params,
    query_params = query_params
  ))
}


require_params <- function(have, need) {
  ## .endpoints %>% map("path_params") %>% flatten() %>% map_lgl("required")
  ## .endpoints %>% map("query_params") %>% flatten() %>% map_lgl("required")
  required <- need %>% purrr::map_lgl("required") %>% purrr::map_lgl(isTRUE)
  need <- need[required]
  missing <- setdiff(names(need), names(have))
  if (length(missing)) {
    stop(
      "Required parameter(s) are missing:\n",
      missing,
      call. = FALSE
    )
  }
  return(invisible())
}

handle_repeats <- function(user, api) {

  if (length(user) < 1) {
    return(invisible(user))
  }
  can_repeat <- api[names(user)] %>%
    purrr::map_lgl("repeated") %>%
    purrr::map_lgl(isTRUE)
  too_long <- lengths(user) > 1 & !can_repeat
  if (any(too_long)) {
    stop(
      "These parameter(s) are not allowed to have length > 1:\n",
      names(user)[too_long],
      call. = FALSE
    )
  }

  is_a_repeat <- duplicated(names(user))
  too_many <- is_a_repeat & !can_repeat
  if (any(too_many)) {
    stop(
      "These parameter(s) are not allowed to appear more than once:\n",
      names(user)[too_many],
      call. = FALSE
    )
  }

  ## replicate anything with length > 1
  n <- lengths(user)
  nms <- names(user)
  ## this thwarts protection from urlencoding via I() ... revisit if needed
  user <- user %>% purrr::flatten() %>% purrr::set_names(rep(nms, n))

  return(invisible(user))
}
