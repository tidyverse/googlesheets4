#' Read a Sheet into a data frame
#'
#' @description
#' This is the main "read" function of the googlesheets4 package. It goes by two
#' names, because we want it to make sense in two contexts:
#' * `read_sheet()` evokes other table-reading functions, like
#'   `readr::read_csv()` and `readxl::read_excel()`. The `sheet` in this case
#'    refers to a Google (spread)Sheet.
#' * `range_read()` is the right name according to the naming convention used
#'   throughout the googlesheets4 package.
#'
#' `read_sheet()` and `range_read()` are synonyms and you can use either one.
#'
#' @section Column Specification:
#'
#'   Column types must be specified in a single string of readr-style short
#'   codes, e.g. "cci?l" means "character, character, integer, guess, logical".
#'   This is not where googlesheets4's col spec will end up, but it gets the
#'   ball rolling in a way that is consistent with readr and doesn't reinvent
#'   any wheels.
#'
#'   Shortcodes for column types:

#'   * `_` or `-`: Skip. Data in a skipped column is still requested from the
#'   API (the high-level functions in this package are rectangle-oriented), but
#'   is not parsed into the data frame output.
#'   * `?`: Guess. A type is guessed for each cell and then a consensus type is
#'   selected for the column. If no atomic type is suitable for all cells, a
#'   list-column is created, in which each cell is converted to an R object of
#'   "best" type. If no column types are specified, i.e. `col_types = NULL`,
#'   all types are guessed.
#'   * `l`: Logical.
#'   * `i`: Integer. This type is never guessed from the data, because Sheets
#'   have no formal cell type for integers.
#'   * `d` or `n`: Numeric, in the sense of "double".
#'   * `D`: Date. This type is never guessed from the data, because date cells
#'   are just serial datetimes that bear a "date" format.
#'   * `t`: Time of day. This type is never guessed from the data, because time
#'   cells are just serial datetimes that bear a "time" format. *Not implemented
#'   yet; returns POSIXct.*
#'   * `T`: Datetime, specifically POSIXct.
#'   * `c`: Character.
#'   * `C`: Cell. This type is unique to googlesheets4. This returns raw cell
#'   data, as an R list, which consists of everything sent by the Sheets API for
#'   that cell. Has S3 type of `"CELL_SOMETHING"` and `"SHEETS_CELL"`. Mostly
#'   useful internally, but exposed for those who want direct access to, e.g.,
#'   formulas and formats.
#'   * `L`: List, as in "list-column". Each cell is a length-1 atomic vector of
#'   its discovered type.
#'   * *Still to come*: duration (code will be `:`) and factor (code will be
#'   `f`).
#'
#' @inheritParams range_read_cells
#' @param col_names `TRUE` to use the first row as column names, `FALSE` to get
#'   default names, or a character vector to provide column names directly. If
#'   user provides `col_types`, `col_names` can have one entry per column or one
#'   entry per unskipped column.
#' @param col_types Column types. Either `NULL` to guess all from the
#'   spreadsheet or a string of readr-style shortcodes, with one character or
#'   code per column. If exactly one `col_type` is specified, it is recycled.
#'   See Column Specification for more.
#' @param na Character vector of strings to interpret as missing values. By
#'   default, blank cells are treated as missing data.
#' @param trim_ws Logical. Should leading and trailing whitespace be trimmed
#'   from cell contents?
#' @param guess_max Maximum number of data rows to use for guessing column
#'   types.
#' @param .name_repair Handling of column names. By default, googlesheets4
#'   ensures column names are not empty and are unique. There is full support
#'   for `.name_repair` as documented in [tibble::tibble()].
#'
#' @return A [tibble][tibble::tibble-package]
#' @export
#'
#' @examplesIf gs4_has_token()
#' ss <- gs4_example("deaths")
#' read_sheet(ss, range = "A5:F15")
#' read_sheet(ss, range = "other!A5:F15", col_types = "ccilDD")
#' read_sheet(ss, range = "arts_data", col_types = "ccilDD")
#'
#' read_sheet(gs4_example("mini-gap"))
#' read_sheet(
#'   gs4_example("mini-gap"),
#'   sheet = "Europe",
#'   range = "A:D",
#'   col_types = "ccid"
#' )
range_read <- function(ss,
                       sheet = NULL,
                       range = NULL,
                       col_names = TRUE, col_types = NULL,
                       na = "", trim_ws = TRUE,
                       skip = 0, n_max = Inf,
                       guess_max = min(1000, n_max),
                       .name_repair = "unique") {
  # check these first, so we don't download cells in vain
  col_spec <- standardise_col_spec(col_names, col_types, call = current_env())
  check_character(na)
  check_bool(trim_ws)
  check_non_negative_integer(guess_max)

  # range spec params are checked inside get_cells():
  # ss, sheet, range, skip, n_max
  df <- get_cells(
    ss = ss,
    sheet = sheet, range = range,
    col_names_in_sheet = isTRUE(col_spec$col_names),
    skip = skip, n_max = n_max
  )

  spread_sheet_impl_(
    df,
    col_spec = col_spec, na = na, trim_ws = trim_ws, guess_max = guess_max,
    .name_repair = .name_repair
  )
}

