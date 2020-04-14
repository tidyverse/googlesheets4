#' Deprecated functions
#'
#' @description
#' \lifecycle{deprecated}
#'
#' These functions are deprecated and will be removed in a future release of
#' googlesheets4. Since googlesheets4 is a relatively young package, this
#' removal will happen rapidly, possibly after just 1 release cycle.
#'
#' @param ... Passed on to the function that succeeds the deprecated function.
#'
#' @section Auth and API endpoints:
#'
#' ```{r echo = FALSE}
#' dat <- tibble::tribble(
#'                ~ "< v0.2.0", ~ ">= v0.2.0",
#'          "sheets_api_key()",   "gs4_api_key()",
#'             "sheets_auth()",   "gs4_auth()",
#'   "sheets_auth_configure()",   "gs4_auth_configure()",
#'           "sheets_deauth()",   "gs4_deauth()",
#'        "sheets_endpoints()",   "gs4_endpoints()",
#'        "sheets_has_token()",   "gs4_has_token()",
#'        "sheets_oauth_app()",   "gs4_oauth_app()",
#'            "sheets_token()",   "gs4_token()",
#'             "sheets_user()",   "gs4_user()"
#' )
#' knitr::kable(dat, col.names = paste0("**", colnames(dat), "**"))
#' ```
#'
#' @section Spreadsheet operations:
#'
#' ```{r echo = FALSE}
#' dat <- tibble::tribble(
#'          ~ "< v0.2.0", ~ ">= v0.2.0",
#'     "sheets_browse()",   "gs4_browse()",
#'       "sheets_find()",   "gs4_find()",
#'    "sheets_example()",   "gs4_example()",
#'   "sheets_examples()",   "gs4_examples()",
#'        "sheets_get()",   "gs4_get()",
#' )
#' knitr::kable(dat, col.names = paste0("**", colnames(dat), "**"))
#' ```
#'
#' @section (Work)sheet operations:
#'
#' ```{r echo = FALSE}
#' dat <- tibble::tribble(
#'        ~ "< v0.2.0", ~ ">= v0.2.0",
#'   "sheets_sheets()", "sheet_names()"
#' )
#' knitr::kable(dat, col.names = paste0("**", colnames(dat), "**"))
#' ```
#'
#' @section Range operations:
#'
#' ```{r echo = FALSE}
#' dat <- tibble::tribble(
#'       ~ "< v0.2.0", ~ ">= v0.2.0",
#'   "sheets_cells()", "range_read_cells()",
#'    "sheets_read()", "range_read()"
#' )
#' knitr::kable(dat, col.names = paste0("**", colnames(dat), "**"))
#' ```
#'
#' @keywords internal
#' @name googlesheets4-deprecated
#' @importFrom lifecycle deprecate_warn
NULL

# nocov start

#' @rdname googlesheets4-deprecated
#' @export
sheets_sheets <- function(...) {
  deprecate_warn("0.2.0", "sheets_sheets()", "sheet_names()")
  sheet_names(...)
}

#' @rdname googlesheets4-deprecated
#' @export
sheets_cells <- function(...) {
  deprecate_warn("0.2.0", "sheets_cells()", "range_read_cells()")
  range_read_cells(...)
}

#' @rdname googlesheets4-deprecated
#' @export
sheets_read <- function(...) {
  deprecate_warn("0.2.0", "sheets_read()", "range_read()")
  range_read(...)
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

#' @rdname googlesheets4-deprecated
#' @export
sheets_get <- function(...) {
  deprecate_warn("0.2.0", "sheets_get()", "gs4_get()")
  gs4_get(...)
}

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
