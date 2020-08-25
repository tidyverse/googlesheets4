range_validation <- function(ss,
                             sheet = NULL,
                             range = NULL,
                             rule = NULL) {
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_range(range)
  if (!is.null(rule)) {
    stopifnot(inherits(rule, "googlesheets4_schema_DataValidationRule"))
  }

  x <- gs4_get(ssid)
  message_glue("Editing {dq(x$name)}")

  # determine (work)sheet ------------------------------------------------------
  range_spec <- as_range_spec(
    range,
    sheet = sheet,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  range_spec$sheet_name <- range_spec$sheet_name %||% first_visible_name(x$sheets)
  s <- lookup_sheet(range_spec$sheet_name, sheets_df = x$sheets)
  message_glue("Editing sheet {dq(range_spec$sheet_name)}")

  # form batch update request --------------------------------------------------
  sdv_req <- list(setDataValidation = new(
    "SetDataValidationRequest",
    range = as_GridRange(range_spec),
    rule = rule
  ))

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(sdv_req)
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}

# helpers ----
new_BooleanCondition <- function(type = "NOT_BLANK", values = NULL) {
  out <- new("BooleanCondition", type = type)

  # TODO: build enum checking into our schema-based construction
  schema <- attr(out, "schema")
  enum <- schema$enum[[which(schema$property == "type")]]
  stopifnot(type %in% enum$enum)

  if (length(values) < 1) {
    return(out)
  }

  needs_relative_date <- c(
    "DATE_BEFORE", "DATE_AFTER", "DATE_ON_OR_BEFORE", "DATE_ON_OR_AFTER"
  )
  if (type %in% needs_relative_date) {
    stop_glue("
      {bt('relativeDate')} not yet supported as a {bt('conditionValue')}")
  }
  patch(out, values = map(values, ~ list(userEnteredValue = as.character(.x))))
}
