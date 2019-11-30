# https://developers.google.com/sheets/api/samples/formatting#format_a_header_row
# returns: an instance of RepeatCellRequest
bureq_header_row <- function(row = 1,
                             sheetId = NULL,
                             backgroundColor = 0.92,
                             horizontalAlignment = "CENTER",
                             bold = TRUE) {
  row <- row - 1 # indices are zero-based; intervals are half open: [start, end)
  grid_range <- new("GridRange", startRowIndex = row, endRowIndex = row + 1)
  if (!is.null(sheetId)) {
    grid_range <- patch(grid_range, sheetId = sheetId)
  }

  cell_format <- new(
    "CellFormat",
    horizontalAlignment = horizontalAlignment,
    backgroundColor = new(
      "Color",
      # I want a shade of grey
      red   = backgroundColor,
      green = backgroundColor,
      blue  = backgroundColor
    ),
    textFormat = new(
      "TextFormat",
      bold = bold
    )
  )
  cell_data <- new("CellData", userEnteredFormat = cell_format)
  top_field <- names(cell_data)
  fields <- as.character(glue(
    "{top_field}({glue_collapse(names(pluck(cell_data, top_field)), sep = ',')})"
  ))

  new(
    "RepeatCellRequest",
    range = grid_range,
    cell = cell_data,
    fields = fields
  )
}

# https://developers.google.com/sheets/api/samples/formatting#format_a_header_row
# returns: an instance of RepeatCellRequest
bureq_frozen_rows <- function(n = 1, sheetId) {
  new(
    "UpdateSheetPropertiesRequest",
    properties = new(
      "SheetProperties",
      sheetId = sheetId,
      gridProperties = list(
        frozenRowCount = n
      )
    ),
    fields = "gridProperties.frozenRowCount"
  )
}

# based on this, except I clear everything by sending 'fields = "*"'
# https://developers.google.com/sheets/api/samples/sheet#clear_a_sheet_of_all_values_while_preserving_formats
# returns: an instance of RepeatCellRequest
bureq_clear_sheet <- function(sheetId) {
  new(
    "RepeatCellRequest",
    range = new("GridRange", sheetId = sheetId),
    fields = "*"
  )
}

# https://developers.google.com/sheets/api/samples/rowcolumn#append_empty_rows_or_columns
# https://developers.google.com/sheets/api/samples/rowcolumn#delete_rows_or_columns
# returns: a list of 0 or more instances of RepeatCellRequest
bureq_set_dimensions <- function(sheetId,
                                 nrow = NULL, ncol = NULL,
                                 sheets_df) {
  m <- match(sheetId, sheets_df$id)
  if (is.na(m)) {
    stop("Can't find sheet with this id: {sq(sheetId)}")
  }
  dims <- as.list(sheets_df[m, c("grid_rows", "grid_columns")])
  nrow_before <- dims$grid_rows
  ncol_before <- dims$grid_columns
  if (nrow == nrow_before && ncol == ncol_before) {
    return()
  }

  out <- list()

  truncate <- function(dimension, n) {
    # The Deal ----
    #     nrow_before: 6
    #               n: 3
    # row (or column): 1   2   3   |   4   5   6
    # first row to delete is row 4 = n + 1
    # BUT Sheets API indexes from zero
    # so startIndex = n + 1 - 1 = n
    list(list(deleteDimension = new("DeleteDimensionRequest",
                                    range = new(
                                      "DimensionRange",
                                      sheetId = sheetId,
                                      dimension = dimension,
                                      startIndex = n
                                      # empirically, it seems like you don't need
                                      # to specify endIndex, but I can't find any
                                      # documentation of that
                                    )
    )))
  }

  if (nrow < nrow_before) {
    out <- c(out, truncate("ROWS", nrow))
  }
  if (ncol < ncol_before) {
    out <- c(out, truncate("COLUMNS", ncol))
  }

  extend <- function(dimension, n, n_before) {
    # The Deal ----
    #         n_before: 3
    #                n: 6
    #  row (or column): 1   2   3   |   4   5   6  (7)
    #                   0   1   2   |   3   4   5  (6)
    #
    # first row we need to create is n_before + 1 = 4
    # BUT Sheets API indexes from zero
    # so startIndex = n_before + 1 - 1 = n_before = 3
    #
    # last row we need to create is n = 6
    # BUT Sheets API indexes from zero
    # so you might think we send n - 1 = 5
    # BUT Sheets intervals are half open on the right
    # so endIndex = n - 1 + 1 = n = 6
    list(list(insertDimension = new("InsertDimensionRequest",
                                    range = new(
                                      "DimensionRange",
                                      sheetId = sheetId,
                                      dimension = dimension,
                                      startIndex = n_before,
                                      endIndex = n
                                    ),
                                    # necessary in order to grow a grid
                                    inheritFromBefore = TRUE
    )))
  }

  if (nrow > nrow_before) {
    out <- c(out, extend("ROWS", nrow, nrow_before))
  }
  if (ncol > ncol_before) {
    out <- c(out, extend("COLUMNS", ncol, ncol_before))
  }
  out

}
