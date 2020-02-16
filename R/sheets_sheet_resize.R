#' Change the size of a (work)sheet
#'
#' Changes the number of rows and/or columns in a (work)sheet.
#'
#' @template ss
#' @eval param_sheet(action = "resize")
#' @param nrow,ncol Desired number of rows or columns, respectively. The default
#'   of `NULL` means to leave unchanged.
#' @param Logical, indicating whether to impose `nrow` and `ncol` exactly or to
#'   treat them as lower bounds. If `exact = FALSE`, `sheets_sheet_resize()` can
#'   only add cells. If `exact = TRUE`, cells can be deleted and their contents
#'   are lost.
#'
#' @template ss-return
#' @export
#' @family worksheet functions
#' @seealso Makes an `UpdateSheetPropertiesRequest`:
#'   * <# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest>
#'
#' @examples
#' if (sheets_has_token()) {
#'   # create a Sheet with the default initial worksheet
#'   (ss <- sheets_create("sheets-resize-demo"))
#'
#'   # see (work)sheet dims
#'   sheets_sheet_data(ss)
#'
#'   # no resize
#'   sheets_sheet_resize(ss, nrow = 2, ncol = 6)
#'
#'   # reduce sheet size
#'   sheets_sheet_resize(ss, nrow = 5, ncol = 7, exact = TRUE)
#'
#'   # add rows
#'   sheets_sheet_resize(ss, nrow = 7)

#'   # add columns
#'   sheets_sheet_resize(ss, ncol = 10)
#'
#'   # add both
#'   sheets_sheet_resize(ss, nrow = 9, ncol = 12)
#'
#'   # re-inspect (work)sheet dims
#'   sheets_sheet_data(ss)
#'
#'   googledrive::drive_rm(ss)
#' }
sheets_sheet_resize <- function(ss,
                                sheet = NULL,
                                nrow = NULL, ncol = NULL,
                                exact = FALSE) {
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  maybe_non_negative_integer(nrow)
  maybe_non_negative_integer(ncol)
  check_bool(exact)

  x <- sheets_get(ssid)
  s <- lookup_sheet(sheet, sheets_df = x$sheets)
  message_glue("Resizing sheet {sq(s$name)} in {sq(x$name)}")

  nrow_sheet <- vlookup(s$id, x$sheets, key = "id", value = "grid_rows")
  ncol_sheet <- vlookup(s$id, x$sheets, key = "id", value = "grid_columns")

  new_dims <- c(
    make_dim_patch(nrow_sheet, nrow, "nrow", exact),
    make_dim_patch(ncol_sheet, ncol, "ncol", exact)
  )

  if (length(new_dims) == 0) {
    message_glue("No need to change existing dims ({nrow_sheet} x {ncol_sheet})")
    return(invisible(ssid))
  }

  message_glue(
    "Changing dims: ({nrow_sheet} x {ncol_sheet}) --> ({new_dims$nrow %||% nrow_sheet} x {new_dims$ncol %||% ncol_sheet})"
  )

  bureq <- bureq_set_grid_properties(
    sheetId = s$id,
    nrow = new_dims$nrow, ncol = new_dims$ncol,
    frozenRowCount = NULL
  )

  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(bureq),
      responseIncludeGridData = FALSE
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}

make_dim_patch <- function(current, target, nm, exact) {
  out <- list()
  if (is.null(target)) {
    return(out)
  }
  patch_needed <- (isTRUE(exact) && current != target) || current < target
  if (patch_needed) {
    out[[nm]] <- target
  }
  out
}
