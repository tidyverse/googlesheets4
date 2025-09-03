# ctype = cell or column type
# most types are valid for a cell or a column
# however, a couple are valid only for cells or only for a column

#                       Type can be   Type can be  Type can be
# shortcode             discovered    guessed for  imposed on
#    = ctype            from a cell   a column     a column
# fmt: skip
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

# TODO: add to above:
# CELL_DURATION
# COL_FACTOR

# this generic is "dumb": it only reports ctype
# it doesn't implement any logic about guessing, coercion, etc.
ctype <- function(x, ...) {
  UseMethod("ctype")
}

#' @export
ctype.NULL <- function(x, ...) {
  abort_unsupported_conversion(x, to = "ctype")
}

#' @export
ctype.SHEETS_CELL <- function(x, ...) {
  out <- class(x)[[1]]
  if (out %in% .ctypes) {
    out
  } else {
    NA_character_
  }
}

#' @export
ctype.character <- function(x, ...) .ctypes[x]

#' @export
ctype.list <- function(x, ...) {
  out <- rep_along(x, NA_character_)
  is_SHEETS_CELL <- map_lgl(x, inherits, what = "SHEETS_CELL")
  out[is_SHEETS_CELL] <- map_chr(x[is_SHEETS_CELL], ctype)
  out
}

#' @export
ctype.default <- function(x, ...) {
  abort_unsupported_conversion(x, to = "ctype")
}

# fmt: skip
.discovered_to_effective_type <- c(
  # If discovered   Then effective
  # cell type is:   cell type is:
  CELL_BLANK       = "CELL_BLANK",
  CELL_LOGICAL     = "CELL_LOGICAL",
  CELL_INTEGER     = "CELL_NUMERIC",  ## integers are jsonlite being helpful
  CELL_NUMERIC     = "CELL_NUMERIC",
  CELL_DATE        = "CELL_DATETIME", ## "date" is just a format in Sheets
  CELL_TIME        = "CELL_DATETIME", ## "time" is just a format in Sheets
  CELL_DATETIME    = "CELL_DATETIME",
  CELL_TEXT        = "CELL_TEXT"
)

# input:  cell type, presumably discovered
# output: effective cell type
#
# Where do we use this?
#   * To choose cell-specific parser when col type is COL_LIST == "L"
#   * Pre-processing cell types prior to forming a consensus for an entire
#     column when col type is COL_GUESS = "?"
# This is the where we store type-guessing fiddliness that is specific to
# Google Sheets.
effective_cell_type <- function(ctype) .discovered_to_effective_type[ctype]

# input:  a ctype
# output: vector of ctypes that can hold such input with no data loss, going
#         from most generic (list) to most specific (type of that cell)
# examples:
# CELL_LOGICAL --> COL_LIST, CELL_NUMERIC, CELL_INTEGER, CELL_LOGICAL
# CELL_DATE --> COL_LIST, CELL_DATETIME, CELL_DATE
# CELL_BLANK --> NULL
# fmt: skip
admissible_types <- function(x) {
  z <- c(
    CELL_LOGICAL  = "CELL_INTEGER",
    CELL_INTEGER  = "CELL_NUMERIC",
    CELL_NUMERIC  = "COL_LIST",

    CELL_DATE     = "CELL_DATETIME",
    CELL_DATETIME = "COL_LIST",

    CELL_TIME     = "COL_LIST",

    CELL_TEXT     = "COL_LIST"
  )
  if (x[[1]] == "COL_LIST") {
    return(x)
  }
  if (!x[[1]] %in% names(z)) {
    return()
  }
  c(admissible_types(z[[x[[1]]]]), x)
}

# find the most specific ctype that is admissible for a pair of ctypes
# the limiting case is COL_LIST
# HOWEVER use ctypes that are good for cells, i.e. "two blanks make a blank"
upper_type <- function(x, y) {
  upper_bound(admissible_types(x), admissible_types(y)) %||% "CELL_BLANK"
}

