as_RowData <- function(df) {
  df_cells <- modify(df, as_CellData)
  df_rows <- pmap(df_cells, list)
  df_rows <- c(list(as_CellData(names(df))), df_rows)
  map(df_rows, ~ list(values = unname(.x)))
}
