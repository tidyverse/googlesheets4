lookup_sheet <- function(sheet = NULL,
                         sheets_df,
                         visible = NA,
                         call = caller_env()) {
  maybe_sheet(sheet, call = call)
  if (is.null(sheets_df)) {
    gs4_abort(
      "Can't look up, e.g., sheet name or id without sheet metadata.",
      call = call
    )
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
      gs4_abort(
        c("Can't find a sheet with this name:", x = "{.w_sheet {sheet}}"),
        sheet = sheet,
        # there is some usage where we throw this error, but it is OK
        # and we use tryCatch()
        # that's why we apply the sub-class
        class = "googlesheets4_error_sheet_not_found",
        call = call
      )
    }
    return(as.list(sheets_df[m, ]))
  }
  # sheet is an integer

  m <- as.integer(sheet)
  if (!(m %in% seq_len(nrow(sheets_df)))) {
    gs4_abort(
      c(
        "There {?is/are} {nrow(sheets_df)} sheet{?s}:",
        x = "Requested sheet number is out-of-bounds: {m}"
      ),
      call = call
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

check_sheet <- function(sheet, arg = caller_arg(sheet), call = caller_env()) {
  check_length_one(sheet, arg = arg, call = call)
  if (!is.character(sheet) && !is.numeric(sheet)) {
    gs4_abort(
      c(
        "{.arg {arg}} must be either {.cls character} (sheet name) or \\
         {.cls numeric} (sheet number):",
        x = "{.arg {arg}} has class {.cls {class(sheet)}}."
      ),
      call = call
    )
  }
  sheet
}

maybe_sheet <- function(sheet = NULL,
                        arg = caller_arg(sheet),
                        call = caller_env()) {
  if (is.null(sheet)) {
    sheet
  } else {
    check_sheet(sheet, arg = arg, call = call)
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
  sheets <- eval_tidy(sheets_quo)

  null_along <- function(x) vector(mode = "list", length = length(x))

  if (is.null(sheets)) {
    return(NULL)
  }

  if (is.character(sheets)) {
    return(list(name = sheets, value = null_along(sheets)))
  }

  if (inherits(sheets, "data.frame")) {
    if (quo_is_symbol(sheets_quo)) {
      return(list(name = as_name(sheets_quo), value = list(sheets)))
    } else {
      return(list(name = list(NULL), value = list(sheets)))
    }
  }

  if (is_list(sheets)) {
    nms <- if (is_named(sheets)) names(sheets) else null_along(sheets)
    return(list(name = nms, value = unname(sheets)))
  }

  # we should never get here, so not a user-facing message
  gs4_abort("Invalid input for (work)sheet(s).")
}
