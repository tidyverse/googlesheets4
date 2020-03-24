#' Flood a range of cells
#'
#' This function "floods" a range of cells with the same value, which might be
#' *nothing* (so: clears existing value), and optionally clears any formatting.
#'
#' @template ss
#' @eval param_sheet(action = "write into")
#' @template range
#' @param cell The value to fill the cells in the `range` with. If unspecified,
#'   the default of `NULL` results in clearing the existing value.
#' @template reformat
#'
#' @template ss-return
#' @export
#' @family write functions
#' @seealso
#' Makes a `RepeatCellRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#repeatcellrequest>
#'
#' @examples
#' if (sheets_has_token()) {
#'   # create a data frame to use as initial data
#'   n <- 10
#'   columns <- LETTERS[seq_len(n)]
#'   names(columns) <- columns
#'   f <- function(number, letter) paste0(letter, number)
#'   df <- as.data.frame(outer(seq_len(n) + 1, columns, f), stringsAsFactors = FALSE)
#'
#'   # create Sheet
#'   ss <- sheets_create("sheets-flood-example", sheets = list(df))
#'
#'   # default behavior (`cell = NULL`): clear value and format
#'   sheets_flood(ss, range = "A1:B3")
#'
#'   # clear value but preserve format
#'   sheets_flood(ss, range = "C1:D3", reformat = FALSE)
#'
#'   # send new value
#'   sheets_flood(ss, range = "4:5", cell = ";-)")
#'
#'   # send formatting
#'   # WARNING: use these unexported, internal functions at your own risk!
#'   # This not (yet) officially supported, but it's possible.
#'   blue_background <- googlesheets4:::CellData(
#'     userEnteredFormat = googlesheets4:::new(
#'       "CellFormat",
#'       backgroundColor = googlesheets4:::new(
#'         "Color", red = 159/255, green = 183/255, blue = 196/255
#'       )
#'     )
#'   )
#'   sheets_flood(ss, range = "I:J", cell = blue_background)
#'
#'   # clean up
#'   googledrive::drive_trash(ss)
#' }
sheets_flood <- function(ss,
                         sheet = NULL,
                         range = NULL,
                         cell = NULL,
                         reformat = TRUE) {
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_range(range)
  check_bool(reformat)

  x <- sheets_get(ssid)
  message_glue("Editing {dq(x$name)}")

  # determine (work)sheet ------------------------------------------------------
  range_spec <- as_range_spec(
    range, sheet = sheet,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  range_spec$sheet_name <- range_spec$sheet_name %||% first_visible_name(x$sheets)
  s <- lookup_sheet(range_spec$sheet_name , sheets_df = x$sheets)
  message_glue("Editing sheet {dq(range_spec$sheet_name)}")

  # prepare cell and field mask ------------------------------------------------
  # TODO: adapt here when CellData becomes a vctrs class
  if (is_CellData(cell)) {
    fields <- gargle::field_mask(cell)
  } else {
    cell <- as_CellData(cell %||% NA)[[1]]
    fields <- if (reformat) "userEnteredValue,userEnteredFormat" else "userEnteredValue"
  }

  # form batch update request --------------------------------------------------
  repeat_req <- list(repeatCell = new(
    "RepeatCellRequest",
    range = as_GridRange(range_spec),
    cell = cell,
    fields = fields
  ))

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(repeat_req)
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}
