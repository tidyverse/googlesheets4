#' @export
as_tibble.googlesheets4_schema_ProtectedRange <- function(x, ...) {
  grid_range <- new("GridRange", !!!pluck(x, "range"))
  grid_range <- as_tibble(grid_range)

  tibble::tibble(
    protected_range_id       = glean_int(x, "protectedRangeId"),
    description              = glean_chr(x, "description"),
    requesting_user_can_edit = glean_lgl(x, "requestingUserCanEdit"),
    warning_only             = glean_lgl(x, "warningOnly"),
    has_unprotected_ranges   = rlang::has_name(x, "unprotectedRanges"),
    editors                  = x$editors,
    named_range_id           = glean_chr(x, "namedRangeId"),
    !!!grid_range
  )
}
