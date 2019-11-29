# https://developers.google.com/sheets/api/samples/formatting#format_a_header_row
# returns: an instance of RepeatCellRequest
style_header_row <- function(row = 1,
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
style_frozen_rows <- function(n = 1, sheetId) {
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
style_clear_sheet <- function(sheetId = 0) {
  new(
    "RepeatCellRequest",
    range = new("GridRange", sheetId = sheetId),
    fields = "*"
  )
}

