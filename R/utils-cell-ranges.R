## input: sheet, range, and skip from the user
##        + data frame of sheet metadata
## output: list with components
##   * sheet: sheet name, e.g. "Sheet1"
##   * cell_range: cell range, e.g. "A2:D4", "C:E", "2:5"
##   * api_range: full range string to send to API, e.g. "'Sheet1'!A2:D4"
##   * shim: logical indicating whether user provided input via `range`
##   * cell_limits: cell_limits object reflecting user's `range`
## difference between cell_limits and sheet + cell_range = api_range:
##   * cell_limits is a direct representation of user input for `range`
##   * api_range is always qualified with a sheet name
##   * cell_range may have had unspecified max's populated with sheet extent
form_range_spec <- function(sheet = NULL,
                            range = NULL,
                            skip = 0,
                            sheet_df = NULL) {
  shim <- !is.null(range)

  if (is.null(range)) {
    cell_limits <- cellranger::cell_limits()
    api_limits <- cellranger::cell_rows(c(if (skip > 0) skip + 1 else NA, NA))
  }

  ## ideally, this would call cellranger::as.cell_limits.character()
  ## but it cannot handle ranges like A:A or A5:A (yet?)
  if (is.character(range)) {
    cell_limits <- api_limits <- as_cell_limits(range)
  }

  if (inherits(range, what = "cell_limits")) {
    cell_limits <- api_limits <- range
  }

  sheet <- api_limits$sheet %NA% sheet %||% 1L
  sheet <- resolve_sheet(sheet, sheet_df)

  sheet_extent <- sheet_df[
    sheet_df$name == sheet,
    c("grid_rows", "grid_columns"),
    drop = TRUE
    ]
  api_limits  <- resolve_limits(api_limits, sheet_extent)

  rg <- as_sheets_range(api_limits)

  list(
    sheet = sheet,
    cell_range = rg,
    api_range = paste0(c(sq_escape(sheet), rg), collapse = "!"),
    shim = shim,
    cell_limits = cell_limits
  )
}

A1_char_class <- "[a-zA-Z0-9:$]"
compound_rx <- glue("(?<sheet>^.+)!(?<range>{A1_char_class}+$)")
letter_part <- "[$]?[A-Za-z]{1,3}"
number_part <- "[$]?[0-9]{1,7}"
A1_rx <- glue("^{letter_part}{number_part}$|^{letter_part}$|^{number_part}$")
A1_decomp <- glue("(?<column>{letter_part})?(?<row>{number_part})?")

## Note: this function is NOT vectorized, x is scalar
as_cell_limits <- function(x) {
  check_character(x)
  check_length_one(x)
  ## match against <sheet name>!<A1 cell reference or range>?
  parsed <- rematch2::re_match(x, compound_rx)

  ## successful match (and parse)
  if (notNA(parsed$`.match`)) {
    cell_limits <- limits_from_range(parsed$range)
    cell_limits$sheet <- parsed$sheet
    return(cell_limits)
  }

  ## failed to match
  ## two possibilities:
  ##   * An A1 cell reference or range
  ##   * Name of a sheet or named region
  if (all(grepl(A1_rx, strsplit(x, split = ":")[[1]]))) {
    limits_from_range(x)
  } else {
    ## TO THINK: I am questioning if this should even be allowed
    ## perhaps you MUST use sheet argument for this, not range?
    ## to be clear: we're talking about passing a sheet name or name of a
    ## named range, without a '!A1:C4' type of range as suffix
    cell_limits(sheet = x)
  }
  ## TODO: above is still not sophisticated enough to detect that
  ## A, AA, AAA (strings of length less than 4) and
  ## 1, 12, ..., 1234567 (numbers with less than 8 digits)
  ## are not, I believe, valid ranges
}

limits_from_range <- function(x) {
  x_split <- strsplit(x, ":")[[1]]
  if (!length(x_split) %in% 1:2)   {stop_glue("Invalid range: {sq(x)}")}
  if (!all(grepl(A1_rx, x_split))) {stop_glue("Invalid range: {sq(x)}")}
  corners <- rematch2::re_match(x_split, A1_decomp)
  if (any(is.na(corners$.match)))  {stop_glue("Invalid range: {sq(x)}")}
  corners$column <- ifelse(nzchar(corners$column), corners$column, NA_character_)
  corners$row <- ifelse(nzchar(corners$row), corners$row, NA_character_)
  if (nrow(corners) == 1) {
    corners <- corners[c(1, 1), ]
  }
  cellranger::cell_limits(
    ul = c(
      corners$row[1] %NA% NA_integer_,
      cellranger::letter_to_num(corners$column[1]) %NA% NA_integer_
    ),
    lr = c(
      corners$row[2] %NA% NA_integer_,
      cellranger::letter_to_num(corners$column[2]) %NA% NA_integer_
    )
  )
}

## sheet_df can be NULL iff is.character(sheet)
## otherwise --> error
## minimal sheet_df that works: tibble(name = "a", visible = TRUE)
resolve_sheet <- function(sheet = NULL, sheet_df = NULL) {
  check_sheet(sheet)
  sheet <- sheet %||% 1L
  if (is.character(sheet)) return(sheet)

  if (is.null(sheet_df)) {
    stop_glue(
      "Need to look up the name of sheet in position {sheet}, but no sheet ",
      "metadata was provided via {bt('sheet_df')}."
    )
  }

  visible_sheets <- sheet_df$name[sheet_df$visible]
  if (length(visible_sheets) < 1) {
    stop_glue(
      "No sheets are visible, therefore you must ",
      "specify {bt('sheet')} explicitly and by name."
    )
  }
  sheet <- as.integer(sheet)
  if (!(sheet %in% seq_along(visible_sheets))) {
    stop_glue(
      "There are {length(visible_sheets)} visible sheets:\n",
      "  * Requested sheet number is {sheet}"
    )
  }
  visible_sheets[[sheet]]
}

