#' get a sheet
#'
#' @param ss Something that uniquely identifies a Google Sheet. Processed
#'   through [as_sheets_id()].
#'
#' @return something
#' @export
#'
#' @examples
#' sheets_get(sheets_example("design-dates"))
#' sheets_get(sheets_example("gapminder"))
#' sheets_get(sheets_example("mini-gap"))
#' sheets_get(sheets_example("ff"))
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
    "spreadsheets.get",
    params = list(
      spreadsheetId = ssid,
      fields = fields
    )
  )
  raw_resp <- request_make(req)
  response_process(raw_resp)
}

## input: an instance of Spreadsheet, in Sheets API v4 sense, as a list
## https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet
## output: ?a list or an instance of some TBD S3 class?
sheets_spreadsheet <- function(x = list()) {
  ours_theirs <- list(
     spreadsheet_id = "spreadsheetId",
    spreadsheet_url = "spreadsheetUrl",
               name = list("properties", "title"),
             locale = list("properties", "locale"),
          time_zone = list("properties", "timeZone"),
             sheets = integer(),
       named_ranges = integer()
  )
  out <- map(ours_theirs, ~ pluck(x, .x))

  if (!is.null(x$sheets)) {
    p <- map(x$sheets, "properties")
    out$sheets <- tibble::tibble(
              name = map_chr(p, "title"),
             index = map_int(p, "index"),
                id = map_chr(p, "sheetId"),
              type = map_chr(p, "sheetType"),
         grid_rows = map_int(p, c("gridProperties", "rowCount"), .default = NA),
      grid_columns = map_int(p, c("gridProperties", "columnCount"), .default = NA)
    )
  }

  if (!is.null(x$namedRanges)) {
    nr <- x$namedRanges
    out$named_ranges <- tibble::tibble(
              name = map_chr(nr, "name"),
             range = NA_character_,
                id = map_chr(nr, "namedRangeId"),
          sheet_id = map_chr(nr, c("range", "sheetId")),
        sheet_name = NA_character_,
        ## API sends zero-based row and column
        ##   => we add one
        ## API indices are half-open, i.e. [start, end)
        ##   => we substract one from end_[row|column]
        ## net effect
        ##   => we add one to start_[row|column] but not to end_[row|column]
         start_row = map_int(nr, c("range", "startRowIndex")) + 1L,
           end_row = map_int(nr, c("range", "endRowIndex")),
      start_column = map_int(nr, c("range", "startColumnIndex")) + 1L,
        end_column = map_int(nr, c("range", "endColumnIndex"))
    )
    out$named_ranges$sheet_name <- vlookup(
      out$named_ranges$sheet_id,
      data = out$sheets,
      key = "id",
      value = "name"
    )
    out$named_ranges$range <- purrr::pmap_chr(out$named_ranges, make_range)
  }

  out
}

make_range <- function(start_row, end_row, start_column, end_column,
                       sheet_name, ...) {
  cl <- cellranger::cell_limits(
    ul = c(start_row, start_column),
    lr = c(end_row, end_column),
    sheet = sq(sheet_name)
  )
  cellranger::as.range(cl, fo = "A1")
}
