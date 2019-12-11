#  input: a named list, usually an instance of googlesheets4_schema_Spreadsheet
# output: instance of googlesheets4_spreadsheet, which is actually useful
new_googlesheets4_spreadsheet <- function(x = list()) {
  ours_theirs <- list(
    spreadsheet_id  = "spreadsheetId",
    spreadsheet_url = "spreadsheetUrl",
    name            = list("properties", "title"),
    locale          = list("properties", "locale"),
    time_zone       = list("properties", "timeZone")
  )
  out <- map(ours_theirs, ~ pluck(x, !!!.x))

  if (!is.null(x$sheets)) {
    sheets <- map(x$sheets, ~ new("Sheet", !!!.x))
    sheets <- map(sheets, tibblify)
    out$sheets <- do.call(rbind, sheets)
  }

  if (!is.null(x$namedRanges)) {
    named_ranges <- map(x$namedRanges, ~ new("NamedRange", !!!.x))
    named_ranges <- map(named_ranges, tibblify)
    named_ranges <- do.call(rbind, named_ranges)

    # if there is only 1 sheet, sheetId might not be sent!
    # https://github.com/tidyverse/googlesheets4/issues/29
    needs_sheet_id <- is.na(named_ranges$sheet_id)
    if (any(needs_sheet_id)) {
      # if sheetId is missing, I assume it's the "first" sheet
      # for some definition of "first"
      first_sheet <- which.min(out$sheets$index)
      named_ranges$sheet_id[needs_sheet_id] <- out$sheets$id[[first_sheet]]
    }
    named_ranges$sheet_name <- vlookup(
      named_ranges$sheet_id,
      data = out$sheets,
      key = "id",
      value = "name"
    )
    named_ranges$cell_range <- pmap_chr(named_ranges, make_cell_range)
    named_ranges$A1_range <- qualified_A1(
      named_ranges$sheet_name, named_ranges$cell_range
    )

    out$named_ranges <- named_ranges
  }

  structure(out, class = c("googlesheets4_spreadsheet", "list"))
}

#' @export
format.googlesheets4_spreadsheet <- function(x, ...) {

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
    col2 <- fl(c("(A1 range)", x$named_ranges$A1_range))
    meta <- c(
      meta,
      "",
      glue_data(list(col1 = col1, col2 = col2), "{col1}: {col2}")
    )
  }

  meta
}

#' @export
print.googlesheets4_spreadsheet <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}
