gs_build_request <- function(method = character(), params = list()) {
  endpoint <- .endpoints[[method]]
  if (is.null(endpoint)) {
    stop("Endpoint not recognized:\n", method, call. = FALSE)
  }

  params <- match_params(params, endpoint$parameters)
  params <- handle_repeats(params, endpoint$parameters)
  ## Maybe TO DO: check parameter type?
  ## Everything will be coerced to character anyway, so if I relay error
  ## messages well, user will learn about malformed params anyway.
  check_enums(params, endpoint$parameters)
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

match_params <- function(provided, spec) {
  ## .endpoints %>% map("parameters") %>% flatten() %>% map_lgl("required")
  required <- spec %>% purrr::keep("required") %>% names()
  missing <- setdiff(required, names(provided))
  if (length(missing)) {
    stop(
      "Required parameter(s) are missing:\n",
      missing,
      call. = FALSE
    )
  }

  unknown <- setdiff(names(provided), names(spec))
  if (length(unknown)) {
    m <- names(provided) %in% unknown
    message(
      "Ignoring these unrecognized parameters:\n",
      paste(names(provided[m]), provided[m], sep = ": ", collapse = "\n")
    )
    provided <- provided[!m]
  }
  return(provided)
}

handle_repeats <- function(provided, spec) {

  if (length(provided) < 1) {
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

check_enums <- function(provided, spec) {
  values <- spec %>% purrr::map("enum")
  if (length(provided) < 1 | length(values) < 1) {
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

partition_params <- function(provided, spec) {
  path_params <- query_params <- NULL
  path_param_names <- spec %>%
    purrr::keep(~.x$location == "path") %>%
    names()
  query_param_names <- spec %>%
    purrr::keep(~.x$location == "query") %>%
    names()
  if (length(path_param_names) && length(provided)) {
    m <- names(provided) %in% path_param_names
    path_params <- provided[m]
    provided <- provided[!m]
  }
  if (length(query_param_names) && length(provided)) {
    m <- names(provided) %in% query_param_names
    ## leave query_params as NULL vs list() if no matches
    ## for the sake of downstream URLs
    if (any(m)) {
      query_params <- provided[m]
      provided <- provided[!m]
    }
  }

  return(list(
    path_params = path_params,
    query_params = query_params
  ))
}
