make_column <- function(df, ctype, ..., nr, guess_max = min(1000, nr)) {
  ## must resolve COL_GUESS here (vs when parsing) because need to know ctype
  ## here, when making the column
  ctype <- resolve_col_type(df$cell[df$row <= guess_max], ctype)
  parsed <- gs4_parse(df$cell, ctype, ...)
  if (is.null(parsed)) {
    return()
  }
  fodder <- rep_len(NA, length.out = nr)
  column <- switch(ctype,
    ## NAs must be numeric in order to initialize datetimes with a timezone
    CELL_DATE     = as_Date(as.numeric(fodder)),
    ## TODO: time of day not really implemented yet
    CELL_TIME     = as_POSIXct(as.numeric(fodder)),
    CELL_DATETIME = as_POSIXct(as.numeric(fodder)),
    COL_LIST = vector(mode = "list", length = nr),
    as.vector(fodder, mode = typeof(parsed))
  )
  if (ctype == "CELL_TEXT") {
    dots <- list2(...)
    column <- enforce_na(column, na = dots$na)
  }
  column[df$row] <- parsed
  column
}

resolve_col_type <- function(cell, ctype = "COL_GUESS") {
  if (ctype != "COL_GUESS") {
    return(ctype)
  }
  cell %>%
    ctype() %>%
    effective_cell_type() %>%
    consensus_col_type()
}

gs4_parse <- function(x, ctype, ...) {
  stopifnot(is_string(ctype))
  parse_fun <- switch(ctype,
    COL_SKIP      = as_skip,
    CELL_LOGICAL  = as_logical,
    CELL_INTEGER  = as_integer,
    CELL_NUMERIC  = as_double,
    CELL_DATE     = as_date,
    # TODO: CELL_TIME not really implemented yet
    CELL_TIME     = as_datetime,
    CELL_DATETIME = as_datetime,
    CELL_TEXT     = as_character,
    COL_CELL      = as_cell,
    COL_LIST      = as_list,
    ## TODO: factor, duration
    gs4_abort(
      "Not a recognized column type: {.field {ctype}}",
      .internal = TRUE
    )
  )
  if (inherits(x, "SHEETS_CELL")) {
    x <- list(x)
  }
  parse_fun(x, ...)
}

as_skip <- function(cell, ...) NULL
as_cell <- function(cell, ...) cell

as_list <- function(cell, ...) {
  ctypes <- cell %>%
    ctype() %>%
    effective_cell_type() %>%
    blank_to_logical()
  map2(cell, ctypes, gs4_parse, ...)
}

## prepare to coerce to logical, integer, double
cell_content <- function(cell, na = "", trim_ws = TRUE) {
  switch(ctype(cell),
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
  switch(ctype(cell),
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
    map_dbl(`*`, 24 * 60 * 60) %>%
    as_POSIXct()
}

as_date <- function(cell, na = "", trim_ws = TRUE) {
  cell %>%
    map(cell_content_datetime, na = na, trim_ws = trim_ws) %>%
    map_dbl(as.double) %>%
    as_Date()
}

## TODO: not wired up yet (body is same as as_datetime)
# as_time <- function(cell, na = "", trim_ws = TRUE) {
#   cell %>%
#     map(cell_content_datetime, na = na, trim_ws = trim_ws) %>%
#     map_dbl(as.double) %>%
#     `*`(24 * 60 * 60) %>%
#     as_POSIXct()
# }


## prepare to coerce to character
cell_content_chr <- function(cell, na = "", trim_ws = TRUE) {
  fv <- pluck(cell, "formattedValue", .default = NA_character_)
  groom_text(fv, na = na, trim_ws = trim_ws)
}

as_character <- function(cell, na = "", trim_ws = TRUE) {
  cell %>%
    map(cell_content_chr, na = na, trim_ws = trim_ws) %>%
    map_chr(as.character)
}

as_Date <- function(x = NA_real_, origin = "1899-12-30", tz = "UTC", ...) {
  as.Date(x, origin = origin, tz = tz, ...)
}

as_POSIXct <- function(x = NA_real_, origin = "1899-12-30", tz = "UTC", ...) {
  as.POSIXct(x, origin = origin, tz = tz, ...)
}
