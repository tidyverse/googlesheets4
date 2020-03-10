#' Read Sheet as CSV
#'
#' @description
#' This function uses a quick-and-dirty method to read a Sheet that bypasses the
#' Sheets API entirely. It can be much faster than [sheets_read()] -- noticeably
#' so for "large" spreadsheets. `sheets_speedread()` forms a special URL that
#' reads Sheet values via CSV, then sends that data through vroom or readr.
#' Here are the limitations we must accept to get faster reading:
#' * Only cell values are available, not formats.
#' * We can't target a named range as the `range`.
#' * We have no access to the data type of a cell, i.e. we don't know that it's
#'   logical, numeric, or datetime. That must be re-discovered based on the
#'   CSV data (or specified by the user).
#' * Auth and error handling have to be handled a bit differently internally,
#'   which may lead to behaviour that differs from other functions in
#'   googlesheets4.
#'
#' @section The export URL:
#'
#' The export URL supports various query parameters. We always send
#' `format=csv` and, optionally, `gid=SHEET_ID` and/or `range=A2:D5` (`range`
#' must really be cell range in this case, not a sheet name or named range):
#'
#' ```
#' # here is the base URL:
#' https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/export
#'
#' # examples of the query part
#' ?format=csv
#' ?format=csv?range=CELL_RANGE
#' ?format=csv?gid=SHEET_ID
#' ?format=csv?range=A1_range?gid=SHEET_ID
#' ```
#'
#' The export URL supports the use of a bearer token in the Authorization
#' header.
#'
#' Gist of various query parameters that work for the export URL, with special
#' emphasis on the PDF format, which doesn't help us:
#'   * <https://gist.github.com/Spencer-Easton/78f9867a691e549c9c70>
#'
#' @section The datasource URL:
#'
#' The "Chart Tools datasource protocol" is another way to access values in
#' Sheets, designed to make Sheets play nicely with the Google Charts API. We
#' can use the datasource URL as another way to get data as CSV (or JSON,
#' etc.). It is more powerful than the export URL, in that it supports an
#' entire SQL-like query language.
#'
#' The datasource URL does not appear to work with an Authorization header.
#' Instead, we must send an access token as part of the query.
#'
#' Stack Overflow answer that links to various pages re: the "Chart Tools
#' datasource protocol"
#'   * <https://stackoverflow.com/a/33727897/2825349>
#'
#' The most important link is about "Query Source Ranges":
#'   * <https://developers.google.com/chart/interactive/docs/spreadsheets#queryurlformat>
#'
#' Examples of datasource URLs
#' ```
#' # here is the base URL:
#' https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/gviz/tq
#'
#' # examples of the query part
#' ?tqx=out:csv&sheet={sheet_name}
#' ?range=A1:C4
#' ?headers=N
#' ?gid=N
#' ````
#'
#' A readr issue that demonstrates sending an Authorization header
#'   * <https://github.com/tidyverse/readr/issues/935>
#'
#' @inheritParams sheets_cells
#' @param .url Whether to use the `"export"` (default) or `"datasource"` URL.
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
#' sheets_speedread(ss, .url = "export", .method = "vroom")
#' sheets_speedread(ss, .url = "export", .method = "readr")
#' sheets_speedread(ss, .url = "datasource", .method = "vroom")
#' sheets_speedread(ss, .url = "datasource", .method = "readr")
#'
#' if (FALSE) {
#' library(bench)
#' bnch <- bench::mark(
#'   sheets_speedread(ss, .url = "export", .method = "vroom"),
#'   sheets_speedread(ss, .url = "export", .method = "readr"),
#'   sheets_speedread(ss, .url = "datasource", .method = "vroom"),
#'   sheets_speedread(ss, .url = "datasource", .method = "readr"),
#'   iterations = 5,
#'   check = FALSE
#' )
#' bnch
#' }
#'
#' # prove that we can send a cell range, sheet, and col spec through ...
#' (df <- sheets_speedread(
#'   sheets_example("deaths"),
#'   sheet = "other",
#'   range = "A5:F15",
#'   col_types = vroom::cols(
#'     Age = vroom::col_integer(),
#'     `Date of birth` = vroom::col_date("%m/%d/%Y"),
#'     `Date of death` = vroom::col_date("%m/%d/%Y")
#'   ),
#'   .method = "vroom"
#' ))
#'
#'
#' if (FALSE) {
#' # write a private Sheet
#' (ss <- sheets_write(iris))
#'
#' # read via 'export' URL (sends a bearer token)
#' sheets_speedread(ss, .url = "export")
#'
#' # read via 'datasource' URL (access token goes as query param)
#' sheets_speedread(ss, .url = "datasource")
#'
#' # clean up
#' googledrive::drive_trash(ss)
#' }
sheets_speedread <- function(ss,
                             sheet = NULL,
                             range = NULL,
                             skip = 0,
                             ...,
                             .url = c("export", "datasource"),
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
  .url <- match.arg(.url)

   x <- sheets_get(ssid)

  params <- list(spreadsheet_id = unclass(ssid))
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
    params <- c(params, range = range_spec$cell_range)
    range_msg <- glue(", range {dq(range_spec$cell_range)}")
  }
  if (!is.null(range_spec$sheet_name)) {
    s <- lookup_sheet(range_spec$sheet_name, sheets_df = x$sheets)
    params <- c(params, gid = s$id)
    sheet_msg <- glue(", {dq(range_spec$sheet_name)} sheet")
  }
  message_glue("Reading from {dq(x$name)}{sheet_msg}{range_msg}")

  token <- sheets_token()

  if (.url == "export") {
    params[["format"]] <- "csv"
    params[["req_path"]] <- "export"
  }
  if (.url == "datasource") {
    params[["tqx"]] <- "out:csv"
    params[["req_path"]] <- "gviz/tq"
    if (!is.null(token)) {
      token$auth_token$refresh()
      params[["access_token"]] <- token$auth_token$credentials$access_token
    }
  }

  req <- gargle::request_build(
    path = "spreadsheets/d/{spreadsheet_id}/{req_path}",
    method = "GET",
    params = params,
    base_url = "https://docs.google.com"
  )

  if (.url == "datasource" || is.null(token)) {
    if (.method == "vroom") {
      return(vroom::vroom(req$url, delim = ",", ...))
    } else { # .method == "readr"
      return(readr::read_csv(req$url, ...))
    }
  }

  # .url == "export" and we must have a token
  response <- httr::GET(req$url, config = token)
  stopifnot(identical(httr::http_type(response), "text/csv"))
  csv <- httr::content(response, as = "text", encoding = "UTF-8")
  if (.method == "vroom") {
    vroom::vroom(csv, delim = ",", ...)
  } else {
    readr::read_csv(csv, ...)
  }
}
