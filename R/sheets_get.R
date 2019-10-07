#' Get metadata for a spreadsheet
#'
#' WIP. Name should maybe involve "meta" or "metadata"? OTOH there's an obvious
#' connection to [googledrive::drive_get()].
#'
#' @inheritParams sheets_cells
#'
#' @return A list with S3 class `sheets_meta`, for printing purposes.
#' @export
#'
#' @examples
#' if (sheets_has_token()) {
#'   sheets_get(sheets_example("gapminder"))
#'   sheets_get(sheets_example("mini-gap"))
#'   sheets_get(sheets_example("deaths"))
#'   sheets_get(sheets_example("chicken-sheet"))
#' }
sheets_get <- function(ss) {
  resp <- sheets_get_impl_(as_sheets_id(ss))
  sheets_spreadsheet(resp)
}

## I want a separate worker so there is a version of this available that
## accepts `fields`, yet I don't want a user-facing function with `fields` arg
sheets_get_impl_ <- function(ssid,
                             fields = NULL) {
  fields <- fields %||% "spreadsheetId,properties,spreadsheetUrl,sheets.properties,namedRanges"
  req <- request_generate(
    "sheets.spreadsheets.get",
    params = list(
      spreadsheetId = ssid,
      fields = fields
    )
  )
  raw_resp <- request_make(req)
  gargle::response_process(raw_resp)
}

## input: an instance of Spreadsheet
## https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet
## output: a list with S3 class `sheets_meta`
sheets_spreadsheet <- function(x = list()) {
  ours_theirs <- list(
    spreadsheet_id  = "spreadsheetId",
    spreadsheet_url = "spreadsheetUrl",
    name            = list("properties", "title"),
    locale          = list("properties", "locale"),
    time_zone       = list("properties", "timeZone"),
    sheets          = integer(),
    named_ranges    = integer()
  )
  out <- map(ours_theirs, ~ pluck(x, !!!.x))

  if (!is.null(x$sheets)) {
    p <- map(x$sheets, "properties")
    out$sheets <- tibble::tibble(
      name         = map_chr(p, "title"),
      index        = map_int(p, "index"),
      id           = map_chr(p, "sheetId"),
      type         = map_chr(p, "sheetType"),
      visible      = !map_lgl(p, "hidden", .default = FALSE),
      grid_rows    = map_int(p, c("gridProperties", "rowCount"), .default = NA),
      grid_columns = map_int(p, c("gridProperties", "columnCount"), .default = NA)
    )
  }

  if (!is.null(x$namedRanges)) {
    nr <- x$namedRanges
    out$named_ranges <- tibble::tibble(
      name         = map_chr(nr, "name"),
      range        = NA_character_,
      id           = map_chr(nr, "namedRangeId"),
      sheet_id     = map_chr(nr, c("range", "sheetId")),
      sheet_name   = NA_character_,
      ## API sends zero-based row and column
      ##   => we add one
      ## API indices are half-open, i.e. [start, end)
      ##   => we substract one from end_[row|column]
      ## net effect
      ##   => we add one to start_[row|column] but not to end_[row|column]
      start_row    = map_int(nr, c("range", "startRowIndex"), .default = NA) + 1L,
      end_row      = map_int(nr, c("range", "endRowIndex"), .default = NA),
      start_column = map_int(nr, c("range", "startColumnIndex"), .default = NA) + 1L,
      end_column   = map_int(nr, c("range", "endColumnIndex"), .default = NA)
    )
    out$named_ranges$sheet_name <- vlookup(
      out$named_ranges$sheet_id,
      data = out$sheets,
      key = "id",
      value = "name"
    )
    out$named_ranges$range <- purrr::pmap_chr(out$named_ranges, make_range)
  }

  structure(out, class = c("sheets_meta", "list"))
}

#' @export
format.sheets_meta <- function(x, ...) {

  meta <- glue_data(
    x,
    "
      Spreadsheet name: {name}
                    ID: {spreadsheet_id}
                Locale: {locale}
             Time zone: {time_zone}
           # of sheets: {nrow(x$sheets)}
    ",
    .sep = "\n"
  )
  meta <- strsplit(meta, split = "\n")[[1]]

  col1 <- fr(c("(Sheet name)", x$sheets$name))
  col2 <- c(
    "(Nominal extent in rows x columns)",
    glue_data(x$sheets, "{grid_rows} x {grid_columns}")
  )
  sheets <- glue_data(list(col1 = col1, col2 = col2), "{col1}: {col2}")

  c(meta, "", sheets)
}

#' @export
print.sheets_meta <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}
