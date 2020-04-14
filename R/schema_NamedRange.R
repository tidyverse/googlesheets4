#' @export
as_tibble.googlesheets4_schema_NamedRange <- function(x, ...) {
  grid_range <- new("GridRange", !!!pluck(x, "range"))
  grid_range <- as_tibble(grid_range)

  tibble::tibble(
    name = glean_chr(x, "name"),
    id   = glean_chr(x, "namedRangeId"),
    !!!grid_range
  )
}

as_NamedRange <- function(x, ...) {
  UseMethod("as_NamedRange")
}

#' @export
as_NamedRange.default <- function(x, ...) {
  stop_glue(
    "Don't know how to make an instance of {bt('NamedRange')} from something of ",
    "class {class_collapse(x)}."
  )
}

#' @export
as_NamedRange.range_spec <- function(x, ..., name) {
  new("NamedRange", name = name, range = as_GridRange(x))
}
