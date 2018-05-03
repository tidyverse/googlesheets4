## this is the "cell getter" for sheets_cells() and read_sheet()
get_cells <- function(ss,
                      sheet = NULL,
                      range = NULL,
                      col_names_in_sheet = TRUE,
                      skip = 0, n_max = Inf) {
  ssid <- as_sheets_id(ss)

  ## sheet and range are vetted below, inside standardise_range()
  ## TODO: check col_names_in_sheet
  check_non_negative_integer(skip)
  check_non_negative_integer(n_max)

  ## retrieve spreadsheet metadata --------------------------------------------
  x <- sheets_get(ssid)
  message_glue("Reading from {sq(x$name)}")

  ## prepare range specification for API --------------------------------------

  ## user's sheet, range --> our sheet, nominal_range
  ## TODO: provide full cellranger-style flexibility
  parsed_range <- standardise_range(sheet, range, x$sheets)
  sheet <- parsed_range$sheet
  nominal_range <- parsed_range$range
  shim <- !is.null(nominal_range)

  ## convert "skip 4 rows" into the range '4:ROW_MAX'
  if (!shim && skip > 0) {
    nominal_range <- range_from_skip(skip, sheet, x$sheets)
  }

  api_range <- as.character(
    glue_collapse(c(sq_escape(sheet), nominal_range), sep = "!")
  )
  message_glue("Range {dq(api_range)}")

  ## main GET -----------------------------------------------------------------
  resp <- sheets_cells_impl_(
    ssid,
    ranges = api_range
  )
  out <- cells(resp)

  ## enforce geometry on the cell data frame ----------------------------------
  if (shim) {
    out <- insert_shims(out, nominal_range)
    ## guarantee:
    ## every row and every column spanned by user's range is represented by at
    ## least one cell, (could be placeholders w/ no content from API, though)
    ##
    ## NOTE:
    ## this does NOT imply that every spreadsheet cell spanned by user's range
    ## is represented by a cell in 'out' --> rectangling must be robust to holes
  } else if (n_max < Inf) {
    out <- enforce_n_max(out, n_max, col_names_in_sheet)
  }
  out

}

## I want a separate worker so there is a version of this available that
## accepts `fields`, yet I don't want a user-facing function with `fields` arg
sheets_cells_impl_ <- function(ssid,
                               ranges,
                               fields = NULL) {
  fields <- fields %||% "spreadsheetId,properties,sheets.data(startRow,startColumn),sheets.data.rowData.values(formattedValue,userEnteredValue,effectiveValue,effectiveFormat.numberFormat)"

  req <- request_generate(
    "spreadsheets.get",
    params = list(
      spreadsheetId = ssid,
      ranges = ranges,
      fields = fields
    )
  )
  raw_resp <- request_make(req)
  response_process(raw_resp)
}

## input: an instance of Spreadsheet
## https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet
## output: a tibble with one row per non-empty cell (row, column, cell)
cells <- function(x = list()) {
  ## identify upper left cell of the rectangle
  ## values are absent in the response if equal to 0, hence the default
  ## return values are zero-based, hence we add 1
  start_row <- (pluck(x, "sheets", 1, "data", 1, "startRow") %||% 0) + 1
  start_column <- (pluck(x, "sheets", 1, "data", 1, "startColumn") %||% 0) + 1

  ## TODO: deal with the merged cells

  row_data <- x %>%
    pluck("sheets", 1, "data", 1, "rowData") %>%
    map("values")

  ## an empty row can be present as an explicit NULL
  ## within a non-empty row, an empty cell can be present as list()
  ## rows are ragged and appear to end at the last non-empty cell
  row_lengths <- map_int(row_data, length)
  n_rows <- length(row_data)

  out <- tibble::tibble(
    row = rep.int(
      seq.int(from = start_row, length.out = n_rows),
      times = row_lengths
    ),
    col = start_column + sequence(row_lengths) - 1,
    cell = purrr::flatten(row_data)
  )

  ## cells can be present, just because they bear a format (much like Excel)
  ## as in readxl, we only load cells with content
  cell_is_empty <- map_lgl(out$cell, ~ is.null(pluck(.x, "effectiveValue")))
  out[!cell_is_empty, ]
}


range_from_skip <- function(skip = 0, sheet = NULL, sheet_df = NULL) {
  sheet_i <- match(sheet %||% NA_character_, sheet_df$name)
  max_row <- if (is.na(sheet_i)) {
    max(sheet_df$grid_rows)
  } else {
    sheet_df$grid_rows[sheet_i]
  }
  if (skip + 1 > max_row) {
    stop_glue(
      "Sheet has {max_row} rows, but {bt('skip')} is only {skip}. ",
      "Nothing to read."
    )
  }
  as.character(glue("{skip + 1}:{max_row}"))
}

insert_shims <- function(df, range) {
  cl_range <- cellranger::as.cell_limits(range)

  ## 1-based indices, referring to cell coordinates in the spreadsheet
  start_row <- cl_range$ul[[1]]
  end_row   <- cl_range$lr[[1]]
  start_col <- cl_range$ul[[2]]
  end_col   <- cl_range$lr[[2]]

  shim_up    <- start_row < min(df$row)
  shim_left  <- start_col < min(df$col)
  shim_down  <-   end_row > max(df$row)
  shim_right <-   end_col > max(df$col)

  ## add placeholder to establish upper left corner
  if (shim_up || shim_left) {
    df <- tibble::add_row(
      df,
      row = start_row,
      col = start_col,
      cell = list(list()),
      .before = 1
    )
  }

  ## add placeholder to establish lower right corner
  if (shim_down || shim_right) {
    df <- tibble::add_row(
      df,
      row = end_row,
      col = end_col,
      cell = list(list())
    )
  }

  df
}

enforce_n_max <- function(out, n_max, col_names_in_sheet) {
  row_max <- realize_n_max(n_max, out$row, col_names_in_sheet)
  out[out$row <= row_max, ]
}

realize_n_max <- function(n_max, rows, col_names_in_sheet) {
  start_row <- min(rows)
  end_row <- max(rows)
  n_read <- end_row - start_row + 1
  to_read <- n_max + col_names_in_sheet
  if (n_read <= to_read) {
    Inf
  } else {
    start_row + to_read - 1
  }
}
