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

## extract the collections and get to same level of hierarchy
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

## determine the names of sub-items and a consensus order
## get vector of names for each endpoint
nms_list <- endpoints %>%
  map(names)
## union of names across endpoints
nms_glop <- nms_list %>%
  reduce(union)
## reach a consensus on name order
nms_rksum <- nms_list %>%
  map_dfc(~ match(nms_glop, .x)) %>%
  rowSums(na.rm = TRUE)
nms <- nms_glop[order(nms_rksum)]

## over-simple functions to coerce to atomic, if possible
can_be_atomic <- function(l) all(lengths(l) < 2)
atomicate <- function(l) {
  ## would be use the most frequent class
  cls <- class(l[[1]])
  switch(cls,
         logical = flatten_lgl(l),
         integer = flatten_int(l),
         numeric = flatten_dbl(l),
         character = flatten_chr(l),
         l)
}

## poor woman's implementation of transpread()
## transpose a list and make a tibble
.endpoints <- nms %>%
  map(~ map(endpoints, .x)) %>%
  modify_if(can_be_atomic, atomicate) %>%
  set_names(nms) %>%
  as_tibble()
#View(.endpoints)

## more processing is needed :(

## these look identical, are they?
identical(.endpoints$path, .endpoints$flatPath)
## drop flatPath
.endpoints$flatPath <- NULL

## consensus order from above is pretty lame, actually
.endpoints <- .endpoints %>%
  select(id, httpMethod, path, parameters, scopes, description, everything())

.endpoints$scopes <- .endpoints$scopes %>%
  map(~ gsub("https://www.googleapis.com/auth/", "", .)) %>%
  map_chr(str_c, collapse = ", ")

.endpoints$parameterOrder <- .endpoints$parameterOrder %>%
  modify_if(is_null, ~ NA_character_) %>%
  map_chr(str_c, collapse = ", ")

.endpoints$response <- .endpoints$response %>%
  map_chr("$ref", .null = NA_character_)
.endpoints$request <- .endpoints$request %>%
  map_chr("$ref", .null = NA_character_)
#View(.endpoints)

out_fname <- str_replace(
  json_fname,
  "discovery-document.json",
  "endpoints.rds")
saveRDS(.endpoints, file = out_fname)

use_data(.endpoints, internal = TRUE, overwrite = TRUE)
