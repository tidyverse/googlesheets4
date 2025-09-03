## range_spec is an "internal-use only" S3 class ----
new_range_spec <- function(...) {
  l <- list2(...)
  structure(
    list(
      sheet_name = l$sheet_name %||% NULL,
      named_range = l$named_range %||% NULL,
      cell_range = l$cell_range %||% NULL,
      cell_limits = l$cell_limits %||% NULL,
      shim = FALSE,
      sheets_df = l$sheets_df %||% NULL,
      nr_df = l$nr_df %||% NULL
    ),
    # useful when debugging range specification, but otherwise this is TMI
    # .input = l$.input,
    class = "range_spec"
  )
}

as_range_spec <- function(x, ...) {
  UseMethod("as_range_spec")
}

#' @export
as_range_spec.default <- function(x, ...) {
  gs4_abort(c(
    "Can't make a range suitable for the Sheets API from the supplied \\
     {.arg range}.",
    x = "{.arg range} has class {.cls {class(x)}}.",
    i = "{.arg range} must be {.code NULL}, a string, or \\
         a {.cls cell_limits} object."
  ))
}

## as_range_spec.character ----

# anticipated inputs to the character method for x (= range)
# **** means "doesn't matter, never consulted"
#
# sheet   range         skip
# --------------------------------------
# ****    Sheet1!A1:B2  ****
# ****    Named_range   ****
# ****    Sheet1        i     weird, but I guess we roll with it (re-dispatch)
#         A1:B2         ****
# Sheet1  A1:B2         ****
# 3       A1:B2         ****
#' @export
as_range_spec.character <- function(
  x,
  ...,
  sheet = NULL,
  skip = 0,
  sheets_df = NULL,
  nr_df = NULL
) {
  check_length_one(x)

  out <- new_range_spec(
    sheets_df = sheets_df,
    nr_df = nr_df,
    .input = list(
      sheet = sheet,
      range = x,
      skip = skip
    )
  )

  m <- rematch2::re_match(x, compound_rx)

  # range looks like: Sheet1!A1:B2
  if (notNA(m[[".match"]])) {
    out$sheet_name <- lookup_sheet_name(m$sheet, sheets_df)
    out$cell_range <- m$cell_range
    out$shim <- TRUE
    return(out)
  }

  # check if range matches a named range
  m <- match(x, nr_df$name)
  if (notNA(m)) {
    out$named_range <- x
    return(out)
  }

  # check if range matches a sheet name
  # API docs: "When a named range conflicts with a sheet's name, the named range
  # is preferred."
  m <- match(x, sheets_df$name)
  if (notNA(m)) {
    # Re-dispatch as if provided as `sheet`. Which it should have been.
    return(as_range_spec(NULL, sheet = x, skip = skip, sheets_df = sheets_df))
  }

  # range must be in A1 notation
  m <- grepl(A1_rx, strsplit(x, split = ":")[[1]])
  if (!all(m)) {
    gs4_abort(c(
      "{.arg range} doesn't appear to be a range in A1 notation, a named \\
       range, or a sheet name:",
      x = "{.range {x}}"
    ))
  }
  out$cell_range <- x
  if (!is.null(sheet)) {
    out$sheet_name <- lookup_sheet_name(sheet, sheets_df)
  }
  out$shim <- TRUE
  out
}

## as_range_spec.NULL ----

# anticipated inputs to the NULL method for x (= range)
#
# sheet       skip
# --------------------------------------
#             0     This is what "nothing" looks like. Send nothing.
# Sheet1 / 2  0     Send sheet name.
#             >0    Express skip request in cell_limits object and re-dispatch.
# Sheet1 / 2  >0    <same as previous>
#' @export
as_range_spec.NULL <- function(
  x,
  ...,
  sheet = NULL,
  skip = 0,
  sheets_df = NULL
) {
  out <- new_range_spec(
    sheets_df = sheets_df,
    .input = list(sheet = sheet, skip = skip)
  )

  if (skip < 1) {
    if (!is.null(sheet)) {
      out$sheet_name <- lookup_sheet_name(sheet, sheets_df)
    }
    return(out)
  }

  as_range_spec(
    cell_rows(c(skip + 1, NA)),
    sheet = sheet,
    sheets_df = sheets_df,
    shim = FALSE
  )
}

## as_range_spec.cell_limits ----

# anticipated inputs to the cell_limits method for x (= range)
#
# sheet       range
# --------------------------------------
#             cell_limits   Send A1 representation of cell_limits. Let the API
#                           figure out the sheet. API docs imply it will be the
#                           "first visible sheet".
# Sheet1 / 2  cell_limits   Resolve sheet name, make A1 range, send combined
#                           result.
#' @export
as_range_spec.cell_limits <- function(
  x,
  ...,
  shim = TRUE,
  sheet = NULL,
  sheets_df = NULL
) {
  out <- new_range_spec(
    sheets_df = sheets_df,
    .input = list(sheet = sheet, range = x, shim = shim)
  )
  out$cell_limits <- x
  if (!is.null(sheet)) {
    out$sheet_name <- lookup_sheet_name(sheet, sheets_df)
  }
  out$shim <- shim
  out
}

#' @export
format.range_spec <- function(x, ...) {
  is_df <- names(x) %in% c("sheets_df", "nr_df")
  x[is_df & !map_lgl(x, is.null)] <- "<provided>"
  glue("{fr(names(x))}: {x}")
}

#' @export
print.range_spec <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}

as_A1_range <- function(x) {
  stopifnot(inherits(x, "range_spec"))

  if (!is.null(x$named_range)) {
    return(x$named_range)
  }

  if (!is.null(x$cell_limits)) {
    x$cell_range <- as_sheets_range(x$cell_limits)
  }

  qualified_A1(x$sheet_name, x$cell_range)
}

# has been useful during development, at times
# sheets_A1_range <- function(ss,
#                             sheet = NULL,
#                             range = NULL,
#                             skip = 0) {
#   ssid <- as_sheets_id(ss)
#   maybe_sheet(sheet)
#   check_range(range)
#   check_non_negative_integer(skip)
#
#   # retrieve spreadsheet metadata ----------------------------------------------
#   x <- gs4_get(ssid)
#   gs4_bullets(c(i = "Spreadsheet name: {.s_sheet {x$name}}"))
#
#   # range specification --------------------------------------------------------
#   range_spec <- as_range_spec(
#     range, sheet = sheet, skip = skip,
#     sheets_df = x$sheets, nr_df = x$named_ranges
#   )
#   A1_range <- as_A1_range(range_spec)
#   gs4_bullets(c(i = "A1 range {.range {A1_range}}"))
#
#   range_spec
# }
