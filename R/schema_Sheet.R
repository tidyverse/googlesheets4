#' @export
as_tibble.googlesheets4_schema_Sheet <- function(x, ...) {
  out <- as_tibble(new("SheetProperties", !!!x$properties))
  # TODO: come back to deal with `data`
  tibble::add_column(out, data = list(NULL))
}

as_Sheet <- function(df, name) {
  UseMethod("as_Sheet")
}

#' @export
as_Sheet.default <- function(df, name) {
  stop_glue(
    "Don't know how to make an instance of {bt('Sheet')} from something of ",
    "class {class_collapse(x)}."
  )
}

#' @export
as_Sheet.data.frame <- function(df, name) {
  check_string(name)
  x <- new(
    id = "Sheet",
    properties = new(
      id = "SheetProperties",
      title = name,
      gridProperties = list(
        rowCount = nrow(df) + 1, # make room for column names
        columnCount = ncol(df),
        frozenRowCount = 1       # freeze top row
      )
    ),
    data = list( # an array of instances of GridData
      list(
        rowData = as_RowData(df) # an array of instances of RowData
      )
    )
  )
}

as_RowData <- function(df) {
  df_cells <- modify(df, as_CellData)
  df_rows <- pmap(df_cells, list)
  df_rows <- c(list(as_CellData(names(df))), df_rows)
  map(df_rows, ~ list(values = unname(.x)))
}
