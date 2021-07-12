## this is the "cell getter" for range_read_cells() and read_sheet()
get_cells <- function(ss,
                      sheet = NULL,
                      range = NULL,
                      col_names_in_sheet = TRUE,
                      skip = 0, n_max = Inf,
                      detail_level = c("default", "full"),
                      discard_empty = TRUE) {
  ssid <- as_sheets_id(ss)

  maybe_sheet(sheet)
  check_range(range)
  check_bool(col_names_in_sheet)
  check_non_negative_integer(skip)
  check_non_negative_integer(n_max)
  detail_level <- match.arg(detail_level)
  check_bool(discard_empty)

  ## retrieve spreadsheet metadata --------------------------------------------
  x <- gs4_get(ssid)
  gs4_bullets(c(v = "Reading from {.s_sheet {x$name}}."))

  ## prepare range specification for API --------------------------------------

  ## user's range, sheet, skip --> qualified A1 range, suitable for API
  range_spec <- as_range_spec(
    range,
    sheet = sheet, skip = skip,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  # if we send no range, we get all cells from all sheets; not what we want
  effective_range <- as_A1_range(range_spec) %||% first_visible_name(x$sheets)
  gs4_bullets(c(v = "Range {.range {effective_range}}."))

  ## main GET -----------------------------------------------------------------
  resp <- read_cells_impl_(
    ssid,
    ranges = effective_range,
    detail_level = detail_level
  )
  out <- cells(resp)

  if (discard_empty) {
    # cells can be present, just because they bear a format (much like Excel)
    cell_is_empty <- map_lgl(out$cell, ~ is.null(pluck(.x, "effectiveValue")))
    out <- out[!cell_is_empty, ]
  }

  ## enforce geometry on the cell data frame ----------------------------------
  if (range_spec$shim) {
    range_spec$cell_limits <- range_spec$cell_limits %||%
      as_cell_limits(effective_range)
    out <- insert_shims(out, range_spec$cell_limits)
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

# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get
# I want a separate worker so there is a version of this available that
# accepts `fields` (or `includeGridData`), yet I don't want a user-facing
# function that exposes those details
read_cells_impl_ <- function(ssid,
                             ranges,
                             fields = NULL,
                             detail_level = c("default", "full")) {
  # there are 2 ways to control the level of detail re: cell data:
  #   1. Supply a field mask. What we currently do.
  #   2. Set `includeGridData` to true. This gets *everything* about the
  #      Spreadsheet and the Sheet(s). So far, this seems like TMI.
  detail_level <- match.arg(detail_level)
  cell_mask <- switch(
    detail_level,
    "default" = ".values(effectiveValue,formattedValue,effectiveFormat.numberFormat)",
    "full" = ""
  )
  default_fields <- c(
    "spreadsheetId", "properties.title",
    "sheets.properties(sheetId,title)",
    glue("sheets.data(startRow,startColumn,rowData{cell_mask})")
  )
  fields <- fields %||% glue_collapse(default_fields, sep = ",")

  req <- request_generate(
    "sheets.spreadsheets.get",
    params = list(
      spreadsheetId = ssid,
      ranges = ranges,
      fields = fields
    )
  )
  raw_resp <- request_make(req)
  gargle::response_process(raw_resp)
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

  # TODO: make this an as_tibble method?
  # TODO: deal with the merged cells
  # TODO: ensure this returns integer columns where appropriate

  row_data <- x %>%
    pluck("sheets", 1, "data", 1, "rowData") %>%
    map("values")

  ## an empty row can be present as an explicit NULL
  ## within a non-empty row, an empty cell can be present as list()
  ## rows are ragged and appear to end at the last non-empty cell
  row_lengths <- map_int(row_data, length)
  n_rows <- length(row_data)

  tibble::tibble(
    row = rep.int(
      seq.int(from = start_row, length.out = n_rows),
      times = row_lengths
    ),
    col = as.integer(start_column + sequence(row_lengths) - 1),
    cell = purrr::flatten(row_data)
  )
}

insert_shims <- function(df, cell_limits) {
  ## emulating behaviour of readxl
  if (nrow(df) == 0) {
    return(df)
  }
  df$row <- as.integer(df$row)
  df$col <- as.integer(df$col)

  ## 1-based indices, referring to cell coordinates in the spreadsheet
  start_row <- cell_limits$ul[[1]]
  end_row   <- cell_limits$lr[[1]]
  start_col <- cell_limits$ul[[2]]
  end_col   <- cell_limits$lr[[2]]

  shim_up    <- notNA(start_row) && start_row < min(df$row)
  shim_left  <- notNA(start_col) && start_col < min(df$col)
  shim_down  <- notNA(end_row)   &&   end_row > max(df$row)
  shim_right <- notNA(end_col)   &&   end_col > max(df$col)

  ## add placeholder to establish upper left corner
  if (shim_up || shim_left) {
    df <- tibble::add_row(
      df,
      row = start_row %|% min(df$row),
      col = start_col %|% min(df$col),
      cell = list(list()),
      .before = 1
    )
  }

  ## add placeholder to establish lower right corner
  if (shim_down || shim_right) {
    df <- tibble::add_row(
      df,
      row = end_row %|% max(df$row),
      col = end_col %|% max(df$col),
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
