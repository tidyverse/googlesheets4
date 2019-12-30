#' @param n_max Maximum number of data rows to parse into the returned tibble.
#'   Trailing empty rows are automatically skipped, so this is an upper bound on
#'   the number of rows in the result. Ignored if `range` is given. `n_max` is
#'   imposed locally, after reading all non-empty cells, so, if speed is an
#'   issue, it is better to use `range`.
