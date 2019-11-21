#  input: instance of Spreadsheet, in the Sheets API sense, as a named list
# output: instance of sheets_Spreadsheet, which is how I want to hold this info
sheets_Spreadsheet <- function(x = list()) {
  ours_theirs <- list(
    spreadsheet_id  = "spreadsheetId",
    spreadsheet_url = "spreadsheetUrl",
    name            = list("properties", "title"),
    locale          = list("properties", "locale"),
    time_zone       = list("properties", "timeZone")
  )
  out <- map(ours_theirs, ~ pluck(x, !!!.x))

  if (!is.null(x$sheets)) {
    sheets <- map(x$sheets, tibblify_Sheet)
    out$sheets <- do.call(rbind, sheets)
  }

  if (!is.null(x$namedRanges)) {
    # TODO: refactor in terms of a to-be-created sheets_NamedRange()? changes
    # the angle of attack to NamedRange-wise, whereas here I work column-wise
    nr <- x$namedRanges
    out$named_ranges <- tibble::tibble(
      name         = map_chr(nr, "name"),
      range        = NA_character_,
      id           = map_chr(nr, "namedRangeId"),
      # if there is only 1 sheet, sheetId might not be sent!
      # https://github.com/tidyverse/googlesheets4/issues/29
      sheet_id     = map_chr(nr, c("range", "sheetId"), .default = NA),
      sheet_name   = NA_character_,
      # TODO: extract into functions re: GridRange?
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
    no_sheet <- is.na(out$named_ranges$sheet_id)
    if (any(no_sheet)) {
      # if no associated sheetId, assume it's the first (only?) sheet
      # https://github.com/tidyverse/googlesheets4/issues/29
      out$named_ranges$sheet_id[no_sheet] <- out$sheets$id[[1]]
    }
    out$named_ranges$sheet_name <- vlookup(
      out$named_ranges$sheet_id,
      data = out$sheets,
      key = "id",
      value = "name"
    )
    out$named_ranges$range <- pmap_chr(out$named_ranges, make_range)
  }

  structure(out, class = c("sheets_Spreadsheet", "list"))
}

#' @export
format.sheets_Spreadsheet <- function(x, ...) {

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
  meta <- c(
    meta,
    "",
    glue_data(list(col1 = col1, col2 = col2), "{col1}: {col2}")
  )

  if (!is.null(x$named_ranges)) {
    col1 <- fr(c("(Named range)", x$named_ranges$name))
    col2 <- fl(c("(A1 range)", x$named_ranges$range))
    meta <- c(
      meta,
      "",
      glue_data(list(col1 = col1, col2 = col2), "{col1}: {col2}")
    )
  }

  meta
}

#' @export
print.sheets_Spreadsheet <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}
