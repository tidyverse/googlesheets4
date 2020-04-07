#' @export
as_tibble.googlesheets4_schema_Sheet <- function(x, ...) {
  out <- as_tibble(new("SheetProperties", !!!x$properties))
  # TODO: come back to deal with `data`
  tibble::add_column(out, data = list(NULL))
}

as_Sheet <- function(x, ...) {
  UseMethod("as_Sheet")
}

#' @export
as_Sheet.default <- function(x, ...) {
  stop_glue(
    "Don't know how to make an instance of {bt('Sheet')} from something of ",
    "class {class_collapse(x)}."
  )
}

#' @export
as_Sheet.NULL <- function(x, ...) {
  return(new(id = "Sheet", properties = NULL))
}

#' @export
as_Sheet.character <- function(x, ...) {
  check_length_one(x)
  new(
    "Sheet",
    properties = new(id = "SheetProperties", title = x),
    ...
  )
}

#' @export
as_Sheet.data.frame <- function(x, ...) {
  # do first, so that gridProperties derived from x overwrite anything passed
  # via `...`
  sp <- new("SheetProperties", ...)

  sp <- patch(
    sp,
    gridProperties = new(
      "GridProperties",
      rowCount       = nrow(x) + 1, # make room for column names
      columnCount    = ncol(x),
    )
  )

  new(
    "Sheet",
    properties = sp,
    data = list( # an array of instances of GridData
      list(
        rowData = as_RowData(x) # an array of instances of RowData
      )
    )
  )
}
