library(rprojroot)
library(jsonlite)
library(httr)
library(tidyverse)

## load the API spec, including download if necessary
dd_cache <- find_package_root_file("data-raw") %>%
  list.files(pattern = "discovery-document.json$", full.names = TRUE)
if (length(dd_cache) < 1) {
  dd_get <- GET("https://sheets.googleapis.com/$discovery/rest?version=v4")
  dd_content <- content(dd_get)
  json_fname <- dd_content[c("revision", "id")] %>%
    c("discovery-document") %>%
    map(~ str_replace_all(.x, ":", "-")) %>%
    str_c(collapse = "_") %>%
    str_c(".json") %>%
    find_package_root_file("data-raw", .)
  write_lines(
    content(dd_get, as = "text"),
    json_fname
  )
} else {
  json_fname <- rev(dd_cache)[1]
}
dd_content <- fromJSON(json_fname)
## listviewer::jsonedit(dd_content)

## extract the collections and bring to same level of hierarchy
spreadsheets <- dd_content[[c("resources", "spreadsheets", "methods")]]
names(spreadsheets) <- paste("spreadsheets", names(spreadsheets), sep = "_")
sheets <-
  dd_content[[c("resources", "spreadsheets", "resources", "sheets", "methods")]]
names(sheets) <- paste("sheets", names(sheets), sep = "_")
values <-
  dd_content[[c("resources", "spreadsheets", "resources", "values", "methods")]]
names(values) <- paste("values", names(values), sep = "_")
endpoints <- c(spreadsheets, sheets, values)
# str(endpoints, max.level = 1)
# listviewer::jsonedit(endpoints)

nms <- endpoints %>%
  map(names) %>%
  reduce(union)

## tibble with one row per endpoint
.endpoints <- endpoints %>%
  transpose(.names = nms) %>%
  simplify_all(.type = character(1)) %>%
  as_tibble()
#View(.endpoints)

## more processing is needed :(

## clean up individual variables

## these look identical, are they?
identical(.endpoints$path, .endpoints$flatPath)
## drop flatPath
.endpoints$flatPath <- NULL

## enforce my own order
.endpoints <- .endpoints %>%
  select(id, httpMethod, path, parameters, scopes, description, everything())

.endpoints$scopes <- .endpoints$scopes %>%
  map(~ gsub("https://www.googleapis.com/auth/", "", .)) %>%
  map_chr(str_c, collapse = ", ")

.endpoints$parameterOrder <- .endpoints$parameterOrder %>%
  modify_if(~ length(.x) < 1, ~ NA_character_) %>%
  map_chr(str_c, collapse = ", ")

.endpoints$response <- .endpoints$response %>%
  map_chr("$ref", .null = NA_character_)
.endpoints$request <- .endpoints$request %>%
  map_chr("$ref", .null = NA_character_)
#View(.endpoints)

## loooong side journey to clean up parameters
params <- .endpoints %>%
  select(id, parameters) %>% {
    ## unnest() won't work with a list ... doing it manually
    tibble(
      id = rep(.$id, lengths(.$parameters)),
      parameters = flatten(.$parameters),
      pname = names(parameters)
    )
  } %>%
  select(id, pname, parameters)
#params$parameters %>% map(names) %>% reduce(union)
nms <-
  c("location", "required", "type", "repeated", "format", "enum", "description")

## tibble with one row per parameter
## variables id and pname keep track of endpoint and parameter name
params <- params$parameters %>%
  transpose(.names = nms) %>%
  as_tibble() %>%
  add_column(pname = params$pname, .before = 1) %>%
  add_column(id = params$id, .before = 1)
params <- params %>%
  mutate(
    location = location %>% flatten_chr(),
    required = required %>% map(1, .null = NA) %>% flatten_lgl(),
    type = type %>% flatten_chr(),
    repeated = repeated %>% map(1, .null = NA) %>% flatten_lgl(),
    format = format %>%  map(1, .null = NA) %>% flatten_chr(),
    enum = enum %>%  modify_if(is_null, ~ NA),
    description = description %>% flatten_chr()
  )
## repack all the info for each parameter into a list
repacked <- params %>%
  select(-id, -pname, -location) %>%
  pmap(list)
params <- params %>%
  select(id, pname, location) %>%
  mutate(pdata = repacked)

## tibble with one or zero rows per endpoint and a list of path parameters
path_params <- params %>%
  filter(location == "path") %>%
  select(-location)
path_params <- path_params %>%
  group_by(id) %>%
  nest(.key = path_params) %>%
  mutate(path_params = map(path_params, deframe))

## tibble with one or zero rows per endpoint and a list of query parameters
query_params <- params %>%
  filter(location == "query") %>%
  select(-location)
query_params <- query_params %>%
  group_by(id) %>%
  nest(.key = query_params) %>%
  mutate(query_params = map(query_params, deframe))

## join the path and query parameters back to main endpoint tibble
.endpoints <- .endpoints %>%
  left_join(path_params) %>%
  left_join(query_params) %>%
  select(id, httpMethod, path, parameters, path_params, query_params,
         everything())

## spot check that we have the same (number of) parameters
tibble(
  orig_n = .endpoints$parameters %>% lengths(),
  path_n = .endpoints$path_params %>% lengths(),
  query_n = .endpoints$query_params %>% lengths(),
  new_n = path_n + query_n,
  ok = orig_n == new_n
)

.endpoints <- .endpoints %>%
  select(-parameters)

out_fname <- str_replace(
  json_fname,
  "discovery-document.json",
  "endpoints.rds")

saveRDS(.endpoints, file = out_fname)
use_data(.endpoints, internal = TRUE, overwrite = TRUE)
