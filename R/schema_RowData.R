as_RowData <- function(df, col_names = TRUE) {
  df_cells <- modify(df, as_CellData)
  df_rows <- pmap(df_cells, list)
  if (col_names) {
    df_rows <- c(list(as_CellData(names(df))), df_rows)
  }
  map(df_rows, ~ list(values = unname(.x)))
}
