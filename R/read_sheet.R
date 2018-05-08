#' Read a Sheet into a data frame
#'
#' WIP! The main read function of this package.
#'
#' Data in a skipped column is still requested from the API (we work in a
#' rectangle, after all), but is not parsed into the data frame output. The
#' `"list"` type requests a column that is a list of length 1 vectors, using the
#' type guessing logic from `col_types = NULL`, but on a cell-by-cell basis.
#' Shortcode refresher: `_` or `-` for skip, `?` for guess, `l` for logical, `i`
#' for integer, `d` or `n` for double, `c` for character, `T` for POSIXct
#' datetime, `D` for date, `t` for time-of-day (currently treated like a
#' datetime). To be determined: factor, list, raw (meaning API payload, not raw
#' in the usual R sense).
#'
#' @param ss Something that uniquely identifies a Google Sheet. Processed
#'   through [as_sheets_id()].
#' @param sheet Sheet to read. Either a string (the name of a sheet), or an
#'   integer (the position of the sheet). Ignored if the sheet is specified via
#'   `range`. If neither argument specifies the sheet, defaults to the first
#'   visible sheet.
#' @param range A cell range to read from, as described in FILL THIS IN.
#' @param col_names `TRUE` to use the first row as column names, `FALSE` to get
#'   default names, or a character vector to provide column names directly. In
#'   all cases, names are processed through [tibble::tidy_names()]. If user
#'   provides `col_types`, `col_names` can have one entry per column, i.e. have
#'   the same length as `col_types`, or one entry per unskipped column.
#' @param col_types column types Either `NULL` to guess all from the spreadsheet
#'   or (TEMPORARY INTERFACE!!!) a string using readr shortcodes, with one
#'   character or code per column. If exactly one `col_type` is specified, it is
#'   recycled. See Details for more.
#' @param na Character vector of strings to interpret as missing values. By
#'   default, blank cells are treated as missing data.
#' @param trim_ws Should leading and trailing whitespace be trimmed?
#' @param skip Minimum number of rows to skip before reading anything, be it
#'   column names or data. Leading empty rows are automatically skipped, so this
#'   is a lower bound. Ignored if `range` is given.
#' @param n_max Maximum number of data rows to read. Trailing empty rows are
#'   automatically skipped, so this is an upper bound on the number of rows in
#'   the returned tibble. Ignored if `range` is given.
#' @param guess_max Maximum number of data rows to use for guessing column
#'   types.
#'
#' @return a tibble
#' @export
#'
#' @examples
#' read_sheet(sheets_example("mini-gap"))
#' read_sheet(sheets_example("mini-gap"), sheet = "Europe", col_types = "cciddd")
#' read_sheet(sheets_example("mini-gap"), sheet = 4, col_types = "c?ii-d")
#' test_sheet <- "1J5gb0u8n3D2qx3O3rY28isnI5SD89attRwhWPWlkmDM"
#' read_sheet(test_sheet)
#' read_sheet(test_sheet, skip = 2)
#' read_sheet(test_sheet, n_max = 2)
#' read_sheet(test_sheet, range = "A1:B2")
#' read_sheet(test_sheet, range = "B2:C4")
#' read_sheet(test_sheet, range = "B2:E5")
#'
#' ss <- sheets_example("deaths")
#' read_sheet(ss, range = "A5:F15")
#' range <- "A5:F15"
#' col_types <- "ccilDD"
#' #read_excel(readxl_example("deaths.xlsx"), range = "other!A5:F15")
#' read_sheet(ss, range = "other!A5:F15", col_types = "ccilDD")
read_sheet <- function(ss,
                       sheet = NULL,
                       range = NULL,
                       col_names = TRUE, col_types = NULL,
                       na = "", trim_ws = TRUE,
                       skip = 0, n_max = Inf,
                       guess_max = min(1000, n_max)) {
  ## ss, sheet, range get checked inside get_cells()
  check_col_names(col_names)
  ctypes <- standardise_ctypes(col_types)
  if (is.character(col_names)) {
    ctypes <- rep_ctypes(length(col_names), ctypes, "column names")
    col_names <- filter_col_names(col_names, ctypes)
    ## if column names were provided explicitly, this is now true
    ## length(col_names) == length(ctypes[ctypes != "COL_SKIP"])
  }

  check_character(na)
  check_bool(trim_ws)
  ## skip and n_max get checked inside get_cells()
  check_non_negative_integer(guess_max)

  out <- get_cells(
    ss = ss,
    sheet = sheet, range = range,
    col_names_in_sheet = isTRUE(col_names),
    skip = skip, n_max = n_max
  )

  ## absolute spreadsheet coordinates no longer relevant
  ## update row, col to refer to location in output data frame
  ## row 0 holds cells designated as column names
  col_names_in_sheet <- isTRUE(col_names)
  out$row <- out$row - min(out$row) + !col_names_in_sheet
  nr <- max(out$row)
  out$col <- out$col - min(out$col) + 1

  if (is.logical(col_names)) {
    ## if col_names is logical, this is first chance to check/set length of
    ## ctypes, using the cell data
    ctypes <- rep_ctypes(max(out$col), ctypes, "columns found in sheet")
  }

  ## drop cells in skipped cols, update out$col and ctypes
  skipped_col <- ctypes == "COL_SKIP"
  if (any(skipped_col)) {
    out <- out[!out$col %in% which(skipped_col), ]
    out$col <- match(out$col, sort(unique(out$col)))
    ctypes <- ctypes[!skipped_col]
  }
  nc <- max(out$col)

  ## if column names were provided explicitly, we need to check that length
  ## of col_names (and, therefore, ctypes) == nc
  if (is.character(col_names) && length(col_names) != nc) {
    stop_glue(
      "Length of {bt('col_names')} is not compatible with the data:\n",
      "  * Expected {length(col_names)} un-skipped columns\n",
      "  * But data has {nc} columns"
    )
  }

  out$cell <- apply_ctype(out$cell)

  if (is.logical(col_names)) {
    col_names <- character(length = nc)
  }
  if (col_names_in_sheet) {
    this <- out$row == 0
    col_names[out$col[this]] <- as_character(out$cell[this])
    out <- out[!this, ]
  }
  col_names <- tibble::tidy_names(col_names)

  out_split <- map(seq_len(nc), ~ out[out$col == .x, ])

  out_scratch <- purrr::map2(
    out_split,
    ctypes,
    make_column,
    na = na, trim_ws = trim_ws, nr = nr, guess_max = guess_max
  ) %>%
    purrr::set_names(col_names) %>%
    purrr::compact()

  tibble::as_tibble(out_scratch)
}

