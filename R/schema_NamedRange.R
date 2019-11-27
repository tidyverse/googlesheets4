#' @export
tibblify.googlesheets4_NamedRange <- function(x, ...) {
  grid_range <- new("GridRange", !!!pluck(x, "range"))
  grid_range <- tibblify(grid_range)

  tibble::tibble(
    name = glean_chr(x, "name"),
    id   = glean_chr(x, "namedRangeId"),
    !!!grid_range
  )
}
