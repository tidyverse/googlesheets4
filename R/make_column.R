make_column <- function(df, shortcode, ..., nr) {
  parsed <- parse(df$cell, shortcode, ...)
  if (is.null(parsed)) {
    return()
  }
  column <- switch(
    shortcode,
    ## TODO: do I need to set timezone in any of these?
    `T` = rep(NA, length.out = nr) %>% as.POSIXct(),
    D   = rep(NA, length.out = nr) %>% as.Date(),
    ## TODO: time of day not implemented yet
    t   = rep(NA, length.out = nr) %>% as.POSIXct(),
    vector(mode = typeof(parsed), length = nr)
  )
  column[df$row] <- parsed
  column
}

parse <- function(x, shortcode, ...) {
  stopifnot(is.character(shortcode))
  parse_fun <- switch(
    shortcode,
    `-` =,          ## I've tried to eliminate '-' internally but still ...
    `_` = as_skip,  ## also, skipped cols are not normally parsed but still ...
    l   = as_logical,
    i   = as_integer,
    d   = ,
    n   = as_double,
    T   = as_datetime,
    D   = as_date,
    t   = as_time,
    c   = as_character,
    C   = as_cell,
    L   = as_list,
    `?` = as_guess,
    ## TODO: factor, duration
    stop_glue("Not a recognized shortcode: {sq(shortcode)}")
  )
  if (inherits(x, "SHEETS_CELL")) {
    x <- list(x)
  }
  parse_fun(x, ...)
}

as_skip <- function(cell, ...) NULL
as_cell <- function(cell, ...) cell

as_list <- function(cell, ...) {
  codes <- cell %>%
    map_chr(~ class(.x)[[1]]) %>%
    guess_col_type() %>%
    get_shortcode()
  map2(cell, codes, parse, ...)
}

as_guess <- function(cell, ...) {
  code <- cell %>%
    map_chr(~ class(.x)[[1]]) %>%
    consensus_col_type() %>%
    get_shortcode()
  parse(cell, code, ...)
}

## prepare to coerce to logical, integer, double
cell_content <- function(cell, na = "", trim_ws = TRUE) {
  cls <- class(cell)[1]
  switch(
    cls,
    CELL_BLANK = NA,
    CELL_LOGICAL = pluck(cell, "effectiveValue", "boolValue"),
    CELL_NUMERIC = pluck(cell, "effectiveValue", "numberValue"),
    CELL_DATE = NA_real_,
    CELL_TIME = NA_real_,
    CELL_DATETIME = NA_real_,
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
    CELL_DATE = pluck(cell, "effectiveValue", "numberValue"),
    CELL_TIME = pluck(cell, "effectiveValue", "numberValue"),
    CELL_DATETIME = pluck(cell, "effectiveValue", "numberValue"),
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
    as.Date(origin = "1899-12-30", tz = "UTC")
}

## TODO: not wired up yet (body is same as as_datetime)
as_time <- function(cell, na = "", trim_ws = TRUE) {
  cell %>%
    map(cell_content_datetime, na = na, trim_ws = trim_ws) %>%
    map_dbl(as.double) %>%
    `*`(24 * 60 * 60) %>%
    as.POSIXct(origin = "1899-12-30", tz = "UTC")
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
