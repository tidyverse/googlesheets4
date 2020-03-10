#' Read Sheet as csv
#'
#' @description
#' The `export` URL supports various query parameters. We exploit `format=csv`
#' and, optionally, `gid=SHEET_ID` and/or `range=A2:D5` (`range` must really be
#' cell range in this case, not a sheet name or named range):
#'
#' ```
#' # here is the base URL:
#' https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/export
#'
#' # examples of the query part
#' ?format=csv
#' ?format=csv?range=A1_range
#' ?format=csv?gid=SHEET_ID
#' ?format=csv?range=A1_range?gid=SHEET_ID
#' ```
#'
#' Handy gist of various query parameters that work for the `export` URL, with
#' special attention to the PDF format:
#'   * <https://gist.github.com/Spencer-Easton/78f9867a691e549c9c70>
#'
#' The "Chart Tools datasource protocol" is another way to access values in
#' Sheets, designed to make Sheets play nicely with the Google Charts API. We
#' can use the datasource URL as another way to get data as CSV (or JSON, etc.).
#' It is more powerful than the `export` URL.
#'
#' Stack Overflow answer that links to various pages re: the "Chart Tools
#' datasource protocol"
#'   * <https://stackoverflow.com/a/33727897/2825349>
#'
#' The most important link is about "Query Source Ranges":
#'   * <https://developers.google.com/chart/interactive/docs/spreadsheets#queryurlformat>
#'
#' Examples of such URLs
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
#' @param ... Passed along to `vroom::vroom()`.
#'
#' @return
#' @export
#'
#' @examples
#' # Using the large NBA sheet from
#' # https://github.com/tidyverse/googlesheets4/issues/122
#' spreadsheet_id <- "1mnWcn7bd7obaXd05rnXrEtgzMBLdy7ctsYvlQM52W00"
#' (ss <- as_sheets_id(spreadsheet_id))
#' (df <- sheets_speedread(
#'   ss,
#'   col_types = vroom::cols(
#'     idTeam = vroom::col_character(),
#'     idPlayer = vroom::col_character()
#'   ),
#'   .url = "datasource"
#' ))
#'
#' library(bench)
#' bnch <- bench::mark(
#'   sheets_speedread(ss, .url = "export"),
#'   sheets_speedread(ss, .url = "datasource"),
#'   #readr::read_csv(nba_export_url),
#'   #readr::read_csv(nba_datasource_url),
#'   iterations = 1,
#'   check = FALSE
#' )
#' bnch
sheets_speedread <- function(ss,
                             sheet = NULL,
                             range = NULL,
                             skip = 0,
                             ...,
                             .url = c("export", "datasource")) {
  if (!requireNamespace("vroom", quietly = TRUE)) {
    stop_glue("The vroom package must be installed to use {bt('sheets_speedread()'}")
  }

  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_range(range)
  check_non_negative_integer(skip)
  .url <- match.arg(.url)

  # retrieve spreadsheet metadata ----------------------------------------------
  x <- sheets_get(ssid)

  # prepare params -------------------------------------------------------------
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

  if (.url == "export") {
    params[["format"]] <- "csv"
    params[["req_path"]] <- "export"
  }
  if (.url == "datasource") {
    params[["tqx"]] <- "out:csv"
    params[["req_path"]] <- "gviz/tq"
  }
  req <- gargle::request_build(
    path = "spreadsheets/d/{spreadsheet_id}/{req_path}",
    method = "GET",
    params = params,
    token = sheets_token(),
    base_url = "https://docs.google.com"
  )
  # httr::with_config(
  #   req$token,
  #   vroom::vroom(req$url, ...)
  # )
  vroom::vroom(req$url, delim = ",", ...)
}