#' @rdname range_read
#' @export
read_sheet <- range_read

#' Spread a data frame of cells into spreadsheet shape
#'
#' Reshapes a data frame of cells (presumably the output of
#' [range_read_cells()]) into another data frame, i.e., puts it back into the
#' shape of the source spreadsheet. This function exists primarily for internal
#' use and for testing. The flagship function [range_read()], a.k.a.
#' [read_sheet()], is what most users are looking for. It is basically
#' [range_read_cells()] + `spread_sheet()`.
#'
#' @inheritParams range_read
#' @param df A data frame with one row per (nonempty) cell, integer variables
#'   `row` and `column` (probably referring to location within the spreadsheet),
#'   and a list-column `cell` of `SHEET_CELL` objects.
#'
#' @return A tibble in the shape of the original spreadsheet, but enforcing
#'   user's wishes regarding column names, column types, `NA` strings, and
#'   whitespace trimming.
#' @export
#'
#' @examplesIf gs4_has_token()
#' df <- gs4_example("mini-gap") %>%
#'   range_read_cells()
#' spread_sheet(df)
#'
#' # ^^ gets same result as ...
#' read_sheet(gs4_example("mini-gap"))
spread_sheet <- function(df,
                         col_names = TRUE, col_types = NULL,
                         na = "", trim_ws = TRUE,
                         guess_max = min(1000, max(df$row)),
                         .name_repair = "unique") {
  col_spec <- standardise_col_spec(col_names, col_types, call = current_env())
  check_character(na)
  check_bool(trim_ws)
  check_non_negative_integer(guess_max)

  spread_sheet_impl_(
    df,
    col_spec = col_spec, na = na, trim_ws = trim_ws, guess_max = guess_max,
    .name_repair = .name_repair
  )
}

spread_sheet_impl_ <- function(df,
                               col_spec = list(
                                 col_names = TRUE, col_types = NULL
                               ),
                               na = "", trim_ws = TRUE,
                               guess_max = min(1000, max(df$row)),
                               .name_repair = "unique",
                               call = caller_env()) {
  if (nrow(df) == 0) {
    return(tibble::tibble())
  }
  col_names <- col_spec$col_names
  ctypes <- col_spec$ctypes
  col_names_in_sheet <- isTRUE(col_names)

  # absolute spreadsheet coordinates no longer relevant
  # update row, col to refer to location in output data frame
  # row 0 holds cells designated as column names
  df$row <- df$row - min(df$row) + !col_names_in_sheet
  nr <- max(df$row)
  df$col <- df$col - min(df$col) + 1

  if (is.logical(col_names)) {
    # if col_names is logical, this is first chance to check/set length of
    # ctypes, using the cell data
    ctypes <- rep_ctypes(
      max(df$col),
      ctypes,
      "column{?s} found in sheet",
      call = call
    )
  }

  # drop cells in skipped cols, update df$col and ctypes
  skipped_col <- ctypes == "COL_SKIP"
  if (any(skipped_col)) {
    df <- df[!df$col %in% which(skipped_col), ]
    df$col <- match(df$col, sort(unique(df$col)))
    ctypes <- ctypes[!skipped_col]
  }
  nc <- max(df$col)

  # if column names were provided explicitly, we need to check that length
  # of col_names (and, therefore, ctypes) == nc
  if (is.character(col_names) && length(col_names) != nc) {
    gs4_abort(
      c(
        "Length of {.arg col_names} is not compatible with the data:",
        "*" = "{.arg col_names} has length {length(col_names)}.",
        "x" = "But data has {nc} un-skipped column{?s}."
      ),
      call = call
    )
  }

  df$cell <- apply_ctype(df$cell, na = na, trim_ws = trim_ws)

  if (is.logical(col_names)) {
    col_names <- character(length = nc)
  }
  if (col_names_in_sheet) {
    this <- df$row == 0
    col_names[df$col[this]] <-
      as_character(df$cell[this], na = na, trim_ws = trim_ws)
    df <- df[!this, ]
  }

  df_split <- map(seq_len(nc), ~ df[df$col == .x, ])

  out_scratch <- map2(
    df_split,
    ctypes,
    make_column,
    na = na, trim_ws = trim_ws, nr = nr, guess_max = guess_max
  ) %>%
    set_names(col_names) %>%
    discard(is.null)

  as_tibble(out_scratch, .name_repair = .name_repair)
}

