## A pair of functions for the (un)escaping of spreadsheet names
## for use in range strings like Sheet1!A2:D4
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

make_range <- function(start_row, end_row, start_column, end_column,
                       sheet_name, ...) {
  cl <- cellranger::cell_limits(
    ul = c(start_row, start_column),
    lr = c(end_row, end_column),
    sheet = sq(sheet_name)
  )
  cellranger::as.range(cl, fo = "A1")
}

standardise_range <- function(sheet = NULL, range = NULL, sheet_df = NULL) {
  if (is.null(range)) {
    sheet <- sheet %||% 1L
  } else {
    check_length_one(range)
    check_character(range)
    parsed <- parse_user_range(range)
    sheet <- parsed$sheet %||% sheet
    range <- parsed$range
  }

  if (!is.null(sheet)) {
    check_length_one(sheet)
    if (!is.character(sheet) && !is.numeric(sheet)) {
      stop_glue(
        "{bt('sheet')} must be either character (sheet name) or ",
        "numeric (sheet number):\n",
        "  * {bt('sheet')} has class {glue_collapse(class(sheet), sep = '/')}"
      )
    }
  }
  ## range guaranteed to be NULL or unqualified cell ref or range
  ## sheet guaranteed to be NULL, a number, or name of a sheet or named range
  ## at least one of (sheet, range) guaranteed to be non-NULL

  if (is.numeric(sheet) && is.null(sheet_df)) {
    if (is.null(range)) {
      ## we have nothing to send to the API as the range --> untenable
      stop_glue(
        "{bt('sheet')} specified by number in the absence of sheet data ",
        "or a range."
      )
    }
    warning_glue(
      "{bt('sheet')} specified by number in the absence of sheet data. ",
      "Ignoring."
    )
    sheet <- NULL
  }

  if (is.numeric(sheet)) {
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
    sheet <- visible_sheets[[sheet]]
  }

  list(sheet = sheet, range = range)
}

A1_char_class <- "[a-zA-Z0-9:$]"
compound_rx <- glue("(?<sheet>^.+)!(?<range>{A1_char_class}+$)")
letter_part <- "[$]?[A-Za-z]{1,3}"
number_part <- "[$]?[0-9]{1,7}"
A1_rx <- glue("^{letter_part}{number_part}$|^{letter_part}$|^{number_part}$")
A1_decomp <- glue("(?<column>{letter_part})?(?<row>{number_part})?")

##              | output
##        input | sheet      range
## -------------------------------
## Sheet1!A1:C4 | Sheet1     A1:C4
##           A1 |            A1
##       Sheet1 | Sheet1
##   '[Sheet !' | '[Sheet !'
##
## Note: this function is NOT vectorized, x is scalar
parse_user_range <- function(x) {
  ## match against <sheet name>!<A1 cell reference or range>?
  parsed <- rematch2::re_match(x, compound_rx)

  ## successful match (and parse)
  if (!is.na(parsed$`.match`)) return(as.list(parsed[c("sheet", "range")]))

  ## failed to match
  ## two possibilities:
  ##   * An A1 cell reference or range
  ##   * Name of a sheet or named region
  if (all(grepl(A1_rx, strsplit(x, split = ":")[[1]]))) {
    list(sheet = NULL, range = x)
  } else {
    ## TO THINK: I am questioning if this should even be allowed
    ## perhaps you MUST use sheet argument for this, not range?
    ## to be clear: we're talking about passing a sheet name or name of a
    ## named range, without a '!A1:C4' type of range as suffix
    list(sheet = x, range = NULL)
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
