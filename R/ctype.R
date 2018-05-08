## ctype = cell or column type
## most types are valid for a cell or a column
## however, a couple are valid only for cells or only for a column

##                       Type can be   Type can be  Type can be
## shortcode             discovered    guessed for  imposed on
##    = ctype            from a cell   a column     a column
.ctypes <- c(
  `_` = "COL_SKIP",      # --          no           yes
  `-` = "COL_SKIP",
        "CELL_BLANK",    # yes         no           no
  l   = "CELL_LOGICAL",  # yes         yes          yes
  i   = "CELL_INTEGER",  # no          no           yes
  d   = "CELL_NUMERIC",  # yes         yes          yes
  n   = "CELL_NUMERIC",  #
  D   = "CELL_DATE",     # yes         no           yes
  t   = "CELL_TIME",     # yes         no           yes
  `T` = "CELL_DATETIME", # yes         yes          yes
  c   = "CELL_TEXT",     # yes         yes          yes
  C   = "COL_CELL",      # --          no           yes
  L   = "COL_LIST",      # --          yes          yes
  `?` = "COL_GUESS"      # --          --           --
)

## TODO: add to above:
## CELL_DURATION
## COL_FACTOR

ctype <- function(x,  ...) {
  UseMethod("ctype")
}

ctype.NULL <- function(x, ...) stop_glue("Cannot turn `NULL` into `ctype`.")

ctype.SHEETS_CELL <- function(x, ...) class(x)[[1]]

ctype.character <- function(x, ...) .ctypes[x]

ctype.list <- function(x, ...) {
  out <- rlang::rep_along(x, NA_character_)
  is_SHEETS_CELL <- map_lgl(x, inherits, what = "SHEETS_CELL")
  out[is_SHEETS_CELL] <- map_chr(x[is_SHEETS_CELL], ctype)
  out
}

ctype.default <- function(x, ...) {
  stop_glue_data(
    list(x = glue_collapse(class(x), sep = "/")),
    "Don't know how to coerce object of class {sq(x)} to ctype"
  )
}

.cell_to_col_types <- c(
  ## If discovered   Then guessed
  ## cell type is:   col type is:
  CELL_BLANK       = "CELL_LOGICAL",
  CELL_LOGICAL     = "CELL_LOGICAL",
  CELL_INTEGER     = "CELL_NUMERIC",
  CELL_NUMERIC     = "CELL_NUMERIC",
  CELL_DATE        = "CELL_DATETIME",
  CELL_TIME        = "CELL_DATETIME",
  CELL_DATETIME    = "CELL_DATETIME",
  CELL_TEXT        = "CELL_TEXT"
)

## input:  discover-able cell type
## output: guess-able col type
## Where needed? Col type guessing when col type = COL_GUESS = "?", cell
## conversion when col type = COL_LIST = "L"
guess_col_type <- function(ctype) .cell_to_col_types[ctype]

##  input: vector of two ctypes
## output: one ctype
## c(X, X) --> X
## c(X, Y) --> "COL_LIST" with one exception:
## c("CELL_LOGICAL", "CELL_NUMERIC") --> "CELL_NUMERIC"
## CELL_BLANK is useful internally, but this is conceived to work
## on inputs that are *column* types, not *cell* types
consensus_col_type <- function(ctype) {
  g <- function(x, y) {
    if (setequal(c(x, y), c("CELL_LOGICAL", "CELL_NUMERIC"))) {
      return("CELL_NUMERIC")
    }

    if (x == y) {
      return(x)
    }

    blank <- match("CELL_BLANK", c(x, y))
    if (!is.na(blank)) {
      return(c(x, y)[-blank])
    }
    "COL_LIST"
  }

  out <- Reduce(g, ctype, init = "CELL_BLANK")
  if (out == "CELL_BLANK") {
    "CELL_LOGICAL"
  } else {
    out
  }
}

## input: an instance of CellData
## https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#CellData
## returns same, but applies a class vector:
##   [1] one of the CELL_* above, inspired by the CellType enum in readxl
##   [2] SHEETS_CELL
apply_ctype <- function(cell_list, na = "", trim_ws = TRUE) {
  ctypes <- map_chr(cell_list, infer_ctype, na = na, trim_ws = trim_ws)
  map2(cell_list, ctypes, ~ structure(.x, class = c(.y, "SHEETS_CELL")))
}

infer_ctype <- function(cell, na = "", trim_ws = TRUE) {
  ## Blank cell criteria
  ##   * cell is NULL or list()
  ##   * cell has no effectiveValue
  ##   * formattedValue matches an `na` string
  if ( length(cell) == 0 ||
       is.null(cell[["effectiveValue"]]) ||
       is_na_string(cell[["formattedValue"]], na = na, trim_ws = trim_ws)
  ) {
    return("CELL_BLANK")
  }

  effective_type <- .extended_value[[names(cell[["effectiveValue"]])]]

  if (effective_type == "error") {
    return("CELL_BLANK")
  }

  if (effective_type == "formula") {
    warning_glue("Cell has formula as effectiveValue. I thought impossible!")
    return("CELL_TEXT")
  }

  if (effective_type != "number") {
    return(switch(
      effective_type,
      string = "CELL_TEXT",
      boolean = "CELL_LOGICAL",
      stop_glue("Unhandled effective_type: {sq(effective_type)}")
    ))
  }
  ## only numeric cells remain

  nf_type <- pluck(
    cell,
    "effectiveFormat", "numberFormat", "type",
    ## in theory, should consult hosting spreadsheet for a default format
    ## if that's absent, should consult locale (of spreadsheet? user? unclear)
    ## for now, I punt on this
    .default = "NUMBER"
  )
  .number_types[[nf_type]]
}

## userEnteredValue and effectiveValue hold an instance of ExtendedValue
## https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#ExtendedValue
# {
#   // Union field value can be only one of the following:
#   "numberValue": number,
#   "stringValue": string,
#   "boolValue": boolean,
#   "formulaValue": string,
#   "errorValue": {
#     object(ErrorValue)
#   },
#   // End of list of possible types for union field value.
# }
.extended_value <- c(
   numberValue = "number",
   stringValue = "string",
     boolValue = "boolean",
  formulaValue = "formula",  # hypothesis: this is impossible in effectiveValue
    errorValue = "error"
)

.number_types <- c(
  TEXT       = "CELL_NUMERIC",
  NUMBER     = "CELL_NUMERIC",
  PERCENT    = "CELL_NUMERIC",
  CURRENCY   = "CELL_NUMERIC",
  SCIENTIFIC = "CELL_NUMERIC",
  ## on the R side, all of the above are treated as numeric
  ## no current reason to distinguish them, for col type guessing or coercion
  DATE       = "CELL_DATE",
  TIME       = "CELL_TIME",
  DATE_TIME  = "CELL_DATETIME"
)

is_na_string <- function(x, na = "", trim_ws = TRUE) {
  fv <- if (trim_ws) ws_trim(x) else x
  any(fv == na)
}
