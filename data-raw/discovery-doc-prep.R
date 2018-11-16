library(rprojroot)
library(jsonlite)
library(httr)
library(tidyverse)
conflicted::conflict_prefer("flatten", "purrr")

## load the API spec, including download if necessary
dd_cache <- find_package_root_file("data-raw") %>%
  list.files(pattern = "discovery-document.json$", full.names = TRUE)
if (length(dd_cache) == 0) {
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
View(dd_content)

dd_content[["baseUrl"]]
## "https://sheets.googleapis.com/"

## extract methods for the spreadsheets collection ... why?
## because I will have to call the 'get' method, at the very least
## for the main spreadsheet object
spreadsheets <- dd_content[[c("resources", "spreadsheets", "methods")]]
## names(spreadsheets)
names(spreadsheets) <- map_chr(spreadsheets, "id")

## extract methods for the spreadsheets.values collection ... why?
## https://developers.google.com/sheets/api/samples/
## "If you just need to read or write cell values, the spreadsheets.values
## collection is a better choice than the spreadsheets collection. The
## former's interface is easier to use for simple read/write operations."
values <- dd_content[[c("resources", "spreadsheets", "resources", "values", "methods")]]
## names(values)
names(values) <- map_chr(values, "id")

## catenate these two lists of methods
endpoints <- c(spreadsheets, values)
View(endpoints)

## add API-wide params to all endpoints
add_global_params <- function(x) {
  x[["parameters"]] <- c(x[["parameters"]], dd_content[["parameters"]])
  x
}
endpoints <- map(endpoints, add_global_params)

nms <- endpoints %>%
  map(names) %>%
  reduce(union)

## tibble with one row per endpoint
edf <- endpoints %>%
  transpose(.names = nms) %>%
  simplify_all(.type = character(1)) %>%
  as_tibble()
View(edf)

## more processing is needed :(

## clean up individual variables

## it is tempting to trim the entire common stem from 'id'
## e.g. delete "sheets.spreadsheets." from "sheets.spreadsheets.get"
## but I will resist and only trim "sheets." for now
## that is consistent with method ids given in the docs
edf <- edf %>%
  mutate(id = gsub("^sheets\\.", "", id))

## these look identical, are they?
identical(edf$path, edf$flatPath)
## Yes! drop flatPath
edf$flatPath <- NULL

## enforce my own variable order
edf <- edf %>%
  select(id, httpMethod, path, parameters, scopes, description, everything())

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
View(edf)

## tbh I'm not sure what 'parameterOrder' is good for?

## loooong side journey to clean up parameters
## give them common sub-elements, in a common order
params <- edf %>%
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
nms <- c(
  "location", "required", "type", "repeated", "description",
  "enum", "enumDescriptions", "default"
)

## tibble with one row per parameter
## variables method and pname keep track of endpoint and parameter name
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
    description = description %>% flatten_chr(),
    enum = enum %>% modify_if(is_null, ~ NA)
    #enumDescriptions = enumDescriptions %>% modify_if(is_null, ~ NA),
    #default = default %>% map(1, .null = NA) %>% flatten_chr()
  ) %>%
  select(-enumDescriptions, -default)

## repack all the info for each parameter into a list
repacked <- params %>%
  select(-id, -pname) %>%
  pmap(list)
params <- params %>%
  select(id, pname) %>%
  mutate(pdata = repacked)

## repack all the parameters for each method into a named list
params <- params %>%
  group_by(id) %>%
  nest(.key = parameters) %>%
  mutate(parameters = map(parameters, deframe))

## replace the parameters in the main endpoint tibble
edf <- edf %>%
  select(-parameters) %>%
  left_join(params) %>%
  select(id, httpMethod, path, parameters, everything())
View(edf)

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
  set_names(edf$id)
View(elist)

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

## as csv, dropping the 'parameters' list-column
out_fname <- str_replace(
  json_fname,
  "discovery-document.json",
  "endpoints-list.csv")
write_csv(select(edf, -parameters), path = out_fname)

## partial spec as list, i.e. keep only the variables I currently use to
## create the API
## rename to 'method', from 'httpMethod'
.endpoints <- edf %>%
  select(id, method = httpMethod, path, parameters, request, response) %>%
  pmap(list) %>%
  set_names(edf$id)
attr(.endpoints, "base_url") <- dd_content$baseUrl
View(.endpoints)

usethis::use_data(.endpoints, internal = TRUE, overwrite = TRUE)

## TO CONSIDER:
## store schemas that seem very important, i.e. I might actually write
## some code specific to creating or parsing such an item

# schemas <- c(edf$request, edf$response)
# tibble(schemas) %>%
#   drop_na(schemas) %>%
#   count(schemas) %>%
#   arrange(desc(n)) %>%
#   filter(n > 1) %>%
#   pull(schemas)
## Lesson: "Spreadsheet" and "ValueRange" seem worthy

# .schemas <- dd_content[["schemas"]][c("Spreadsheet", "ValueRange")]
# view(.schemas)
