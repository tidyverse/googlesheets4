#' (Over)write new data into a Sheet
#'
#' @description
#' \lifecycle{experimental}
#'
#' Writes a data frame into a (work)sheet in an existing (spread)Sheet. If no
#' `sheet` is specified or if `sheet` doesn't match an existing sheet name, a
#' new sheet is created to receive the `data`. If `sheet` matches an existing
#' sheet, it is effectively overwritten. All pre-existing values, formats, and
#' dimensions of the targeted sheet are cleared and it gets new values and
#' dimensions from `data`.
#'
#' In all cases, the target sheet is styled in a specific way:
#'   * Special formatting is applied to the header row, which holds column names.
#'   * The first `skip + 1` rows are frozen (so, up to and including the header
#'     row).
#'  * Sheet dimensions are set to "shrink wrap" the `data`.
#'
#' @param data A data frame.
#' @template ss
#' @eval param_sheet(action = "write into")
#' @param skip Number of rows to leave empty before starting to write.
#'
#' @template ss-return
#' @export
#'
#' @examples
#' if (sheets_has_token()) {
#'   # create a Sheet with some initial, placeholder data
#'   ss <- sheets_create(
#'     "sheets-write-demo",
#'     sheets = list(alpha = data.frame(x = 1), omega = data.frame(x = 1))
#'   )
#'
#'   df <- data.frame(
#'     x = 1:3,
#'     y = letters[1:3]
#'   )
#'
#'   # write df into its own new sheet
#'   sheets_write(df, ss = ss)
#'
#'   # write mtcars into the sheet named 'omega'
#'   sheets_write(mtcars, ss = ss, sheet = "omega")
#'
#'   # get an overview of the sheets
#'   sheets_sheet_data(ss)
#'
#'   # view your magnificent creation in the browser
#'   # sheets_browse(ss)
#'
#'   # clean up
#'   sheets_find("sheets-write-demo") %>% googledrive::drive_rm()
#' }
write_sheet <- function(data,
                        ss,
                        sheet = NULL,
                        skip = 0) {
  data_quo <- rlang::enquo(data)
  check_data_frame(data)
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_non_negative_integer(skip)

  # retrieve spreadsheet metadata ----------------------------------------------
  x <- sheets_get(ssid)
  message_glue("Writing to {sq(x$name)}")

  # no `sheet` ... but maybe we can name the sheet after the data --------------
  if (is.null(sheet) && rlang::quo_is_symbol(data_quo)) {
    candidate <- rlang::as_name(data_quo)
    # accept proposed name iff it does not overwrite existing sheet
    if (!is.null(candidate)) {
      m <- match(candidate, x$sheets$name)
      sheet <- if (is.na(m)) candidate else NULL
    }
  }

  # initialize the batch update requests and the target sheet s ----------------
  requests <- list()
  s <- NULL

  # ensure there's a target sheet, ready to receive data -----------------------
  if (!is.null(sheet)) {
    s <- tryCatch(
      lookup_sheet(sheet, sheets_df = x$sheets),
      googlesheets4_error_sheet_not_found = function(cnd) NULL
    )
  }
  if (is.null(s)) {
    x <- sheets_sheet_add_impl_(ssid, sheet_name = sheet)
    s <- lookup_sheet(nrow(x$sheets), sheets_df = x$sheets)
  } else {
    # create request to clear the data and formatting in pre-existing sheet
    requests <- c(
      requests,
      list(bureq_clear_sheet(s$id))
    )
  }
  message_glue("Writing to sheet {dq(s$name)}")

  # create request to write data frame into sheet ------------------------------
  requests <- c(
    requests,
    prepare_df(s$id, data)
  )

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = requests,
      includeSpreadsheetInResponse = TRUE,
      responseIncludeGridData = FALSE
    )
  )
  resp_raw <- request_make(req)
  resp <- gargle::response_process(resp_raw)
  ss <- new_googlesheets4_spreadsheet(resp$updatedSpreadsheet)
  message_glue(glue_collapse(format(ss), sep = "\n"))

  invisible(ssid)
}

#' @rdname write_sheet
#' @export
sheets_write <- write_sheet
