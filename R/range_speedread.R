#' Read Sheet as CSV
#'
#' @description
#' This function uses a quick-and-dirty method to read a Sheet that bypasses the
#' Sheets API and, instead, parses a CSV representation of the data. This can be
#' much faster than [range_read()] -- noticeably so for "large" spreadsheets.
#' There are real downsides, though, so we recommend this approach only when the
#' speed difference justifies it. Here are the limitations we must accept to get
#' faster reading:
#' * Only formatted cell values are available, not underlying values or details
#'   on the formats.
#' * We can't target a named range as the `range`.
#' * We have no access to the data type of a cell, i.e. we don't know that it's
#'   logical, numeric, or datetime. That must be re-discovered based on the
#'   CSV data (or specified by the user).
#' * Auth and error handling have to be handled a bit differently internally,
#'   which may lead to behaviour that differs from other functions in
#'   googlesheets4.
#'
#' Note that the Sheets API is still used to retrieve metadata on the target
#' Sheet, in order to support range specification. `range_speedread()` also
#' sends an auth token with the request, unless a previous call to
#' [gs4_deauth()] has put googlesheets4 into a de-authorized state.
#'
#' @inheritParams range_read_cells
#' @param ... Passed along to the CSV parsing function (currently
#'   `readr::read_csv()`).
#'
#' @return A [tibble][tibble::tibble-package]
#' @export
#'
#' @examplesIf gs4_has_token()
#' if (require("readr")) {
#'   # since cell type is not available, use readr's col type specification
#'   range_speedread(
#'     gs4_example("deaths"),
#'     sheet = "other",
#'     range = "A5:F15",
#'     col_types = cols(
#'       Age = col_integer(),
#'       `Date of birth` = col_date("%m/%d/%Y"),
#'       `Date of death` = col_date("%m/%d/%Y")
#'     )
#'   )
#' }
#'
#' # write a Sheet that, by default, is NOT world-readable
#' (ss <- sheet_write(chickwts))
#'
#' # demo that range_speedread() sends a token, which is why we can read this
#' range_speedread(ss)
#'
#' # clean up
#' googledrive::drive_trash(ss)
range_speedread <- function(ss, sheet = NULL, range = NULL, skip = 0, ...) {
  check_installed("readr", "to use `range_speedread()`.")

  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_range(range)
  check_non_negative_integer(skip)

  x <- gs4_get(ssid)

  params <- list(
    spreadsheet_id = unclass(ssid),
    path = "export",
    format = "csv"
  )
  sheet_msg <- ""
  range_msg <- ""
  range_spec <- as_range_spec(
    range,
    sheet = sheet,
    skip = skip,
    sheets_df = x$sheets,
    nr_df = x$named_ranges
  )
  if (!is.null(range_spec$named_range)) {
    gs4_abort("{.fun range_speedread} cannot work with a named range.")
  }
  if (!is.null(range_spec$cell_limits)) {
    range_spec$cell_range <- as_sheets_range(range_spec$cell_limits)
  }
  if (!is.null(range_spec$cell_range)) {
    params[["range"]] <- range_spec$cell_range
    range_msg <- ", range {.range {range_spec$cell_range}}"
  }
  if (!is.null(range_spec$sheet_name)) {
    s <- lookup_sheet(range_spec$sheet_name, sheets_df = x$sheets)
    params[["gid"]] <- s$id
    sheet_msg <- ", sheet {.w_sheet {range_spec$sheet_name}}"
  }
  msg <- glue(
    "
    Reading from {.s_sheet {x$name}}<<sheet_msg>><<range_msg>>.",
    .open = "<<",
    .close = ">>"
  )
  gs4_bullets(c(v = msg))

  token <- gs4_token() %||% list()

  req <- gargle::request_build(
    path = "spreadsheets/d/{spreadsheet_id}/{path}",
    params = params,
    base_url = "https://docs.google.com"
  )
  gs4_bullets(c(i = "Export URL: {.url {req$url}}"))

  response <- httr::GET(req$url, config = token)
  stopifnot(identical(httr::http_type(response), "text/csv"))
  readr::read_csv(httr::content(response, type = "raw"), ...)
}
