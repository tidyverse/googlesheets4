A1_char_class <- "[a-zA-Z0-9:$]"
compound_rx <- glue("(?<sheet>^.+)!(?<range>{A1_char_class}+$)")
letter_part <- "[$]?[A-Za-z]{1,3}"
number_part <- "[$]?[0-9]{1,7}"
A1_rx <- glue("^{letter_part}{number_part}$|^{letter_part}$|^{number_part}$")
A1_decomp <- glue("(?<column>{letter_part})?(?<row>{number_part})?")

resolve_sheet <- function(sheet = NULL, sheet_names = NULL) {
  if (is.null(sheet)) {
    return()
  }
  check_sheet(sheet)

  if (is.character(sheet)) {
    sheet <- sq_unescape(sheet)
    if (length(sheet_names) > 0) {
      m <- match(sheet, sheet_names)
      if (is.na(m)) {
        stop_glue("No sheet found with this name: {sq(sheet)}")
      }
    }
    return(sheet)
  }

  if (length(sheet_names) < 1) {
    stop_glue("Sheet specified by number, but no sheet names provided for lookup.")
  }
  m <- as.integer(sheet)
  if (!(m %in% seq_along(sheet_names))) {
    stop_glue(
      "There are {length(sheet_names)} sheet names:\n",
      "  * Requested sheet number is out-of-bounds: {m}"
    )
  }
  sheet_names[[m]]
}

check_sheet <- function(sheet = NULL) {
  if (is.null(sheet)) {
    return()
  }
  check_length_one(sheet)
  if (!is.character(sheet) && !is.numeric(sheet)) {
    stop_glue(
      "{bt('sheet')} must be either character (sheet name) or ",
      "numeric (sheet number):\n",
      "  * {bt('sheet')} has class {class_collapse(sheet)}"
    )
  }
  return(sheet)
}

qualified_A1 <- function(sheet_name = NULL, A1_range = NULL) {
  # API docs: "For simplicity, it is safe to always surround the sheet name
  # with single quotes."
  paste0(c(sq_escape(sheet_name), A1_range), collapse = "!")
}

# shim around cellranger::as.range()
# I'm not sure if this is permanent or not?
# currently cellranger::as.range() does not tolerate any NAs
# but some valid Sheets ranges imply NAs in the cell limits
# hence, this function must exist for now
as_sheets_range <- function(x) {
  stopifnot(inherits(x, what = "cell_limits"))
  # TODO: we don't show people providing sheet name via cell_limits
  #       so I proceed as if sheet is always specified elsewhere
  x$sheet <- NA_character_
  x <- resolve_limits(x)
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

  # in all remaining scenarios, you can't produce a valid Sheets A1 reference
  # without replacing one or more NAs with something specific
  #
  # these should all be eliminated via pre-processing with resolve_limits()
  #
  # shared property of what's left:
  # let X be in {row, column}
  # start_X is specified, but end_X is NA
  #
  #  2 start_row start_col end_row NA
  # 10 NA        start_col end_row NA
  #  3 start_row start_col NA      end_col
  #  7 start_row NA        NA      end_col
  #  4 start_row start_col NA      NA
  #  8 start_row NA        NA      NA
  # 12 NA        start_col NA      NA
  stop_glue("Can't express the specified {bt('range')} as an A1 reference")
}

# think of cell_limits like so:
# ul = upper left  |  lr = lower right
# -----------------+------------------
#      start_row              end_row
#      start_col              end_col
# if start is specified, then so must be the end
#
# here we replace end_row or end_col in such cases with an actual number
#
# if provided, sheet_data is a list with two named elements:
#   * `grid_rows` = max row extent
#   * `grid_columns` = max col extent
# probably obtained like so:
# df <- sheets_get()$sheets
# df[df$name == sheet, c("grid_rows", "grid_columns")]
resolve_limits <- function(cell_limits, sheet_data = NULL) {
  # If no sheet_data, use theoretical maxima.
  # Rows: Max number of cells is 5 million. So that must be the maximum
  #       number of rows (imagine a spreadsheet with 1 sheet and 1 column).
  # Columns: Max col is "ZZZ" = cellranger::letter_to_num("ZZZ") = 18278
  MAX_ROW <- sheet_data$grid_rows    %||% 5000000L
  MAX_COL <- sheet_data$grid_columns %||% 18278L

  limits <- c(cell_limits$ul, cell_limits$lr)
  n_NA <- sum(is.na(limits))
  if (n_NA == 0 || n_NA == 4) {
    # rectangle is completely specified or completely unspecified
    return(cell_limits)
  }

  rlims <- function(cl) map_int(cl[c("ul", "lr")], 1)
  clims <- function(cl) map_int(cl[c("ul", "lr")], 2)

  # i:j, ?:j, i:?
  if (all(is.na(clims(cell_limits)))) {
    cell_limits$ul[1] <- cell_limits$ul[1] %NA% 1L
    cell_limits$lr[1] <- cell_limits$lr[1] %NA% MAX_ROW
    return(cell_limits)
  }

  # X:Y, ?:Y, X:?
  if (all(is.na(rlims(cell_limits)))) {
    cell_limits$ul[2] <- cell_limits$ul[2] %NA% 1L
    cell_limits$lr[2] <- cell_limits$lr[2] %NA% MAX_COL
    return(cell_limits)
  }

  # complete ul
  cell_limits$ul[1] <- cell_limits$ul[1] %NA% 1L
  cell_limits$ul[2] <- cell_limits$ul[2] %NA% 1L

  if (all(is.na(cell_limits$lr))) {
    # populate col of lr
    cell_limits$lr[2] <- cell_limits$lr[2] %NA% MAX_COL
  }

  cell_limits
}

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

check_range <- function(range = NULL) {
  if (is.null(range) ||
      inherits(range, what = "cell_limits") ||
      is_string(range)) return(range)
  stop_glue(
    "{bt('range')} must be NULL, a string, or a {bt('cell_limits')} object."
  )
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
