#' Protect a cell range
#'
#' @description
#' *Note: not yet exported, still very alpha. Usage still requires using
#' low-level helpers. This documentation is for ME.*
#'
#' `range_add_protection()` protects a range of cells against editing.
#'
#' @eval param_ss()
#' @eval param_sheet()
#' @param range Cells to protect. This `range` argument works very much like
#'   `range` in, for example, [range_read()]). Specific things to note:
#'   You can omit `range` to protect a whole sheet and `range` can be a named
#'   range.
#' @param ... Optional arguments used when constructing the `ProtectedRange`
#'   object. Use this is you want to set `description`, `warningOnly`,
#'   `unprotectedRanges`, or `editors`. For advanced use.
#'
#' @template ss-return
#' @seealso Makes an `AddProtectedRangeRequest`:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#addprotectedrangerequest>
#'
#' Documentation on the `ProtectedRange` object:
#'   * <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#protectedrange>
#'
#' @keywords internal
#' @noRd
#'
#' @examples
#' if (gs4_has_token()) {
#'   # create a data frame to use as initial data
#'   dat <- gs4_fodder(3)
#'
#'   # create Sheet, add a couple more sheets
#'   ss <- gs4_create("range-add-protection-example", sheets = dat)
#'   sheet_write(head(iris), ss, sheet = "iris")
#'   sheet_write(head(mtcars), ss, sheet = "mtcars")
#'   sheet_write(ToothGrowth, ss, sheet = "ToothGrowth")
#'
#'   # add myself and get it open in the browser
#'   gs4_share(ss, type = "user", emailAddress = "jenny@rstudio.com", role = "writer")
#'   gs4_browse(ss)
#'
#'   # protect a whole sheet
#'   ss %>%
#'     range_add_protection(sheet = "dat", description = "whole sheet")
#'
#'   # create a named range, then protect it
#'   ss %>%
#'     range_add_named("species", sheet = "iris", range = "E:E") %>%
#'     range_add_protection(range = "species", description = "named range")
#'
#'   # protect an arbitrary rectangle and add an editor
#'   ss %>%
#'     range_add_protection(
#'       range = "mtcars!1:1",
#'       description = "single row",
#'       editors = new("Editors", users = "jenny@rstudio.com")
#'     )
#'
#'   # check in on the protected ranges we've created
#'   ss_info <- gs4_get(ss)
#'   ss_info$protected_ranges
#'
#'   # protect a sheet EXCEPT certain columns that can be edited
#'   unprotect_this <- as_range_spec(
#'     "C:C",
#'     sheet = "ToothGrowth",
#'     sheets_df = ss_info$sheets, nr_df = ss_info$named_ranges
#'     )
#'   unprotect_range <- as_GridRange(unprotect_this)
#'   ss %>%
#'     range_add_protection(
#'       sheet = "ToothGrowth",
#'       description = "sheet MINUS some cols",
#'       unprotectedRanges = unprotect_range
#'     )
#'
#'   # look at the editors for our protected ranges
#'   ss_info <- gs4_get(ss)
#'   ss_info$protected_ranges
#'   ss_info$protected_ranges$editors
#'
#'   # add an editor to a protected range
#'   id <- ss_info$protected_ranges$protected_range_id[[1]]
#'   range_update_protection(
#'     ss,
#'     protectedRangeId = id,
#'     editors = new("Editors", users = "jenny@rstudio.com")
#'   )
#'
#'   # confirm the editor change happened
#'   ss_info <- gs4_get(ss)
#'   ss_info$protected_ranges$editors
#'
#'   # delete protections from a range
#'   id <- ss_info$protected_ranges$protected_range_id[[3]]
#'   range_delete_protection(ss, id = id)
#'
#'   # confirm the deletion happened
#'   ss_info <- gs4_get(ss)
#'   ss_info$protected_ranges
#'
#'   # clean up
#'   gs4_find("range-add-protection-example") %>%
#'     googledrive::drive_trash()
#' }
range_add_protection <- function(ss,
                                 sheet = NULL,
                                 range = NULL, ...) {
  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_range(range)

  x <- gs4_get(ssid)
  message_glue("Editing {dq(x$name)}")

  # determine range ------------------------------------------------------------
  range_spec <- as_range_spec(
    range,
    sheet = sheet,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  if (is.null(range_spec$named_range)) {
    range_spec$sheet_name <- range_spec$sheet_name %||% first_visible_name(x$sheets)
    message_glue("Protecting cells on sheet: {dq(range_spec$sheet_name)}")
  } else {
    message_glue("Protecting named range: {dq(range_spec$named_range)}")
  }

  # form batch update request --------------------------------------------------
  prot_req <- list(addProtectedRange = new(
    "AddProtectedRangeRequest",
    protectedRange = new_ProtectedRange(range_spec, ...)
  ))

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(prot_req)
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}

# helpers ----
new_ProtectedRange <- function(range_spec, ...) {
  if (is.null(range_spec$named_range)) {
    out <- new("ProtectedRange", range = as_GridRange(range_spec))
  } else {
    out <- new(
      "ProtectedRange",
      namedRangeId = vlookup(range_spec$named_range, range_spec$nr_df, "name", "id")
    )
  }
  out <- patch(out, editors = new("Editors", domainUsersCanEdit = FALSE))
  patch(out, ...)
}

# even less polished one-offs used during development
range_update_protection <- function(ss, ...) {
  ssid <- as_sheets_id(ss)

  x <- gs4_get(ssid)
  message_glue("Editing {dq(x$name)}")

  # form batch update request --------------------------------------------------
  protected_range <- new("ProtectedRange", ...)
  mask <- gargle::field_mask(protected_range)
  # I have no idea why this is necessary, but it's the only way I've been able
  # to updated editors
  mask <- sub("editors.users", "editors", mask)
  prot_req <- list(updateProtectedRange = new(
    "UpdateProtectedRangeRequest",
    protectedRange = protected_range,
    fields = mask
  ))

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(prot_req)
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}

range_delete_protection <- function(ss, id) {
  ssid <- as_sheets_id(ss)

  x <- gs4_get(ssid)
  message_glue("Editing {dq(x$name)}")

  # form batch update request --------------------------------------------------
  prot_req <- list(deleteProtectedRange = new(
    "DeleteProtectedRangeRequest",
    protectedRangeId = id
  ))

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(prot_req)
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}
