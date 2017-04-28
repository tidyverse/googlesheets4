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
nms_pos <- nms_list %>%
  ## I don't really want column binding but have little choice today
  map_dfc(~ match(nms_glop, .x)) %>%
  add_column(nms = nms_glop, .before = 1) %>%
  add_column(rk_sum = rowSums(.[ , -1], na.rm = TRUE), .before = 1) %>%
  arrange(rk_sum)
nms <- nms_pos$nms

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
df <- nms %>%
  map(~ map(endpoints, .x)) %>%
  modify_if(can_be_atomic, atomicate) %>%
  set_names(nms) %>%
  as_tibble()
#View(df)

## more processing is needed :(

## these look identical, are they?
identical(df$path, df$flatPath)
## drop flatPath
df$flatPath <- NULL

## consensus order from above is pretty lame, actually
df <- df %>%
  select(id, httpMethod, path, parameters, scopes, description, everything())

df$scopes <- df$scopes %>%
  map(~ gsub("https://www.googleapis.com/auth/", "", .)) %>%
  map_chr(str_c, collapse = ", ")

df$parameterOrder <- df$parameterOrder %>%
  modify_if(is_null, ~ NA_character_) %>%
  map_chr(str_c, collapse = ", ")

df$response <- df$response %>%
  map_chr("$ref", .null = NA_character_)
df$request <- df$request %>%
  map_chr("$ref", .null = NA_character_)
#View(df)

out_fname <- str_replace(
  json_fname,
  "discovery-document.json",
  "endpoints.rds")
saveRDS(df, file = out_fname)

