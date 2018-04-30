#' Read a Sheet into a data frame
#'
#' WIP! The main read function of this package.
#'
#' @param ss Something that uniquely identifies a Google Sheet. Processed
#'   through [as_sheets_id()].
#' @param sheet Sheet to read. Either a string (the name of a sheet), or an
#'   integer (the position of the sheet). Ignored if the sheet is specified via
#'   `range`. If neither argument specifies the sheet, defaults to the first
#'   visible sheet. *wording basically copied from readxl*
#' @param range A cell range to read from, as described in FILL THIS IN
#'   *wording basically copied copied from readxl*
#' @param col_names column names
#' @param col_types column types
#' @param na na strings
#' @param trim_ws whether to trim ws
#' @param skip rows to skip
#' @param n_max max data rows to read
#' @param guess_max max rows to consult in column typing
#'
#' @return a tibble
#' @export
#'
#' @examples
#' read_sheet(sheets_example("mini-gap"))
read_sheet <- function(ss,
                       sheet = NULL,
                       range = NULL,
                       col_names = TRUE, col_types = NULL,
                       na = "", trim_ws = TRUE,
                       skip = 0, n_max = Inf,
                       guess_max = min(1000, n_max)) {
  ## ss, sheet, range, skip, and n_max are checked inside get_cells()
  ## TODO: flesh out checks as I wire up these arguments
  ## col_names
  ## col_types
  ## na
  ## trim_ws
  check_non_negative_integer(guess_max)

  out <- get_cells(ss = ss,
                   sheet = sheet, range = range,
                   has_col_names = isTRUE(col_names),
                   skip = skip, n_max = n_max)

  out
}
