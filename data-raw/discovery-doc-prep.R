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
names(spreadsheets) <- paste("spreadsheets", names(spreadsheets), sep = ".")
sheets <-
  dd_content[[c("resources", "spreadsheets", "resources", "sheets", "methods")]]
names(sheets) <- paste("spreadsheets", "sheets", names(sheets), sep = ".")
values <-
  dd_content[[c("resources", "spreadsheets", "resources", "values", "methods")]]
names(values) <- paste("spreadsheets", "values", names(values), sep = ".")
endpoints <- c(spreadsheets, sheets, values)
# str(endpoints, max.level = 1)
# listviewer::jsonedit(endpoints)

nms <- endpoints %>%
  map(names) %>%
  reduce(union)

## tibble with one row per endpoint
edf <- endpoints %>%
  transpose(.names = nms) %>%
  simplify_all(.type = character(1)) %>%
  as_tibble()
#View(edf)

## more processing is needed :(

## clean up individual variables

## docs call these "methods" and omit the leading `sheets.`
edf <- edf %>%
  rename(method = id) %>%
  mutate(method = gsub("^sheets\\.", "", method))

## these look identical, are they?
identical(edf$path, edf$flatPath)
## drop flatPath
edf$flatPath <- NULL

## enforce my own order
edf <- edf %>%
  select(method, httpMethod, path, parameters, scopes, description, everything())

edf$scopes <- edf$scopes %>%
  map(~ gsub("https://www.googleapis.com/auth/", "", .)) %>%
  map_chr(str_c, collapse = ", ")

edf$parameterOrder <- edf$parameterOrder %>%
  modify_if(~ length(.x) < 1, ~ NA_character_) %>%
  map_chr(str_c, collapse = ", ")

edf$response <- edf$response %>%
  map_chr("$ref", .null = NA_character_)
edf$request <- edf$request %>%
  map_chr("$ref", .null = NA_character_)
#View(edf)

## loooong side journey to clean up parameters
params <- edf %>%
  select(method, parameters) %>% {
    ## unnest() won't work with a list ... doing it manually
    tibble(
      method = rep(.$method, lengths(.$parameters)),
      parameters = flatten(.$parameters),
      pname = names(parameters)
    )
  } %>%
  select(method, pname, parameters)
#params$parameters %>% map(names) %>% reduce(union)
nms <-
  c("location", "required", "type", "repeated", "format", "enum", "description")

## tibble with one row per parameter
## variables method and pname keep track of endpoint and parameter name
params <- params$parameters %>%
  transpose(.names = nms) %>%
  as_tibble() %>%
  add_column(pname = params$pname, .before = 1) %>%
  add_column(method = params$method, .before = 1)
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
  select(-method, -pname, -location) %>%
  pmap(list)
params <- params %>%
  select(method, pname, location) %>%
  mutate(pdata = repacked)

## tibble with one or zero rows per endpoint and a list of path parameters
path_params <- params %>%
  filter(location == "path") %>%
  select(-location)
path_params <- path_params %>%
  group_by(method) %>%
  nest(.key = path_params) %>%
  mutate(path_params = map(path_params, deframe))

## tibble with one or zero rows per endpoint and a list of query parameters
query_params <- params %>%
  filter(location == "query") %>%
  select(-location)
query_params <- query_params %>%
  group_by(method) %>%
  nest(.key = query_params) %>%
  mutate(query_params = map(query_params, deframe))

## join the path and query parameters back to main endpoint tibble
edf <- edf %>%
  left_join(path_params) %>%
  left_join(query_params) %>%
  select(method, httpMethod, path, parameters, path_params, query_params,
         everything())

## spot check that we have the same (number of) parameters
tibble(
  orig_n = edf$parameters %>% lengths(),
  path_n = edf$path_params %>% lengths(),
  query_n = edf$query_params %>% lengths(),
  new_n = path_n + query_n,
  ok = orig_n == new_n
)

edf <- edf %>%
  select(-parameters)

## WE ARE DONE
## saving in various forms

## full spec as tibble, one row per endpoint
out_fname <- str_replace(
  json_fname,
  "discovery-document.json",
  "endpoints-tibble.rds")
saveRDS(edf, file = out_fname)

## full spec as list
## transpose again, back to a list with one component per endpoint
elist <- edf %>%
  pmap(list) %>%
  set_names(edf$method)
#listviewer::jsonedit(elist)

out_fname <- str_replace(
  json_fname,
  "discovery-document.json",
  "endpoints-list.rds")
saveRDS(elist, file = out_fname)

out_fname <- str_replace(
  json_fname,
  "discovery-document.json",
  "endpoints-list.json")
elist %>%
  toJSON(pretty = TRUE) %>%
  writeLines(out_fname)

## partial spec as list, i.e. drop variables not needed internally
.endpoints <- edf %>%
  select(method, verb = httpMethod, path, path_params, query_params) %>%
  pmap(list) %>%
  set_names(edf$method)
#listviewer::jsonedit(.endpoints)

use_data(.endpoints, internal = TRUE, overwrite = TRUE)
