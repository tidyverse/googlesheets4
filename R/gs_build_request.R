gs_build_request <- function(path,
                             verb,
                             params = list(),
                             .api_key = api_key()) {
  params <- partition_params(params, extract_param_names(path))
  out <- list(
    verb = verb,
    path = glue::glue_data(params$path_params, path),
    query = c(params$query_params, list(key = .api_key))
  )
  out$url <- httr::modify_url(
    url = .state$gs_base_url,
    path = out$path,
    query = out$query
  )
  out
}

gs_generate_request <- function(method = character(),
                                params = list(),
                                .api_key = api_key()) {
  endpoint <- .endpoints[[method]]
  if (is.null(endpoint)) {
    stop("Endpoint not recognized:\n", method, call. = FALSE)
  }

  params <- match_params(params, endpoint$parameters)
  params <- handle_repeats(params, endpoint$parameters)
  check_enums(params, endpoint$parameters)
  params <- partition_params(params, keep_path_param_names(endpoint$parameters))

  gs_build_request(
    path = glue::glue_data(params$path_params, endpoint$path),
    verb = endpoint$verb,
    params = params$query_params,
    .api_key = .api_key
  )
}

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

partition_params <- function(provided, path_param_names) {
  query_params <- provided
  path_params <- NULL
  if (length(path_param_names) && length(query_params)) {
    m <- names(provided) %in% path_param_names
    path_params <- query_params[m]
    query_params <- query_params[!m]
  }
  ## if no query_params, NULL is preferred to list()
  ## for the sake of downstream URLs
  if (length(query_params) == 0) {
    query_params <- NULL
  }
  return(list(
    path_params = path_params,
    query_params = query_params
  ))
}

keep_path_param_names <- function(spec) {
  spec %>%
    purrr::keep(~.x$location == "path") %>%
    names()
}

extract_param_names <- function(path) {
  m <- gregexpr("\\{[^/]*\\}", path)
  path_param_names <- regmatches(path, m)[[1]]
  gsub("[\\{\\}]", "", path_param_names)
}
