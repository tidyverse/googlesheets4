#' (Over)write new data into a Sheet
#'
#' @description
#' \lifecycle{experimental}
#'

#' @description

#' This is one of the main ways to write data with googlesheets4. This function
#' writes a data frame into a (work)sheet inside a (spread)Sheet. The target
#' sheet is styled as a table:
#'   * Special formatting is applied to the header row, which holds column
#'     names.
#'   * The first row (header row) is frozen.
#'   * The sheet's dimensions are set to "shrink wrap" the `data`.
#'
#' If no existing Sheet is specified via `ss`, this function delegates to
#' [`sheets_create()`] and the new Sheet's name is randomly generated. If that's
#' undesirable, call [`sheets_create()`] directly to get more control.
#'
#' If no `sheet` is specified or if `sheet` doesn't identify an existing sheet,
#' a new sheet is added to receive the `data`. If `sheet` specifies an existing
#' sheet, it is effectively overwritten! All pre-existing values, formats, and
#' dimensions are cleared and the targeted sheet gets new values and dimensions
#' from `data`.
#'
#' This function goes by two names, because we want it to make sense in two
#' contexts:
#' * `write_sheet()` evokes other table-writing functions, like
#'   `readr::write_csv()`. The `sheet` here technically refers to an individual
#'   (work)sheet (but also sort of refers to the associated Google
#'   (spread)Sheet).
#' * `sheet_write()` is the right name according to the naming convention used
#'   throughout the googlesheets4 package.
#'
#' `write_sheet()` and `sheet_write()` are synonyms and you can use either one.
#' The first release of googlesheets used a `sheets_` prefix everywhere, so we
#' had `sheets_write()`. It still works, but it's deprecated and will go away
#' rather swiftly.
#'
#' @param data A data frame. If it has zero rows, we send one empty pseudo-row
#'   of data, so that we can apply the usual table styling. This empty row goes
#'   away (gets filled, actually) the first time you send more data with
#'   [sheet_append()].
#' @eval param_ss()
#' @eval param_sheet(action = "write into")
#'
#' @template ss-return
#' @export
#' @family write functions
#' @family worksheet functions
#'
#' @examples
#' if (sheets_has_token()) {
#'   df <- data.frame(
#'     x = 1:3,
#'     y = letters[1:3]
#'   )
#'
#'   # specify only a data frame, get a new Sheet, with a random name
#'   ss <- write_sheet(df)
#'   read_sheet(ss)
#'
#'   # clean up
#'   googledrive::drive_trash(ss)
#'
#'   # create a Sheet with some initial, placeholder data
#'   ss <- sheets_create(
#'     "sheet-write-demo",
#'     sheets = list(alpha = data.frame(x = 1), omega = data.frame(x = 1))
#'   )
#'
#'   # write df into its own, new sheet
#'   sheet_write(df, ss = ss)
#'
#'   # write mtcars into the sheet named "omega"
#'   sheet_write(mtcars, ss = ss, sheet = "omega")
#'
#'   # get an overview of the sheets
#'   sheet_properties(ss)
#'
#'   # view your magnificent creation in the browser
#'   # sheets_browse(ss)
#'
#'   # clean up
#'   googledrive::drive_trash(ss)
#' }
sheet_write <- function(data,
                        ss = NULL,
                        sheet = NULL) {
  data_quo <- enquo(data)
  data <- eval_tidy(data_quo)
  check_data_frame(data)

  # no Sheet provided --> call sheets_create() ---------------------------------
  if (is.null(ss)) {
    if (quo_is_symbol(data_quo)) {
      sheet <- sheet %||% as_name(data_quo)
    }
    if (is.null(sheet)) {
      return(sheets_create(sheets = data))
    } else {
      check_string(sheet)
      return(sheets_create(sheets = list2(!!sheet := data)))
    }
  }

  # finish checking inputs -----------------------------------------------------
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)

  # retrieve spreadsheet metadata ----------------------------------------------
  x <- sheets_get(ssid)
  message_glue("Writing to {dq(x$name)}")

  # no `sheet` ... but maybe we can name the sheet after the data --------------
  if (is.null(sheet) && quo_is_symbol(data_quo)) {
    candidate <- as_name(data_quo)
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
    x <- sheet_add_impl_(ssid, sheet_name = sheet)
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
      responseIncludeGridData = FALSE
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}

#' @rdname sheet_write
#' @export
write_sheet <- sheet_write
