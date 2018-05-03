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
#'   default, readxl treats blank cells as missing data.
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
#' test_sheet <- "1J5gb0u8n3D2qx3O3rY28isnI5SD89attRwhWPWlkmDM"
#' read_sheet(test_sheet)
#' read_sheet(test_sheet, skip = 2)
#' read_sheet(test_sheet, n_max = 2)
#' read_sheet(test_sheet, range = "A1:B2")
#' read_sheet(test_sheet, range = "B2:C4")
#' read_sheet(test_sheet, range = "B2:E5")
#'
#' ss <- sheets_example("deaths")
#' range <- "A5:F15"
#' col_types <- "ccilDD"
#' read_excel(readxl_example("deaths.xlsx"), range = "other!A5:F15")
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
  col_types <- standardise_col_types(col_types)
  check_col_names_and_types(col_names, col_types)
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

  # TODO: remove this, but can be nice during dev
  #out <- add_loc(out)

  ## absolute spreadsheet coordinates no longer relevant
  ## update row, col to refer to location in output data frame
  ## row 0 holds cells designated as column names
  col_names_in_sheet <- isTRUE(col_names)
  out$row <- out$row - min(out$row) + !col_names_in_sheet
  nr <- max(out$row)
  out$col <- out$col - min(out$col) + 1

  types <- strsplit(col_types, split = '')[[1]]
  ## TODO: only recycle if length 1
  types <- rep_len(types, length.out = max(out$col))

  ## drop cells in skipped cols
  ## update types, col_names, and out$col accordingly
  skipped_col <- types %in% c("-", "_")
  if (any(skipped_col)) {
    out <- out[!out$col %in% which(skipped_col), ]
    out$col <- match(out$col, sort(unique(out$col)))
    types <- types[!skipped_col]
    if (is.character(col_names) && length(col_names) > length(types)) {
      col_names <- col_names[!skipped_col]
    }
  }
  nc <- max(out$col)

  out$cell <- apply_type(out$cell)

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
    types,
    make_column,
    na = na, trim_ws = trim_ws, nr = nr
  ) %>% purrr::set_names(col_names)

  tibble::as_tibble(out_scratch)
}

## TO DO: move this physically and conceptually into coercing
make_column <- function(df, shortcode, ..., nr) {
  parsed <- parse(df$cell, shortcode, ...)
  column <- switch(
    shortcode,
    ## TODO: do I need set timezone in any of these?
    `T` = as.POSIXct(rep(NA, length.out = nr)),
    D = as.Date(rep(NA, length.out = nr)),
    ## TODO: time of day not implemented yet
    t = as.POSIXct(rep(NA, length.out = nr)),
    vector(mode = typeof(parsed), length = nr)
  )
  column[df$row] <- parsed
  column
}

check_col_names_and_types <- function(col_names, col_types) {
  if (is.null(col_types)) {
    return(invisible())
  }
  col_types_split <- strsplit(col_types, split = '')[[1]]
  n_col_types <- sum(! col_types_split %in% c("-", "_"))
  if (length(col_names) <= 1 ||
      n_col_types  <= 1 ||
      length(col_names) == n_col_types) {
    return(invisible())
  }
  stop_glue(
    "If column names are provided, there must be one name for each ",
    "un-skipped column (no more, no less):\n",
    "  * {length(col_names)} column names were provided\n",
    "  * {n_col_types} columns are not skipped"
  )
}

check_col_names <- function(col_names) {
  if (is.logical(col_names)) {
    return(check_bool(col_names))
  }
  check_character(col_names)
}

standardise_col_types <- function(col_types) {
  if (length(col_types) < 1) {
    return("?")
  }
  check_string(col_types)

  accepted_codes <- "[-_\\?lidncTDt]+"
  ## for the moment, requires readr shortcodes
  ## will ultimately use new col spec work, possibly before release?
  ## in any case, this gets things moving
  ##
  ## col_skip()      _ or -
  ## guess_parser    ?
  ## parse_logical   l
  ## parse_integer   i
  ## parse_double    d
  ## parse_number    n
  ## parse_character c
  ##
  ## these will be very low-functioning until a format can be passed
  ## parse_datetime(..., format = "??") T
  ## parse_date(..., format = "??")     D
  ## parse_time(..., format = "??")     t
  ##
  ## this has no shortcode (an oversight, issue opened)
  ## parse_factor(..., levels = "??")   <NO SHORTCODE, OOPS>
  ## convert to factor after import, for now

  col_types_split <- strsplit(col_types, split = '')[[1]]
  ## if col_types = "", col_types_split = character()
  ok <- nzchar(col_types) && grepl(accepted_codes, col_types_split)
  if (!all(ok)) {
    stop_glue(
      "{bt('col_types')} must be a string of readr-style shortcodes.\n"
      ## TODO: reveal the unrecognized shortcode?
    )
  }
  col_types
}
