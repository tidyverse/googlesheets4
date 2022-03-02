#' Freeze rows or columns in a (work)sheet
#'
#' @description
#' *Note: not yet exported.*
#'
#' Sets the number of frozen rows or column for a (work)sheet.
#'
#' @eval param_ss()
#' @eval param_sheet()
#' @param nrow,ncol Desired number of frozen rows or columns, respectively. The
#'   default of `NULL` means to leave unchanged.
#'
#' @template ss-return
#' @seealso Makes an `UpdateSheetPropertiesRequest`:
#'   * <# https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest>
#'
#' @keywords internal
#' @noRd
#'
#' @examples
#' if (gs4_has_token()) {
#'   # create a data frame to use as initial data
#'   # intentionally has lots of rows and columns
#'   dat <- gs4_fodder(25)
#'
#'   # create Sheet
#'   ss <- gs4_create("sheet-freeze-example", sheets = list(dat))
#'
#'   # look at it in the browser
#'   gs4_browse(ss)
#'
#'   # freeze first 2 columns
#'   sheet_freeze(ss, ncol = 2)
#'
#'   # clean up
#'   gs4_find("sheet-freeze-example") %>%
#'     googledrive::drive_trash()
#' }
sheet_freeze <- function(ss,
                         sheet = NULL,
                         nrow = NULL, ncol = NULL) {
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  maybe_non_negative_integer(nrow)
  maybe_non_negative_integer(ncol)

  if (is.null(nrow) && is.null(ncol)) {
    gs4_bullets(c(i = "Nothing to be done."))
    return(invisible(ssid))
  }

  dims <- c(
    if (!is.null(nrow)) cli::pluralize("{nrow} row{?s}"),
    if (!is.null(ncol)) cli::pluralize("{ncol} column{?s}")
  )
  dims <- glue_collapse(dims, sep = " and ")

  x <- gs4_get(ssid)
  s <- lookup_sheet(sheet, sheets_df = x$sheets)
  gs4_bullets(c(
    v = "Freezing {dims} on sheet {.w_sheet {s$name}} in {.s_sheet {x$name}}."
  ))

  freeze_req <- bureq_set_grid_properties(
    sheetId = s$id,
    frozenRowCount = nrow,
    frozenColumnCount = ncol
  )

  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = freeze_req
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}
