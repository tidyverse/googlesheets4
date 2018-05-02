## input: an instance of CellData
## https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#CellData
## returns same, but adds one of the following as a class, inspired by
## CellType enum in readxl
##   * CELL_BLANK
##   * CELL_LOGICAL
##   * CELL_NUMERIC.XXX
##   * CELL_TEXT
apply_type <- function(cell, na = "", trim_ws = TRUE) {
  map(cell, ~ structure(
    .x,
    class = c(infer_type(.x, na = na, trim_ws = trim_ws), class(.x))
  ))
}

infer_type <- function(cell, na = "", trim_ws = TRUE) {
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

  effective_type <- extended_value[[names(cell[["effectiveValue"]])]]

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
  number_types[[nf_type]]
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
extended_value <- c(
   numberValue = "number",
   stringValue = "string",
     boolValue = "boolean",
  formulaValue = "formula",  # hypothesis: this is impossible in effectiveValue
    errorValue = "error"
)

number_types <- c(
        TEXT = "CELL_NUMERIC",
      NUMBER = "CELL_NUMERIC",
     PERCENT = "CELL_NUMERIC",
    CURRENCY = "CELL_NUMERIC",
  SCIENTIFIC = "CELL_NUMERIC",
  ## on the R side, at this time, all of the above will be treated as numeric
  ## no current reason to distinguish them, for col type guessing or coercion
        DATE = "CELL_NUMERIC.DATE",
        TIME = "CELL_NUMERIC.TIME",
   DATE_TIME = "CELL_NUMERIC.DATE_TIME"
  ## it IS conceivable that we have use of these distincions ... keep for now
)

is_na_string <- function(x, na = "", trim_ws = TRUE) {
  fv <- if (trim_ws) ws_trim(x) else x
  any(fv == na)
}
