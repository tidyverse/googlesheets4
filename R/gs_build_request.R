gs_build_request <- function(method = character(), params = list()) {
  endpoint <- .endpoints[[method]]
  if (is.null(endpoint)) {
    stop("Endpoint not recognized:\n", method, call. = FALSE)
  }

  params <- match_params(params, endpoint$parameters)
  params <- handle_repeats(params, endpoint$parameters)

  ## TO DO: check parameter type
  # .endpoints %>% map("path_params") %>% flatten() %>% map_chr("type")
  # .endpoints %>% map("query_params") %>% flatten() %>% map_chr("type")

  ## TO DO: check enums

  params <- partition_params(params, endpoint$parameters)

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

match_params <- function(have, allowed) {
  ## .endpoints %>% map("parameters") %>% flatten() %>% map_lgl("required")
  required <- allowed %>% purrr::keep("required") %>% names()
  missing <- setdiff(required, names(have))
  if (length(missing)) {
    stop(
      "Required parameter(s) are missing:\n",
      missing,
      call. = FALSE
    )
  }

  unknown <- setdiff(names(have), names(allowed))
  if (length(unknown)) {
    m <- names(have) %in% unknown
    message(
      "Ignoring these unrecognized parameters:\n",
      paste(names(have[m]), have[m], sep = ": ", collapse = "\n")
    )
    have <- have[!m]
  }
  return(have)
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

partition_params <- function(params, endpoint) {
  path_params <- query_params <- NULL
  path_param_names <- endpoint %>% purrr::keep(~.x$location == "path") %>% names()
  query_param_names <- endpoint %>% purrr::keep(~.x$location == "query") %>% names()
  if (length(path_param_names) && length(params)) {
    m <- names(params) %in% path_param_names
    path_params <- params[m]
    params <- params[!m]
  }
  if (length(query_param_names) && length(params)) {
    m <- names(params) %in% query_param_names
    ## leave query_params as NULL vs list() if no matches
    ## for the sake of downstream URLs
    if (any(m)) {
      query_params <- params[m]
      params <- params[!m]
    }
  }

  return(list(
    path_params = path_params,
    query_params = query_params
  ))
}
