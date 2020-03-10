#' Read Sheet as CSV
#'
#' @description
#' This function uses a quick-and-dirty method to read a Sheet that bypasses the
#' Sheets API and, instead, parses a CSV representation of the data. This can be
#' much faster than [sheets_read()] -- noticeably so for "large" spreadsheets.
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
#' Sheet, in order to support range specification.
#'
#' @inheritParams sheets_cells
#' @param .method Whether to process the CSV data with `vroom::vroom()`
#'   (default) or `readr::read_csv()`.
#' @param ... Passed along to `vroom::vroom()` or `readr::read_csv()`.
#'
#' @return A [tibble][tibble::tibble-package]
#' @export
#'
#' @examples
#' # Using the large NBA sheet from
#' # https://github.com/tidyverse/googlesheets4/issues/122
#' spreadsheet_id <- "1mnWcn7bd7obaXd05rnXrEtgzMBLdy7ctsYvlQM52W00"
#' (ss <- as_sheets_id(spreadsheet_id))
#'
#' sheets_speedread(ss, .method = "vroom")
#' sheets_speedread(ss, .method = "readr")
#'
#' # prove that we can send a cell range, sheet, and col spec through ...
#' if (require("vroom")) {
#'   sheets_speedread(
#'     sheets_example("deaths"),
#'     sheet = "other",
#'     range = "A5:F15",
#'     col_types = cols(
#'       Age = col_integer(),
#'       `Date of birth` = col_date("%m/%d/%Y"),
#'       `Date of death` = col_date("%m/%d/%Y")
#'     ),
#'     .method = "vroom"
#'   )
#' }
#'
#' if (sheets_has_token()) {
#' # write a Sheet that, by default, is NOT world-readable
#' (ss <- sheets_write(iris))
#'
#' sheets_speedread(ss, .url = "export")
#'
#' # clean up
#' googledrive::drive_trash(ss)
#' }
sheets_speedread <- function(ss,
                             sheet = NULL,
                             range = NULL,
                             skip = 0,
                             ...,
                             .method = c("vroom", "readr")) {
  .method <- match.arg(.method)
  stop_for_pkg <- function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop_glue("The {pkg} package must be installed to use {bt('sheets_speedread()'}")
    }
  }
  stop_for_pkg(.method)

  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_range(range)
  check_non_negative_integer(skip)

  x <- sheets_get(ssid)

  params <- list(
    spreadsheet_id = unclass(ssid),
    path = "export",
    format = "csv"
  )
  sheet_msg <- ""
  range_msg <- ""
  range_spec <- as_range_spec(
    range, sheet = sheet, skip = skip,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  if (!is.null(range_spec$named_range)) {
    stop_glue("{bt('sheets_speedread()'} cannot work with a named range")
  }
  if (!is.null(range_spec$cell_limits)) {
    range_spec$cell_range <- as_sheets_range(range_spec$cell_limits)
  }
  if (!is.null(range_spec$cell_range)) {
    params[["range"]] <- range_spec$cell_range
    range_msg <- glue(", range {dq(range_spec$cell_range)}")
  }
  if (!is.null(range_spec$sheet_name)) {
    s <- lookup_sheet(range_spec$sheet_name, sheets_df = x$sheets)
    params[["gid"]] <- s$id
    sheet_msg <- glue(", {dq(range_spec$sheet_name)} sheet")
  }
  message_glue("Reading from {dq(x$name)}{sheet_msg}{range_msg}")

  token <- sheets_token()

  req <- gargle::request_build(
    path = "spreadsheets/d/{spreadsheet_id}/{path}",
    params = params,
    base_url = "https://docs.google.com"
  )
  message_glue("Export URL: {req$url}")

  if (is.null(token)) {
    if (.method == "vroom") {
      return(vroom::vroom(req$url, delim = ",", ...))
    } else { # .method == "readr"
      return(readr::read_csv(req$url, ...))
    }
  }

  # we must have a token
  response <- httr::GET(req$url, config = token)
  stopifnot(identical(httr::http_type(response), "text/csv"))
  csv <- httr::content(response, as = "text", encoding = "UTF-8")
  if (.method == "vroom") {
    vroom::vroom(csv, delim = ",", ...)
  } else {
    readr::read_csv(csv, ...)
  }
}