## helpers ---------------------------------------------------------------------
check_col_names <- function(col_names) {
  if (is.logical(col_names)) {
    return(check_bool(col_names))
  }
  check_character(col_names)
  check_has_length(col_names)
}

## input:  a string of readr-style shortcodes or NULL
## output: a vector of col types of length >= 1
standardise_ctypes <- function(col_types) {
  col_types <- col_types %||% "?"
  check_string(col_types)

  if (identical(col_types, "")) {
    stop_glue(
      "{bt('col_types')}, if provided, must be a string that contains at ",
      "least one readr-style shortcode."
    )
  }

  accepted_codes <- purrr::keep(names(.ctypes), nzchar)

  col_types_split <- strsplit(col_types, split = '')[[1]]
  ok <- col_types_split %in% accepted_codes
  if (!all(ok)) {
    bad_codes <- glue_collapse(sq(col_types_split[!ok]), sep = ",")
    stop_glue(
      "{bt('col_types')} must be a string of readr-style shortcodes:\n",
      "  * Unrecognized codes: {bad_codes}"
    )
  }
  ctypes <- ctype(col_types_split)
  if (all(ctypes == "COL_SKIP")) {
    stop_glue("{bt('col_types')} can't request that all columns be skipped")
  }
  ctypes
}

## makes sure there are n ctypes or n ctypes that are not COL_SKIP
rep_ctypes <- function(n, ctypes, comparator = "n") {
  if (length(ctypes) == n) {
    return(ctypes)
  }
  n_col_types <- sum(ctypes !=  "COL_SKIP")
  if (n_col_types == n) {
    return(ctypes)
  }
  if (length(ctypes) == 1) {
    return(rep_len(ctypes, length.out = n))
  }
  stop_glue(
    "Length of {bt('col_types')} is not compatible with {comparator}:\n",
    "  * {length(ctypes)} column types specified\n",
    "  * {n_col_types} un-skipped column types specified\n",
    "  * But there are {n} {comparator}."
  )
}

## removes col_names for skipped columns
## rep_ctypes() is called before and ensures that col_names and ctypes are
## conformable (hence the non-user facing stopifnot())
filter_col_names <- function(col_names, ctypes) {
  stopifnot(length(col_names) <= length(ctypes))
  col_names[ctypes != "COL_SKIP"]
}
