#' (Over)write new data into a range
#'
#' @description
#'
#' Writes a data frame into a range of cells. Main differences from
#' [sheet_write()] (a.k.a. [write_sheet()]):
#' * Narrower scope. `range_write()` literally targets some cells, not a whole
#'   (work)sheet.
#' * The edited rectangle is not explicitly styled as a table. Nothing special
#'   is done re: formatting a header row or freezing rows.
#' * Column names can be suppressed. This means that, although `data` must
#'   be a data frame (at least for now), `range_write()` can actually be used
#'   to write arbitrary data.
#' * The target (spread)Sheet and (work)sheet must already exist. There is no
#'   ability to create a Sheet or add a worksheet.
#' * The target sheet dimensions are not "trimmed" to shrink-wrap the `data`.
#'   However, the sheet might gain rows and/or columns, in order to write
#'   `data` to the user-specified `range`.
#'
#' If you just want to add rows to an existing table, the function you probably
#' want is [sheet_append()].
#'
#' @section Range specification:
#' The `range` argument of `range_write()` is special, because the Sheets API
#' can implement it in 2 different ways:
#' * If `range` represents exactly 1 cell, like "B3", it is taken as the *start*
#'   (or upper left corner) of the targeted cell rectangle. The edited cells are
#'   determined implicitly by the extent of the `data` we are writing. This
#'   frees you from doing fiddly range computations based on the dimensions of
#'   the `data`.
#' * If `range` describes a rectangle with multiple cells, it is interpreted
#'   as the *actual* rectangle to edit. It is possible to describe a rectangle
#'   that is unbounded on the right (e.g. "B2:4"), on the bottom (e.g. "A4:C"),
#'   or on both the right and the bottom (e.g.
#'   `cell_limits(c(2, 3), c(NA, NA))`. Note that **all cells** inside the
#'   rectangle receive updated data and format. Important implication: if the
#'   `data` object isn't big enough to fill the target rectangle, the cells that
#'    don't receive new data are effectively cleared, i.e. the existing value
#'    and format are deleted.
#'
#' @eval param_ss()
#' @param data A data frame.
#' @eval param_sheet(
#'   action = "write into",
#'   "Ignored if the sheet is specified via `range`. If neither argument",
#'   "specifies the sheet, defaults to the first visible sheet."
#' )
#' @param range Where to write. This `range` argument has important similarities
#'   and differences to `range` elsewhere (e.g. [range_read()]):
#'   * Similarities: Can be a cell range, using A1 notation ("A1:D3") or using
#'     the helpers in [`cell-specification`]. Can combine sheet name and cell
#'     range ("Sheet1!A5:A") or refer to a sheet by name (`range = "Sheet1"`,
#'     although `sheet = "Sheet1"` is preferred for clarity).
#'   * Difference: Can NOT be a named range.
#'   * Difference: `range` can be interpreted as the *start* of the target
#'     rectangle (the upper left corner) or, more literally, as the actual
#'     target rectangle. See the "Range specification" section for details.
#' @param col_names Logical, indicates whether to send the column names of
#'   `data`.
#' @template reformat
#'
#' @template ss-return
#' @export
#' @family write functions
#' @seealso
#' If sheet size needs to change, makes an `UpdateSheetPropertiesRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest>
#'
#' The main data write is done via an `UpdateCellsRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#updatecellsrequest>
#'
#' @examples
#' if (gs4_has_token()) {
#'   # create a Sheet with some initial, empty (work)sheets
#'   (ss <- gs4_create("range-write-demo", sheets = c("alpha", "beta")))
#'
#'   df <- data.frame(
#'     x = 1:3,
#'     y = letters[1:3]
#'   )
#'
#'   #  write df somewhere other than the "upper left corner"
#'   range_write(ss, data = df, range = "D6")
#'
#'   # view your magnificent creation in the browser
#'   gs4_browse(ss)
#'
#'   # send data of disparate types to a 1-row rectangle
#'   dat <- tibble::tibble(
#'     string = "string",
#'     logical = TRUE,
#'     datetime = Sys.time()
#'   )
#'   range_write(ss, data = dat, sheet = "beta", col_names = FALSE)
#'
#'   # send data of disparate types to a 1-column rectangle
#'   dat <- tibble::tibble(
#'     x = list(Sys.time(), FALSE, "string")
#'   )
#'   range_write(ss, data = dat, range = "beta!C5", col_names = FALSE)
#'
#'   # clean up
#'   gs4_find("range-write-demo") %>%
#'     googledrive::drive_trash()
#' }
range_write <- function(ss,
                        data,
                        sheet = NULL,
                        range = NULL,
                        col_names = TRUE, # not sure about this default
                        reformat = TRUE) {
  ssid <- as_sheets_id(ss)
  check_data_frame(data)
  maybe_sheet(sheet)
  check_range(range)
  check_bool(col_names)
  check_bool(reformat)

  x <- gs4_get(ssid)
  gs4_bullets(c(v = "Editing {.s_sheet {x$name}}."))

  # determine (work)sheet ------------------------------------------------------
  range_spec <- as_range_spec(
    range, sheet = sheet,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  range_spec$sheet_name <- range_spec$sheet_name %||% first_visible_name(x$sheets)
  gs4_bullets(c(v = "Writing to sheet {.w_sheet {range_spec$sheet_name}}."))

  # initialize the batch update requests; store details on target sheet s ------
  requests <- list()
  s <- lookup_sheet(range_spec$sheet_name , sheets_df = x$sheets)

  # package the write location as `start` or `range` ---------------------------
  loc <- prepare_loc(range_spec)

  # figure out if we need to resize the sheet ----------------------------------
  dims_needed <- prepare_dims(loc, data, col_names)
  resize_req <- prepare_resize_request(
    s,
    nrow_needed = dims_needed$nrow,
    ncol_needed = dims_needed$ncol,
    exact = FALSE
  )

  if (!is.null(resize_req)) {
    new_dims <- pluck(
      resize_req,
      "updateSheetProperties", "properties", "gridProperties"
    )
    gs4_bullets(c(
      v = "Changing dims: ({s$grid_rows} x {s$grid_columns}) --> \\
           ({new_dims$rowCount %||% s$grid_rows} x \\
           {new_dims$columnCount %||% s$grid_columns})."))
    requests <- c(requests, list(resize_req))
  }

  # pack the data, specify field mask ------------------------------------------
  fields <- if (reformat) "userEnteredValue,userEnteredFormat" else "userEnteredValue"
  data_req <- new(
    "UpdateCellsRequest",
    rows = as_RowData(data, col_names = col_names),
    fields = fields,
    !!!loc
  )
  requests <- c(requests, list(list(updateCells = data_req)))

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = requests
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}

prepare_loc <- function(x) {
  if (is.null(x$cell_limits)) {
    if (is.null(x$cell_range)) {
      return(list(start = as_GridCoordinate(x)))
    }
    x$cell_limits <- limits_from_range(x$cell_range)
  }

  if (more_than_one_cell(x$cell_limits)) {
    list(range = as_GridRange(x))
  } else {
    list(start = as_GridCoordinate(x))
  }
}

more_than_one_cell <- function(cl) {
  if (anyNA(cl$ul) || anyNA(cl$lr)) {
    return(TRUE)
  }

  nrows <- cl$lr[1] - cl$ul[1] + 1
  ncols <- cl$lr[2] - cl$ul[2] + 1
  nrows > 1 || ncols > 1
}

prepare_dims <- function(write_loc, data, col_names) {
  # Here it is actually useful to us that the row and column indices inside
  # `write_loc` are zero-indexed. Recall that:
  #   * `start` is an instance of GridCoordinate
  #   * `range` is an instance of GridRange
  if (has_name(write_loc, "start")) {
    return(list(
      nrow = (write_loc$start$rowIndex    %||% 0) + nrow(data) + col_names,
      ncol = (write_loc$start$columnIndex %||% 0) + ncol(data)
    ))
  }

  # we must be writing to a `range`
  # take explicit end indices literally
  # otherwise infer from start indices + size of `data`
  gr <- write_loc$range
  list(
    nrow = gr$endRowIndex %||%
      ((gr$startRowIndex %||% 0) + nrow(data) + col_names),
    ncol = gr$endColumnIndex %||%
      ((gr$startColumnIndex %||% 0) + ncol(data))
  )
}