# find the most specific ctype that is admissible for a set of ctypes
# HOWEVER use ctypes that are good for columns, i.e. "two blanks make a
# logical"
consensus_col_type <- function(ctype) {
  out <- Reduce(upper_type, unique(ctype), init = "CELL_BLANK")
  blank_to_logical(out)
}

blank_to_logical <- function(ctype) {
  modify_if(ctype, ~ identical(.x, "CELL_BLANK"), ~"CELL_LOGICAL")
}

# input: an instance of CellData
# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#CellData
# returns same, but applies a class vector:
#   [1] a ctype, inspired by the CellType enum in readxl
#   [2] SHEETS_CELL
apply_ctype <- function(cell_list, na = "", trim_ws = TRUE) {
  ctypes <- map_chr(cell_list, infer_ctype, na = na, trim_ws = trim_ws)
  map2(cell_list, ctypes, ~ structure(.x, class = c(.y, "SHEETS_CELL")))
}

infer_ctype <- function(cell, na = "", trim_ws = TRUE) {
  # Blank cell criteria
  #   * cell is NULL or list()
  #   * cell has no effectiveValue
  #   * formattedValue matches an `na` string
  if (
    length(cell) == 0 ||
      length(cell[["effectiveValue"]]) == 0 ||
      is_na_string(cell[["formattedValue"]], na = na, trim_ws = trim_ws)
  ) {
    return("CELL_BLANK")
  }

  effective_type <- .extended_value[[names(cell[["effectiveValue"]])]]

  if (!identical(effective_type, "number")) {
    return(switch(
      effective_type,
      error = "CELL_BLANK",
      string = "CELL_TEXT",
      boolean = "CELL_LOGICAL",
      formula = {
        cli::cli_warn(
          "
          Internal warning from googlesheets4: \\
          Cell has formula as effectiveValue. \\
          I thought this was impossible!"
        )
        "CELL_TEXT"
      },
      gs4_abort(
        "Unhandled effective_type: {.field {effective_type}}",
        .internal = TRUE
      )
    ))
  }
  # only numeric cells remain

  nf_type <- pluck(
    cell,
    "effectiveFormat",
    "numberFormat",
    "type",
    # in theory, should consult hosting spreadsheet for a default format
    # if that's absent, should consult locale (of spreadsheet? user? unclear)
    # for now, I punt on this
    .default = "NUMBER"
  )
  .number_types[[nf_type]]
}

# userEnteredValue and effectiveValue hold an instance of ExtendedValue
# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#ExtendedValue
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
# fmt: skip
.extended_value <- c(
   numberValue = "number",
   stringValue = "string",
     boolValue = "boolean",
  formulaValue = "formula",  # hypothesis: this is impossible in effectiveValue
    errorValue = "error"
)

# fmt: skip
.number_types <- c(
  TEXT       = "CELL_NUMERIC",
  NUMBER     = "CELL_NUMERIC",
  PERCENT    = "CELL_NUMERIC",
  CURRENCY   = "CELL_NUMERIC",
  SCIENTIFIC = "CELL_NUMERIC",
  # on the R side, all of the above are treated as numeric
  # no current reason to distinguish them, for col type guessing or coercion
  DATE       = "CELL_DATE",
  TIME       = "CELL_TIME",
  DATE_TIME  = "CELL_DATETIME"
)

is_na_string <- function(x, na = "", trim_ws = TRUE) {
  if (length(na) == 0) {
    return(FALSE)
  }
  fv <- if (trim_ws) ws_trim(x) else x
  any(fv == na)
}

# compares x[i] to y[i] and returns the last element where they are equal
# example:
# upper_bound(c("a", "b"), c("a", "b", "c")) is "b"
upper_bound <- function(x, y) {
  nx <- length(x)
  ny <- length(y)
  # these brackets make covr happy
  if (nx + ny == 0) {
    return()
  }
  if (nx == 0) {
    return(y[[ny]])
  }
  if (ny == 0) {
    return(x[[nx]])
  }
  comp <- seq_len(min(nx, ny))
  # TODO: if our DAG were more complicated, I think this would need to be
  # based on a set operation
  res <- x[comp] == y[comp]
  if (!any(res)) {
    return()
  }
  x[[max(which(res))]]
}
