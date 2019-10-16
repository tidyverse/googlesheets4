## range_spec is an "internal-use only" S3 class ----
new_range_spec <- function(...) {
  l <- list(...)
  structure(
    list(
      sheet_name  = l$sheet_name  %||% NULL,
      named_range = l$named_range %||% NULL,
      A1_range    = l$A1_range    %||% NULL,
      api_range   = l$api_range   %||% NULL,
      cell_limits = l$cell_limits %||% NULL,
      shim        = FALSE
    ),
    .input = l$.input,
    class = "range_spec"
  )
}

as_range_spec <- function(x, ...) {
  UseMethod("as_range_spec")
}

as_range_spec.default <- function(x, ...) {
  stop_glue(
    "Can't make a range suitable for the Sheets API from the supplied ",
    "{bt('range')}.\n",
    "{bt('range')} must be NULL, a string, or a cell_limits object.\n",
    "  * {bt('range')} has class {class_collapse(x)}"
  )
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
as_range_spec.character <- function(x,
                                    ...,
                                    sheet = NULL,
                                    skip = 0,
                                    sheet_names = NULL,
                                    nr_names = NULL) {
  check_length_one(x)

  out <- new_range_spec(
    .input = list(
      sheet = sheet, range = x, skip = skip,
      sheet_names = sheet_names, nr_names = nr_names
    )
  )

  m <- rematch2::re_match(x, compound_rx)

  # range looks like: Sheet1!A1:B2
  if (notNA(m[[".match"]])) {
    out$sheet_name <- resolve_sheet(m$sheet, sheet_names)
    out$A1_range   <- m$range
    out$api_range  <- qualified_A1(out$sheet_name, out$A1_range)
    out$shim       <- TRUE
    return(out)
  }

  # check if range matches a named range
  m <- match(x, nr_names)
  if (notNA(m)) {
    out$api_range <- out$named_range <- x
    return(out)
  }

  # check if range matches a sheet name
  # API docs: "When a named range conflicts with a sheet's name, the named range
  # is preferred."
  m <- match(x, sheet_names)
  if (notNA(m)) {
    # Re-dispatch. Match already established, so no need to pass sheet names.
    return(as_range_spec(x = NULL, sheet = x, skip = skip))
  }

  # range must be in A1 notation
  m <- grepl(A1_rx, strsplit(x, split = ":")[[1]])
  if (!all(m)) {
    stop_glue(
      "{bt('range')} doesn't appear to be a range in A1 notation, a named ",
      "range, or a sheet name:\n",
      "  * {sq(x)}"
    )
  }
  out$A1_range <- x
  if (!is.null(sheet)) {
    out$sheet_name <- resolve_sheet(sheet, sheet_names)
  }
  out$api_range <- qualified_A1(out$sheet_name, out$A1_range)
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
as_range_spec.NULL <- function(x,
                               ...,
                               sheet = NULL,
                               skip = 0,
                               sheet_names = NULL) {
  out <- new_range_spec(
    .input = list(
      sheet = sheet, range = x, skip = skip,
      sheet_names = sheet_names
    )
  )

  if (is.null(sheet)) {
    if (skip < 1) {
      return(out)
    } else {
      return(
        as_range_spec(
          x = cell_rows(c(skip + 1, NA)),
          sheet = sheet, sheet_names = sheet_names, shim = FALSE
        )
      )
    }
  }

  out$sheet_name <- resolve_sheet(sheet, sheet_names)
  out$api_range <- qualified_A1(out$sheet_name)
  out
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
as_range_spec.cell_limits <- function(x,
                                      ...,
                                      shim = TRUE,
                                      sheet = NULL,
                                      sheet_names = NULL) {
  out <- new_range_spec(
    .input = list(
      sheet = sheet, range = x, sheet_names = sheet_names, shim = shim
    )
  )
  out$cell_limits <- x
  if (!is.null(sheet)) {
    out$sheet_name <- resolve_sheet(sheet, sheet_names)
  }
  out$api_range <- qualified_A1(
    out$sheet_name,
    # we replace some NAs with concrete extents here, for cell reading
    # but note we use original cell_limits later, for shimming
    as_sheets_range(resolve_limits(x))
  )
  out$shim <- shim
  out
}
