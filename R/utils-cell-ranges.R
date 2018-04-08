## A pair of functions for the (un)escaping of spreadsheet names
## for use in range strings like Sheet1!A2:D4
sq_escape <- function(x) {
  ## if string already starts and ends with single quote, pass it through
  is_not_quoted <- !map_lgl(x, ~ grepl("^'.*'$", .x))
  purrr::modify_if(
    x,
    is_not_quoted,
    ## duplicate each single quote and protect string with single quotes
    ~ paste0("'", gsub("'", "''", .x), "'")
  )
}

sq_unescape <- function(x) {
  ## only modify if string starts and ends with single quote
  is_quoted <- map_lgl(x, ~ grepl("^'.*'$", .x))
  purrr::modify_if(
    x,
    is_quoted,
    ## strip leading and trailing single quote and substitute 1 single quote
    ## for every pair of single quotes
    ~ gsub("''", "'", sub("^'(.*)'$", "\\1", .x))
  )
}

make_range <- function(start_row, end_row, start_column, end_column,
                       sheet_name, ...) {
  cl <- cellranger::cell_limits(
    ul = c(start_row, start_column),
    lr = c(end_row, end_column),
    sheet = sq(sheet_name)
  )
  cellranger::as.range(cl, fo = "A1")
}
