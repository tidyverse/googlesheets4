#' @export
tibblify.googlesheets4_Sheet <- function(x, ...) {
  out <- tibblify(new("SheetProperties", !!!x$properties))
  # TODO: come back to deal with `data`
  tibble::add_column(out, data = list(NULL))
}

as_Sheet <- function(df, name) {
  UseMethod("as_Sheet")
}

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
      # TODO: not making room for col_names here yet
      gridProperties = list(rowCount = nrow(df), columnCount = ncol(df))
    ),
    data = list( # an array of instances of GridData
      list(
        rowData = as_RowData(df) # an array of instances of RowData
      )
    )
  )
}

as_RowData <- function(df) {
  df_rows <- transpose(df)
  make_row <- function(x) {
    map(x, ~ list(userEnteredValue = list(stringValue = as.character(.x))))
  }
  map(df_rows, ~ list(values = make_row(unname(.x))))
  # list(
  #   list(     # row 1
  #     values = list(
  #       list( # row 1 cell 1
  #         userEnteredValue = list(stringValue = "A1")
  #       ),
  #       list( # row 1 cell 2
  #         userEnteredValue = list(stringValue = "B1")
  #       )
  #     )
  #   ),
  #   list(   # row 2
  #     values = list(
  #       list( # row 2 cell 1
  #         userEnteredValue = list(stringValue = "A2")
  #       ),
  #       list( # row 2 cell 2
  #         userEnteredValue = list(stringValue = "B2")
  #       )
  #     )
  #   )
  # )
}