## helpers ---------------------------------------------------------------------

standardise_col_spec <- function(col_names, col_types, call = caller_env()) {
  check_col_names(col_names, call = call)
  ctypes <- standardise_ctypes(col_types, call = call)
  if (is.character(col_names)) {
    ctypes <- rep_ctypes(
      length(col_names),
      ctypes,
      "column name{?s}",
      call = call
    )
    col_names <- filter_col_names(col_names, ctypes)
    # if column names were provided explicitly, this is now true
    # length(col_names) == length(ctypes[ctypes != "COL_SKIP"])
  }
  list(col_names = col_names, ctypes = ctypes)
}

check_col_names <- function(col_names, call = caller_env()) {
  if (is.logical(col_names)) {
    return(check_bool(col_names, call = call))
  }
  check_character(col_names, call = call)
  check_has_length(col_names, call = call)
}

# input:  a string of readr-style shortcodes or NULL
# output: a vector of col types of length >= 1
standardise_ctypes <- function(col_types, call = caller_env()) {
  col_types <- col_types %||% "?"
  check_string(col_types, call = call)

  if (identical(col_types, "")) {
    gs4_abort("
      {.arg col_types}, when provided, must be a string that contains at \\
      least one readr-style shortcode.",
      call = call
    )
  }

  accepted_codes <- keep(names(.ctypes), nzchar)

  col_types_split <- strsplit(col_types, split = "")[[1]]
  ok <- col_types_split %in% accepted_codes
  if (!all(ok)) {
    gs4_abort(
      c(
        "{.arg col_types} must be a string of readr-style shortcodes. \\
         Unrecognized code{?s}{cli::qty(sum(!ok))}:",
        bulletize(gargle_map_cli(col_types_split[!ok]), bullet = "x")
      ),
      call = call
    )
  }
  ctypes <- ctype(col_types_split)
  if (all(ctypes == "COL_SKIP")) {
    gs4_abort(
      "{.arg col_types} can't request that all columns be skipped.",
      call = call
    )
  }
  ctypes
}

# makes sure there are n ctypes or n ctypes that are not COL_SKIP
rep_ctypes <- function(n, ctypes, comparator = "n", call = caller_env()) {
  if (length(ctypes) == n) {
    return(ctypes)
  }
  n_col_types <- sum(ctypes != "COL_SKIP")
  if (n_col_types == n) {
    return(ctypes)
  }
  if (length(ctypes) == 1) {
    return(rep_len(ctypes, length.out = n))
  }
  # must pre-pluralize the comparator, e.g.
  # column{?s} found in sheet
  # column name{?s}
  comparator <- cli::pluralize(sprintf("{cli::qty(n)}%s{?s}", comparator))
  gs4_abort(
    c(
      "Length of {.arg col_types} is not compatible with {comparator}:",
      x = "{length(ctypes)} column type{?s} specified.",
      x = "{n_col_types} un-skipped column type{?s} specified.",
      x = "But there {cli::qty(n)}{?is/are} {n} {comparator}."
    ),
    call = call
  )
}

# removes col_names for skipped columns
# rep_ctypes() is called before and ensures that col_names and ctypes are
# conformable (hence the non-user facing stopifnot())
filter_col_names <- function(col_names, ctypes) {
  stopifnot(length(col_names) <= length(ctypes))
  col_names[ctypes != "COL_SKIP"]
}
