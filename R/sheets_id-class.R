#' `sheets_id` class
#'
#' @description

#' `sheets_id` is an S3 class that marks a string as a Google Sheet's id, which
#' the Sheets API docs refer to as `spreadsheetId`.
#'
#' Any object of class `sheets_id` also has the [`drive_id`][googledrive::as_id]
#' class, which is used by [googledrive] for the same purpose. This means you
#' can provide a `sheets_id` to [googledrive] functions, in order to do anything
#' with your Sheet that has nothing to do with it being a spreadsheet. Examples:
#' change the Sheet's name, parent folder, or permissions. Read more about using
#' [googlesheets4] and [googledrive] together in `vignette("drive-and-sheets")`.
#' Note that a `sheets_id` object is intended to hold **just one** id, while the
#' parent class `drive_id` can be used for multiple ids.
#'

#' `as_sheets_id()` is a generic function that converts various inputs into an
#' instance of `sheets_id`. See more below.
#'

#' When you print a `sheets_id`, we attempt to reveal the Sheet's current
#' metadata, via [gs4_get()]. This can fail for a variety of reasons (e.g. if
#' you're offline), but the input `sheets_id` is always revealed and returned,
#' invisibly.

#' @section `as_sheets_id()`:
#'
#' These inputs can be converted to a `sheets_id`:
#'   * Spreadsheet id, "a string containing letters, numbers, and some special
#'   characters", typically 44 characters long, in our experience. Example:
#'   `1qpyC0XzvTcKT6EISywvqESX3A0MwQoFDE8p-Bll4hps`.
#'   * A URL, from which we can excavate a spreadsheet or file id. Example:
#'     `"https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/edit#gid=1150108545"`.
#'   * A one-row [`dribble`][googledrive::dribble], a "Drive tibble" used by the
#'     [googledrive] package. In general, a `dribble` can represent several
#'     files, one row per file. Since googlesheets4 is not vectorized over
#'     spreadsheets, we are only prepared to accept a one-row `dribble`.
#'     - [`googledrive::drive_get("YOUR_SHEET_NAME")`][googledrive::drive_get()]
#'     is a great way to look up a Sheet via its name.
#'     - [`gs4_find("YOUR_SHEET_NAME")`][gs4_find()] is another good way
#'     to get your hands on a Sheet.
#'   * Spreadsheet meta data, as returned by, e.g., [gs4_get()]. Literally,
#'     this is an object of class `googlesheets4_spreadsheet`.
#'

#' @name sheets_id
#' @seealso [googledrive::as_id]

#' @param x Something that contains a Google Sheet id: an id string, a
#'   [`drive_id`][googledrive::as_id], a URL, a one-row
#'   [`dribble`][googledrive::dribble], or a `googlesheets4_spreadsheet`.
#' @param ... Other arguments passed down to methods. (Not used.)

#' @examplesIf gs4_has_token()
#' mini_gap_id <- gs4_example("mini-gap")
#' class(mini_gap_id)
#' mini_gap_id
#'
#' as_sheets_id("abc")
NULL

# constructor and validator ----
new_sheets_id <- function(x = character()) {
  vec_assert(x, character())
  new_vctr(x, class = c("sheets_id", "drive_id"), inherit_base_type = TRUE)
}

validate_sheets_id <- function(x) {
  if (length(x) > 1) {
    gs4_abort(c(
      "A {.cls sheets_id} object can't have length greater than 1.",
      x = "Actual input has length {length(x)}."
    ))
  }
  validate_drive_id(x)
}

new_drive_id <- function(x = character()) {
  utils::getFromNamespace("new_drive_id", "googledrive")(x)
}
validate_drive_id <- function(x) {
  utils::getFromNamespace("validate_drive_id", "googledrive")(x)
}

# vctrs methods ----

# sheets_id is intended to hold ONE id, so I want:
# c(sheets_id, sheets_id) = drive_id
# I'm willing to accept that this is not quite right / necessary if one or both
# inputs has length 1
#' @export
vec_ptype2.sheets_id.sheets_id <- function(x, y, ...) new_drive_id()

