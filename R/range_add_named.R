#' Add a named range
#'
#' Adds a named range. Not really ready for showtime yet, so not exported. But
#' I need it to (re)create the 'deaths' example Sheet.
#'
#' @noRd
#'
#' @eval param_ss()
#' @param name Name for the new named range.
#' @eval param_sheet(action = "SOMETHING")
#' @template range
#'
#' @template ss-return
#' @keywords internal
#' @examples
#' if (gs4_has_token()) {
#'   dat <- data.frame(x = 1:3, y = letters[1:3])
#'   ss <- gs4_create("range-add-named-demo", sheets = list(alpha = dat))
#'
#'   ss %>%
#'     range_add_named("two_rows", sheet = "alpha", range = "A2:B3")
#'
#'   # notice the 'two_rows' named range reported here
#'   ss
#'
#'   # clean up
#'   gs4_find("range-add-named-demo") %>%
#'     googledrive::drive_trash()
#' }
range_add_named <- function(ss,
                            name,
                            sheet = NULL,
                            range = NULL) {
  ssid <- as_sheets_id(ss)
  name <- check_string(name)
  maybe_sheet(sheet)
  check_range(range)

  x <- gs4_get(ssid)
  gs4_bullets(c(v = "Working in {.file {x$name}}"))

  # determine (work)sheet ------------------------------------------------------
  range_spec <- as_range_spec(
    range, sheet = sheet,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  range_spec$sheet_name <- range_spec$sheet_name %||% first_visible_name(x$sheets)

  # form batch update request --------------------------------------------------
  req <- list(addNamedRange = new(
    "AddNamedRangeRequest",
    namedRange = as_NamedRange(range_spec, name = name)
  ))

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(req)
    )
  )
  resp_raw <- request_make(req)
  reply <- gargle::response_process(resp_raw)
  reply <- pluck(reply, "replies", 1, "addNamedRange", "namedRange")
  reply <- new("NamedRange", !!!reply)
  # TODO: this would not be so janky if new_googlesheets4_spreadsheet() were
  #       factored in a way I could make better use of its logic
  reply <- as.list(as_tibble(reply))
  reply$sheet_name <- vlookup(
    reply$sheet_id, data = x$sheets, key = "id", value = "name"
  )
  A1_range <- qualified_A1(reply$sheet_name, do.call(make_cell_range, reply))
  gs4_bullets(c(
    v = "Created new range named {.field {reply$name}} \\
         representing {.field {A1_range}}"))

  invisible(ssid)
}
