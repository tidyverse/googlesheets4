#' Add a data validation rule to a cell range
#'
#' @description
#' *Note: not yet exported, still very alpha. Usage still requires using
#' low-level helpers.*
#'
#' `range_add_validation()` adds a data validation rule to a range of cells.
#'
#' @eval param_ss()
#' @eval param_sheet()
#' @param range Cells to apply data validation to. This `range` argument has
#'   important similarities and differences to `range` elsewhere (e.g.
#'   [range_read()]):
#'   * Similarities: Can be a cell range, using A1 notation ("A1:D3") or using
#'     the helpers in [`cell-specification`]. Can combine sheet name and cell
#'     range ("Sheet1!A5:A") or refer to a sheet by name (`range = "Sheet1"`,
#'     although `sheet = "Sheet1"` is preferred for clarity).
#'   * Difference: Can NOT be a named range.
#' @param rule An instance of `googlesheets4_schema_DataValidationRule`, which
#'   implements the
#'   [DataValidationRule](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/cells#datavalidationrule)
#'   schema.
#'
#' @template ss-return
#' @seealso Makes a `SetDataValidationRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#setdatavalidationrequest>
#'
#' @keywords internal
#' @noRd
#'
#' @examplesIf gs4_has_token()
#' # create a data frame to use as initial data
#' df <- data.frame(
#'   id = 1:3,
#'   "Hungry?" = NA,
#'   ice_cream = NA,
#'   check.names = FALSE
#' )
#'
#' # create Sheet
#' ss <- gs4_create("range-add-validation-demo", sheets = list(df))
#'
#' # create a column that presents as a basic TRUE/FALSE checkbox
#' rule_checkbox <- googlesheets4:::new(
#'   "DataValidationRule",
#'   condition = googlesheets4:::new_BooleanCondition(type = "BOOLEAN"),
#'   inputMessage = "Please let us know if you are hungry.",
#'   strict = TRUE,
#'   showCustomUi = TRUE
#' )
#' googlesheets4:::range_add_validation(
#'   ss,
#'   range = "Sheet1!B2:B", rule = rule_checkbox
#' )
#'
#' # create a column that presents as a dropdown list
#' rule_dropdown_list <- googlesheets4:::new(
#'   "DataValidationRule",
#'   condition = googlesheets4:::new_BooleanCondition(
#'     type = "ONE_OF_LIST", values = c("vanilla", "chocolate", "strawberry")
#'   ),
#'   inputMessage = "Which ice cream flavor do you want?",
#'   strict = TRUE,
#'   showCustomUi = TRUE
#' )
#' googlesheets4:::range_add_validation(
#'   ss,
#'   range = "Sheet1!C2:C", rule = rule_dropdown_list
#' )
#'
#' read_sheet(ss)
#'
#' # clean up
#' gs4_find("range-add-validation-demo") %>%
#'   googledrive::drive_trash()
range_add_validation <- function(ss, sheet = NULL, range = NULL, rule) {
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_range(range)
  if (!is.null(rule)) {
    stopifnot(inherits(rule, "googlesheets4_schema_DataValidationRule"))
  }

  x <- gs4_get(ssid)
  gs4_bullets(c(v = "Editing {.s_sheet {x$name}}."))

  # determine (work)sheet ------------------------------------------------------
  range_spec <- as_range_spec(
    range,
    sheet = sheet,
    sheets_df = x$sheets,
    nr_df = x$named_ranges
  )
  range_spec$sheet_name <- range_spec$sheet_name %||%
    first_visible_name(x$sheets)
  s <- lookup_sheet(range_spec$sheet_name, sheets_df = x$sheets)
  gs4_bullets(c(v = "Editing sheet {.w_sheet {range_spec$sheet_name}}."))

  # form batch update request --------------------------------------------------
  sdv_req <- list(
    setDataValidation = new(
      "SetDataValidationRequest",
      range = as_GridRange(range_spec),
      rule = rule
    )
  )

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
    "DATE_BEFORE",
    "DATE_AFTER",
    "DATE_ON_OR_BEFORE",
    "DATE_ON_OR_AFTER"
  )
  if (type %in% needs_relative_date) {
    gs4_abort(
      "{.field relativeDate} not yet supported as a {.code conditionValue}.",
      .internal = TRUE
    )
  }
  patch(out, values = map(values, ~ list(userEnteredValue = as.character(.x))))
}