#' @export
vec_ptype2.sheets_id.character <- function(x, y, ...) character()
#' @export
vec_ptype2.character.sheets_id <- function(x, y, ...) character()

#' @export
vec_ptype2.sheets_id.drive_id <- function(x, y, ...) new_drive_id()
#' @export
vec_ptype2.drive_id.sheets_id <- function(x, y, ...) new_drive_id()

#' @export
vec_cast.sheets_id.sheets_id <- function(x, to, ...) x

#' @export
vec_cast.sheets_id.character <- function(x, to, ...) {
  validate_sheets_id(new_sheets_id(x))
}
#' @export
vec_cast.character.sheets_id <- function(x, to, ...) vec_data(x)

#' @export
vec_cast.sheets_id.drive_id <- function(x, to, ...) {
  validate_sheets_id(new_sheets_id(vec_data(x)))
}
#' @export
vec_cast.drive_id.sheets_id <- function(x, to, ...) as_id(vec_data(x))

#' @export
vec_ptype_abbr.sheets_id <- function(x) "sht_id"

# googledrive ----

#' @export
as_id.sheets_id <- function(x, ...) as_id(vec_data(x))
#' @export
as_id.googlesheets4_spreadsheet <- function(x, ...) as_id(x$spreadsheet_id)

# user-facing  ----

#' @export
#' @rdname sheets_id
as_sheets_id <- function(x, ...) UseMethod("as_sheets_id")

#' @export
as_sheets_id.NULL <- function(x, ...) {
  abort_unsupported_conversion(x, to = "sheets_id")
}

#' @export
as_sheets_id.default <- function(x, ...) {
  abort_unsupported_conversion(x, to = "sheets_id")
}

#' @export
as_sheets_id.sheets_id <- function(x, ...) x

#' @export
as_sheets_id.drive_id <- function(x, ...) {
  validate_sheets_id(new_sheets_id(vec_data(x)))
}

#' @export
as_sheets_id.dribble <- function(x, ...) {
  if (nrow(x) != 1) {
    gs4_abort(c(
      "{.cls dribble} input must have exactly 1 row.",
      x = "Actual input has {nrow(x)} rows."
    ))
  }
  # not worrying about whether we are authed as same user with Sheets and Drive
  # revealing the MIME type is local to the dribble, so this makes no API calls
  mime_type <- googledrive::drive_reveal(x, "mime_type")[["mime_type"]]
  target <- "application/vnd.google-apps.spreadsheet"
  if (!identical(mime_type, target)) {
    gs4_abort(c(
      "{.cls dribble} input must refer to a Google Sheet, i.e. a file with \\
       MIME type {.field {target}}.",
      i = "File name: {.s_sheet {x$name}}",
      i = "File id: {.field {x$id}}",
      x = "MIME TYPE: {.field {mime_type}}"
    ))
  }
  as_sheets_id(x$id)
}

#' @export
as_sheets_id.character <- function(x, ...) {
  # we're leaning on as_id() for URL detection and processing
  id <- as_id(x)
  validate_sheets_id(new_sheets_id(vec_data(id)))
}

#' @export
as_sheets_id.googlesheets4_spreadsheet <- function(x, ...) {
  validate_sheets_id(new_sheets_id(x$spreadsheet_id))
}

#' @export
print.sheets_id <- function(x, ...) {
  cli::cat_line(sheets_id_print(x))
  invisible(x)
}

sheets_id_print <- function(x) {
  meta <- tryCatch(
    gs4_get(x),
    # seen with a failed request
    gargle_error_request_failed = function(e) e,
    # seen when we can't get a token but auth is active
    googlesheets4_error = function(e) e
  )

  if (inherits(meta, "googlesheets4_spreadsheet")) {
    return(format(meta))
  }

  # meta is an error, i.e. gs4_get() failed
  out <- new_googlesheets4_spreadsheet(list(spreadsheetId = x))
  c(
    format(out),
    "",
    "Unable to get metadata for this Sheet. Error details:",
    meta$message
  )
}
