#' Deprecated functions
#'
#' @description
#' \lifecycle{deprecated}
#'
#' These functions are deprecated and will be removed in a future release of
#' googlesheets4.
#'
#' @param ... Passed on to the function that succeeds the deprecated function.
#'
#' @keywords internal
#' @name googlesheets4-deprecated
#' @importFrom lifecycle deprecate_warn
NULL

# nocov start

#' @description
#' `sheets_sheets()` is replaced by [sheet_names()].
#' @rdname googlesheets4-deprecated
#' @export
sheets_sheets <- function(...) {
  deprecate_warn("0.2.0", "sheets_sheets()", "sheet_names()")
  sheet_names(...)
}

#' @description
#' `sheets_cells()` is replaced by [range_read_cells()].
#' @rdname googlesheets4-deprecated
#' @export
sheets_cells <- function(...) {
  deprecate_warn("0.2.0", "sheets_cells()", "range_read_cells()")
  range_read_cells(...)
}

#' @description
#' `sheets_read()` is replaced by [range_read()] (which is a synonym for
#' [read_sheet()]).
#' @rdname googlesheets4-deprecated
#' @export
sheets_read <- function(...) {
  deprecate_warn("0.2.0", "sheets_read()", "range_read()")
  range_read(...)
}

#' @description
#' `sheets_write()` is replaced by [sheet_write()] (which is a synonym for
#' [write_sheet()]).
#' @rdname googlesheets4-deprecated
#' @export
sheets_write <- function(...) {
  deprecate_warn("0.2.0", "sheets_write()", "sheet_write()")
  sheet_write(...)
}

#' @section Spreadsheet level operations:
#'
#' ```{r echo = FALSE}
#' dat <- tibble::tribble(
#'          ~ "< v0.2.0", ~ ">= v0.2.0",
#'     "sheets_browse()",   "gs4_browse()",
#'     "sheets_create()",   "gs4_create()",
#'       "sheets_find()",   "gs4_find()",
#'    "sheets_example()",   "gs4_example()",
#'   "sheets_examples()",   "gs4_examples()",
#'        "sheets_get()",   "gs4_get()",
#' )
#' knitr::kable(dat, col.names = paste0("**", colnames(dat), "**"))
#' ```
#'
#' @rdname googlesheets4-deprecated
#' @export
sheets_create <- function(...) {
  deprecate_warn("0.2.0", "sheets_create()", "gs4_create()")
  gs4_create(...)
}

#' @rdname googlesheets4-deprecated
#' @export
sheets_get <- function(...) {
  deprecate_warn("0.2.0", "sheets_get()", "gs4_get()")
  gs4_get(...)
}

#' @rdname googlesheets4-deprecated
#' @export
sheets_example <- function(...) {
  deprecate_warn("0.2.0", "sheets_example()", "gs4_example()")
  gs4_example(...)
}

#' @rdname googlesheets4-deprecated
#' @export
sheets_examples <- function(...) {
  deprecate_warn("0.2.0", "sheets_examples()", "gs4_examples()")
  gs4_examples(...)
}

#' @rdname googlesheets4-deprecated
#' @export
sheets_browse <- function(...) {
  deprecate_warn("0.2.0", "sheets_browse()", "gs4_browse()")
  gs4_browse(...)
}

#' @rdname googlesheets4-deprecated
#' @export
sheets_find <- function(...) {
  deprecate_warn("0.2.0", "sheets_find()", "gs4_find()")
  gs4_find(...)
}

#' @section Auth and API endpoints:
#'
#' ```{r echo = FALSE}
#' dat <- tibble::tribble(
#'                ~ "< v0.2.0", ~ ">= v0.2.0",
#'             "sheets_auth()",   "gs4_auth()",
#'   "sheets_auth_configure()",   "gs4_auth_configure()",
#'          "sheets_api_key()",   "gs4_api_key()",
#'           "sheets_deauth()",   "gs4_deauth()",
#'        "sheets_endpoints()",   "gs4_endpoints()",
#'        "sheets_has_token()",   "gs4_has_token()",
#'        "sheets_oauth_app()",   "gs4_oauth_app()",
#'            "sheets_token()",   "gs4_token()",
#'              "sheet_user()",   "gs4_user()"
#' )
#' knitr::kable(dat, col.names = paste0("**", colnames(dat), "**"))
#' ```
#'
#' @rdname googlesheets4-deprecated
#' @export
sheets_auth <- function(...) {
  deprecate_warn("0.2.0", "sheets_auth()", "gs4_auth()")
  gs4_auth(...)
}

#' @section Auth and API endpoints:
#' @rdname googlesheets4-deprecated
#' @export
sheets_deauth <- function(...) {
  deprecate_warn("0.2.0", "sheets_deauth()", "gs4_deauth()")
  gs4_deauth(...)
}

#' @section Auth and API endpoints:
#' @rdname googlesheets4-deprecated
#' @export
sheets_auth_configure <- function(...) {
  deprecate_warn("0.2.0", "sheets_auth_configure()", "gs4_auth_configure()")
  gs4_auth_configure(...)
}

#' @section Auth and API endpoints:
#' @rdname googlesheets4-deprecated
#' @export
sheets_api_key <- function(...) {
  deprecate_warn("0.2.0", "sheets_api_key()", "gs4_api_key()")
  gs4_api_key(...)
}

#' @section Auth and API endpoints:
#' @rdname googlesheets4-deprecated
#' @export
sheets_oauth_app <- function(...) {
  deprecate_warn("0.2.0", "sheets_oauth_app()", "gs4_oauth_app()")
  gs4_oauth_app(...)
}

#' @section Auth and API endpoints:
#' @rdname googlesheets4-deprecated
#' @export
sheets_token <- function(...) {
  deprecate_warn("0.2.0", "sheets_token()", "gs4_token()")
  gs4_token(...)
}

#' @section Auth and API endpoints:
#' @rdname googlesheets4-deprecated
#' @export
sheets_has_token <- function(...) {
  deprecate_warn("0.2.0", "sheets_has_token()", "gs4_has_token()")
  gs4_has_token(...)
}

#' @section Auth and API endpoints:
#' @rdname googlesheets4-deprecated
#' @export
sheets_user <- function(...) {
  deprecate_warn("0.2.0", "sheets_user()", "gs4_user()")
  gs4_user(...)
}

#' @section Auth and API endpoints:
#' @rdname googlesheets4-deprecated
#' @export
sheets_endpoints <- function(...) {
  deprecate_warn("0.2.0", "sheets_endpoints()", "gs4_endpoints()")
  gs4_endpoints(...)
}

# nocov end
