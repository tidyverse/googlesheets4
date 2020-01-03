lookup_sheet <- function(sheet = NULL, sheets_df, visible = NA) {
  maybe_sheet(sheet)
  if (is.null(sheets_df)) {
    stop_glue("Can't look up, e.g., sheet name or id without sheet metadata")
  }

  if (isTRUE(visible)) {
    sheets_df <- sheets_df[sheets_df$visible, ]
  }

  if (is.null(sheet)) {
    first_sheet <- which.min(sheets_df$index)
    return(as.list(sheets_df[first_sheet, ]))
  }
  # sheet is a string or an integer

  if (is.character(sheet)) {
    sheet <- sq_unescape(sheet)
    m <- match(sheet, sheets_df$name)
    if (is.na(m)) {
      stop_glue("No sheet found with this name: {sq(sheet)}")
    }
    return(as.list(sheets_df[m, ]))
  }
  # sheet is an integer

  m <- as.integer(sheet)
  if (!(m %in% seq_len(nrow(sheets_df)))) {
    stop_glue(
      "There are {nrow(sheets_df)} sheets:\n",
      "  * Requested sheet number is out-of-bounds: {m}"
    )
  }
  as.list(sheets_df[m, ])
}

first_sheet <- function(sheets_df, visible = NA) {
  lookup_sheet(sheet = NULL, sheets_df = sheets_df, visible = visible)
}

first_visible <- function(sheets_df) first_sheet(sheets_df, visible = TRUE)

first_visible_id <- function(sheets_df) {
  first_sheet(sheets_df, visible = TRUE)$id
}

first_visible_name <- function(sheets_df) {
  first_sheet(sheets_df, visible = TRUE)$name
}

lookup_sheet_name <- function(sheet, sheets_df) {
  s <- lookup_sheet(sheet = sheet, sheets_df = sheets_df)
  s$name
}

check_sheet <- function(sheet, nm = deparse(substitute(sheet))) {
  check_length_one(sheet, nm = nm)
  if (!is.character(sheet) && !is.numeric(sheet)) {
    stop_glue(
      "{bt(nm)} must be either character (sheet name) or ",
      "numeric (sheet number):\n",
      "  * {bt(nm)} has class {class_collapse(sheet)}"
    )
  }
  return(sheet)
}

maybe_sheet <- function(sheet = NULL, nm = deparse(substitute(sheet))) {
  if (is.null(sheet)) {
    sheet
  } else {
    check_sheet(sheet, nm = nm)
  }
}

#' Normalize user input re: (work)sheet names and/or data
#'
#' @param sheets_quo Quosure containing user input re: how to populate
#'   (work)sheets.
#'
#' @return A list with 2 equal-sized components, `name` and `value`. Size =
#'   number of (work)sheets.
#' @keywords internal
#' @noRd
enlist_sheets <- function(sheets_quo) {
  sheets <- rlang::eval_tidy(sheets_quo)

  null_along <- function(x) vector(mode = "list", length = length(x))

  if (is.null(sheets)) {
    return(NULL)
  }

  if (is.character(sheets)) {
    return(list(name = sheets, value = null_along(sheets)))
  }

  if (rlang::quo_is_symbol(sheets_quo)) {
    return(list(name = rlang::as_name(sheets_quo), value = list(sheets)))
  }

  if (inherits(sheets, "data.frame")) {
    return(list(name = list(NULL), value = list(sheets)))
  }

  if (rlang::is_list(sheets)) {
    nms <- if (rlang::is_named(sheets)) names(sheets) else null_along(sheets)
    return(list(name = nms, value = unname(sheets)))
  }

  # we should never get here, so not a user-facing message
  stop_glue("Invalid input for (work)sheet(s)")
}
