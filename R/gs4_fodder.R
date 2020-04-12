#' Create useful spreadsheet filler
#'
#' Creates a data frame that is useful for filling a spreadsheet, when you just
#' need a sheet to experiment with. The data frame has `n` rows and `m` columns
#' with these properties:
#' * Column names match what Sheets displays: "A", "B", "C", and so on.
#' * Inner cell values reflect the coordinates where each value will land in
#'   the sheet, in A1-notation. So the first row is "B2", "C2", and so on.
#' Note that this `n`-row data frame will occupy `n + 1` rows in the sheet,
#' because the column names occupy the first row.
#'
#' @param n Number of rows.
#' @param m Number of columns.
#'
#' @return A data frame of character vectors.
#' @export
#'
#' @examples
#' gs4_fodder()
#' gs4_fodder(5, 3)
gs4_fodder <- function(n = 10, m = n) {
  columns <- LETTERS[seq_len(m)]
  names(columns) <- columns
  f <- function(number, letter) paste0(letter, number)
  as.data.frame(
    outer(seq_len(n) + 1, columns, f),
    stringsAsFactors = FALSE
  )
}