check_sheet <- function(sheet = NULL) {
  if (is.null(sheet)) return()
  check_length_one(sheet)
  if (!is.character(sheet) && !is.numeric(sheet)) {
    stop_glue(
      "{bt('sheet')} must be either character (sheet name) or ",
      "numeric (sheet number):\n",
      "  * {bt('sheet')} has class {glue_collapse(class(sheet), sep = '/')}"
    )
  }
  return(sheet)
}

resolve_limits <- function(cell_limits, sheet_extent) {
  ## we must modify cell_limits that have this property:
  ## let X be in {row, column}
  ## if start_X is specified, then end_X cannot be NA
  ## NAs in that position must be replaced with the relevant maximum extent
  row_limits <- map_int(cell_limits[c("ul", "lr")], 1)
  col_limits <- map_int(cell_limits[c("ul", "lr")], 2)
  if (identical(is.na(row_limits), c(ul = FALSE, lr = TRUE))) {
    cell_limits$lr[1] <- as.integer(sheet_extent$grid_rows)
  }
  if (identical(is.na(col_limits), c(ul = FALSE, lr = TRUE))) {
    cell_limits$lr[2] <- as.integer(sheet_extent$grid_columns)
  }
  cell_limits
}

## shim around cellranger::as.range()
## I'm not sure if this is permanent or not?
## currently cellranger::as.range() does not tolerate any NAs
## but some valid Sheets ranges imply NAs in the cell limits
## hence, this function must exist for now
as_sheets_range <- function(x) {
  stopifnot(inherits(x, what = "cell_limits"))
  ## this is not our definitive source of sheet
  x$sheet <- NA_character_
  limits <- x[c("ul", "lr")]

  ## "case numbers" refer to output produced by:
  # tidyr::crossing(
  #   start_row = c(NA, "start_row"), start_col = c(NA, "start_col"),
  #   end_row = c(NA, "end_row"), end_col = c(NA, "end_col")
  # )

  ## end_row and end_col are specified --> lower right cell is fully specified
  #  1 start_row start_col end_row end_col
  #  5 start_row NA        end_row end_col
  #  9 NA        start_col end_row end_col
  # 13 NA        NA        end_row end_col
  if (noNA(limits$lr)) return(cellranger::as.range(x, fo = "A1"))

  ## start of special handling,
  ## cellranger::as.range() returns NA for everything below here, but that's
  ## not what I want

  ## nothing is specified
  # 16 NA        NA        NA      NA
  if (allNA(unlist(limits))) return(NULL)

  row_limits <- map_int(limits, 1)
  col_limits <- map_int(limits, 2)

  ## no cols specified, but end_row is
  #  6 start_row NA        end_row NA
  # 14 NA        NA        end_row NA
  if (allNA(col_limits) && notNA(row_limits[2])) {
    return(paste0(row_limits, collapse = ":"))
  }
  ## no rows specified, but end_col is
  # 11 NA        start_col NA      end_col
  # 15 NA        NA        NA      end_col
  if (allNA(row_limits) && noNA(col_limits)) {
    return(paste0(cellranger::num_to_letter(col_limits), collapse = ":"))
  }

  ## in all remaining scenarios, you can't produce a valid Sheets A1 reference
  ## without replacing one or more NAs with external knowledge re: Sheet extent
  ##
  ## in other words, it's too late to fix it here
  ## therefore, we pre-process cell limits through resolve_limits() to
  ## we never provide such input

  ## shared property of what's left:
  ## let X be in {row, column}
  ## start_X is specified, but end_X is NA

  #  2 start_row start_col end_row NA
  # 10 NA        start_col end_row NA
  #  3 start_row start_col NA      end_col
  #  7 start_row NA        NA      end_col
  #  4 start_row start_col NA      NA
  #  8 start_row NA        NA      NA
  # 12 NA        start_col NA      NA
  stop_glue("Can't express the specified {bt('range')} as an A1 reference")
}

check_range <- function(range = NULL) {
  if (is.null(range) ||
      inherits(range, what = "cell_limits") ||
      is_string(range)) return(range)
  stop_glue(
    "{bt('range')} must be NULL, a string, or a {bt('cell_limits')} object."
  )
}

## A pair of functions for the (un)escaping of spreadsheet names
## for use in range strings like 'Sheet1'!A2:D4
sq_escape <- function(x) {
  ## if string already starts and ends with single quote, pass it through
  is_not_quoted <- !map_lgl(x, ~ grepl("^'.*'$", .x))
  ## duplicate each single quote and protect string with single quotes
  x[is_not_quoted] <- paste0("'", gsub("'", "''", x[is_not_quoted]), "'")
  x
}

sq_unescape <- function(x) {
  ## only modify if string starts and ends with single quote
  is_quoted <- map_lgl(x, ~ grepl("^'.*'$", .x))
  ## strip leading and trailing single quote and substitute 1 single quote
  ## for every pair of single quotes
  x[is_quoted] <- gsub("''", "'", sub("^'(.*)'$", "\\1", x[is_quoted]))
  x
}

## the `...` are used to absorb extra variables when this is used inside pmap()
make_range <- function(start_row, end_row, start_column, end_column,
                       sheet_name, ...) {
  cl <- cellranger::cell_limits(
    ul = c(start_row, start_column),
    lr = c(end_row, end_column),
    sheet = sq(sheet_name)
  )
  cellranger::as.range(cl, fo = "A1")
}
