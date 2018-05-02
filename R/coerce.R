parse <- function(x, shortcode, ...) {
  stopifnot(is.character(shortcode))
  parse_fun <- switch(
    shortcode,
    `-` =,
    `_` = as_skip,
    `?` = as_is,
    l = as_logical,
    i = as_integer,
    d = ,
    n = as_double,
    c = as_character,
    T = as_datetime,
    D = as_date,
    t = as_time,
    ## TODO: as_factor
    stop_glue("Not a recognized shortcode: {sq(shortcode)}")
  )
  parse_fun(x$cell, ...)
}

## TODO: WRONG this column should not exist in the result, it shouldn't just be
## filled with NAs
as_skip <- function(cell, ...) purrr::rep_along(cell, NA)

## TO DO: actually make each atom what it should be
as_is <- function(cell, ...) cell

## prepare to coerce to logical, integer, double
cell_content <- function(cell, na = "", trim_ws = TRUE) {
  cls <- class(cell)[1]
  switch(
    cls,
    CELL_BLANK = NA,
    CELL_LOGICAL = pluck(cell, "effectiveValue", "boolValue"),
    CELL_NUMERIC = pluck(cell, "effectiveValue", "numberValue"),
    CELL_NUMERIC.DATE = NA_real_,
    CELL_NUMERIC.TIME = NA_real_,
    CELL_NUMERIC.DATE_TIME = NA_real_,
    CELL_TEXT = cell %>%
      pluck("effectiveValue", "stringValue") %>%
      groom_text(na = na, trim_ws = trim_ws)
  )
}

as_logical <- function(cell, na = "", trim_ws = TRUE) {
  cell %>%
    map(cell_content, na = na, trim_ws = trim_ws) %>%
    map_lgl(as.logical)
}

as_integer <- function(cell, na = "", trim_ws = TRUE) {
  cell %>%
    map(cell_content, na = na, trim_ws = trim_ws) %>%
    map_int(as.integer)
}

as_double <- function(cell, na = "", trim_ws = TRUE) {
  cell %>%
    map(cell_content, na = na, trim_ws = trim_ws) %>%
    map_dbl(as.double)
}

## prepare to coerce to date, time, datetime
cell_content_datetime <- function(cell, na = "", trim_ws = TRUE) {
  cls <- class(cell)[1]
  switch(
    cls,
    CELL_BLANK = NA,
    CELL_LOGICAL = NA,
    CELL_NUMERIC = NA,
    CELL_NUMERIC.DATE = pluck(cell, "effectiveValue", "numberValue"),
    CELL_NUMERIC.TIME = pluck(cell, "effectiveValue", "numberValue"),
    CELL_NUMERIC.DATE_TIME = pluck(cell, "effectiveValue", "numberValue"),
    CELL_TEXT = NA
  )
}

as_datetime <- function(cell, na = "", trim_ws = TRUE) {
  cell %>%
    map(cell_content_datetime, na = na, trim_ws = trim_ws) %>%
    map_dbl(as.double) %>%
    `*`(24 * 60 * 60) %>%
    as.POSIXct(origin = "1899-12-30", tz = "UTC")
}

as_date <- function(cell, na = "", trim_ws = TRUE) {
  cell %>%
    map(cell_content_datetime, na = na, trim_ws = trim_ws) %>%
    map_dbl(as.double) %>%
    as.Date(origin = "1899-12-30")
}

## TODO: not wired up yet (body is same as as_datetime)
as_time <- function(cell, na = "", trim_ws = TRUE) {
  cell %>%
    map(cell_content_datetime, na = na, trim_ws = trim_ws) %>%
    map_dbl(as.double) %>%
    `*`(24 * 60 * 60) %>%
    as.POSIXct(origin = "1899-12-30", tz = "GMT")
}


## prepare to coerce to character
cell_content_chr <- function(cell, na = "", trim_ws = TRUE) {
  cls <- class(cell)[1]
  switch(
    cls,
    CELL_BLANK = NA_character_,
    pluck(cell, "formattedValue")
  ) %>%
    groom_text(na = na, trim_ws = trim_ws)
}

as_character <- function(cell, na = "", trim_ws = TRUE) {
  cell %>%
    map(cell_content_chr, na = na, trim_ws = trim_ws) %>%
    map_chr(as.character)
}
