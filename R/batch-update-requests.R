# https://developers.google.com/sheets/api/samples/formatting#format_a_header_row
# returns: a wrapped instance of RepeatCellRequest
bureq_header_row <- function(row = 1,
                             sheetId = NULL,
                             backgroundColor = 0.92,
                             horizontalAlignment = "CENTER",
                             bold = TRUE) {
  row <- row - 1 # indices are zero-based; intervals are half open: [start, end)
  grid_range <- new(
    "GridRange",
    startRowIndex = row,
    endRowIndex = row + 1,
    sheetId = sheetId
  )

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
  cell_data <- new_CellData(userEnteredFormat = cell_format)
  # hard-coding because we really do want to reset child properties not
  # explicitly set here
  # example: TextFormat's other children, like fontFamily or underline
  # example: Color's other child, alpha
  fields <- "userEnteredFormat(horizontalAlignment,backgroundColor,textFormat)"

  list(repeatCell = new(
    "RepeatCellRequest",
    range = grid_range,
    cell = cell_data,
    fields = fields
  ))
}

# based on this, except I clear everything by sending 'fields = "*"'
# https://developers.google.com/sheets/api/samples/sheet#clear_a_sheet_of_all_values_while_preserving_formats
# returns: a wrapped instance of RepeatCellRequest
bureq_clear_sheet <- function(sheetId) {
  list(repeatCell = new(
    "RepeatCellRequest",
    range = new("GridRange", sheetId = sheetId),
    fields = "*"
  ))
}

# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest
bureq_set_grid_properties <- function(sheetId,
                                      nrow = NULL, ncol = NULL,
                                      frozenRowCount = 1,
                                      frozenColumnCount = NULL) {
  gp <- new("GridProperties", rowCount = nrow, columnCount = ncol)
  if (!is.null(frozenRowCount) && frozenRowCount > 0) {
    gp <- patch(gp, frozenRowCount = frozenRowCount)
  }
  if (!is.null(frozenColumnCount) && frozenColumnCount > 0) {
    gp <- patch(gp, frozenColumnCount = frozenColumnCount)
  }
  if (length(gp) == 0) {
    return(NULL)
  }

  sp <- new("SheetProperties", sheetId = sheetId, gridProperties = gp)
  list(updateSheetProperties = new(
    "UpdateSheetPropertiesRequest",
    properties = sp,
    fields = gargle::field_mask(sp)
  ))
}

# https://developers.google.com/sheets/api/samples/rowcolumn#automatically_resize_a_column
# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#AutoResizeDimensionsRequest
bureq_auto_resize_dimensions <- function(sheetId,
                                         dimension = c("COLUMNS", "ROWS"),
                                         start = NULL,
                                         end = NULL) {
  dimension <- match.arg(dimension)
  # https://developers.google.com/sheets/api/reference/rest/v4/DimensionRange
  # A range along a single dimension on a sheet. All indexes are zero-based.
  # Indexes are half open: the start index is inclusive and the end index is
  # exclusive. Missing indexes indicate the range is unbounded on that side.
  dimension_range <- new(
    "DimensionRange",
    sheetId = sheetId,
    dimension = dimension
  )
  if (!is.null(start) && notNA(start)) {
    check_non_negative_integer(start)
    dimension_range <- patch(dimension_range, startIndex = start - 1)
  }
  if (!is.null(end) && notNA(end)) {
    check_non_negative_integer(end)
    dimension_range <- patch(dimension_range, endIndex = end)
  }
  list(autoResizeDimensions = new(
    "AutoResizeDimensionsRequest",
    dimensions = dimension_range
  ))
}
