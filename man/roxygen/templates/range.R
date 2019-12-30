#' @param range A cell range to read from. If `NULL`, all non-empty cells are
#'   read. Otherwise specify `range` as described in [Sheets A1
#'   notation](https://developers.google.com/sheets/api/guides/concepts#a1_notation)
#'   or using the helpers documented in [cell-specification]. Sheets uses
#'   fairly standard spreadsheet range notation, although a bit different from
#'   Excel. Examples of valid ranges: `"Sheet1!A1:B2"`, `"Sheet1!A:A"`,
#'   `"Sheet1!1:2"`, `"Sheet1!A5:A"`, `"A1:B2"`, `"Sheet1"`. Interpreted
#'   strictly, even if the range forces the inclusion of leading, trailing, or
#'   embedded empty rows or columns. Takes precedence over `skip`, `n_max` and
#'   `sheet`. Note `range` can be a named range, like `"sales_data"`, without
#'   any cell reference.
