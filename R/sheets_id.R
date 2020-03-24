#' `sheets_id` object
#'
#' @description A `sheets_id` is a spreadsheet identifier, i.e. a string. This
#'   is what the Sheets and Drive APIs refer to as `spreadsheetId` and `fileId`,
#'   respectively. When you print a `sheets_id`, we attempt to reveal its
#'   current metadata (via `sheets_get()`). This can fail for a variety of
#'   reasons (e.g. if you're offline), but the `sheets_id` is always revealed
#'   and is returned, invisibly.
#'
#'   Any object of class `sheets_id` will also have the
#'   [`drive_id`][googledrive::as_id] class, which is used by [googledrive] for
#'   the same purpose. This means you can pipe a `sheets_id` object straight
#'   into [googledrive] functions for all your Google Drive needs that have
#'   nothing to do with the file being a spreadsheet. Examples: examine or
#'   change file name, path, or permissions, copy the file, or visit it in a web
#'   browser.
#'
#' @name sheets_id
#' @seealso [as_sheets_id()]
#'
#' @examples
#' if (sheets_has_token()) {
#'   sheets_example("mini-gap")
#' }
NULL

## implementing sheets_id as advised here:
## https://github.com/hadley/adv-r/blob/master/S3.Rmd

## constructor: efficiently creates new objects with the correct structure
new_sheets_id <- function(x) {
  stopifnot(is_string(x))
  structure(x, class = c("sheets_id", "drive_id"))
}

## validator: performs more expensive checks that the object has correct values
## from Sheet API docs:
## The spreadsheet ID is a string containing letters, numbers, and some special
## characters. The following regular expression can be used to extract the
## spreadsheet ID from a Google Sheets URL:
## /spreadsheets/d/([a-zA-Z0-9-_]+)
validate_sheets_id <- function(x) {
  stopifnot(inherits(x, "sheets_id"))
  if (!grepl("^[a-zA-Z0-9-_]+$", x, perl = TRUE)) {
    stop("Spreadsheet ID contains invalid characters:\n", x, call. = FALSE)
  }
  ## I am quite sure id should have exactly 44 characters but am reluctant
  ## to require this because it makes small examples and tests burdensome
  x
}

## helper: provides convenient, neatly parameterised way for others to construct
## and validate (create) objects of this class
sheets_id <- function(x) {
  validate_sheets_id(new_sheets_id(x))
}

#' Coerce to a sheets_id object
#'
#' @description Converts various representations of a Google Sheet into a
#'   [`sheets_id`] object. Anticipated inputs:
#'   * Spreadsheet id, "a string containing letters, numbers, and some special
#'   characters", typically 44 characters long, in our experience. Example:
#'   `1qpyC0XzvTcKT6EISywvqESX3A0MwQoFDE8p-Bll4hps`.
#'   * A URL, from which we can excavate a spreadsheet or file id. Example:
#'     <https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/edit#gid=1150108545>.
#'   * A one-row [`dribble`][googledrive::dribble], a "Drive tibble" used by the
#'     [googledrive] package. In general, a `dribble` can represent several
#'     files, one row per file. Since googlesheets4 is not vectorized over
#'     spreadsheets, we are only prepared to accept a one-row `dribble`.
#'     - [`googledrive::drive_get("YOUR_SHEET_NAME")`][googledrive::drive_get()]
#'     is a great way to look up a Sheet via its name.
#'     - [`sheets_find("YOUR_SHEET_NAME")`][sheets_find()] is another good way
#'     to get your hands on a Sheet.
#'   * Spreadsheet meta data, as returned by, e.g., [sheets_get()]. Literally,
#'     this is an object of class `googlesheets4_spreadsheet`.
#'
#' @description This is a generic function.
#'
#' @param x Something that uniquely identifies a Google Sheet: a [`sheets_id`],
#'   a URL, one-row [`dribble`][googledrive::dribble], or a
#'   `googlesheets4_spreadsheet`.
#' @param ... Other arguments passed down to methods. (Not used.)
#' @export
#' @examples
#' as_sheets_id("abc")
as_sheets_id <- function(x, ...) UseMethod("as_sheets_id")

#' @export
as_sheets_id.NULL <- function(x, ...) {
  stop_glue("Cannot turn `NULL` into a `sheets_id` object.")
}

#' @export
as_sheets_id.sheets_id <- function(x, ...) x

#' @export
as_sheets_id.drive_id <- function(x, ...) new_sheets_id(x)

#' @export
as_sheets_id.dribble <- function(x, ...) {
  if (nrow(x) != 1) {
    stop_glue(
      "Dribble input must have exactly 1 row.\n",
      "  * Actual input has {nrow(x)} rows."
    )
  }
  mime_type <- googledrive::drive_reveal(x, "mime_type")[["mime_type"]]
  target <- "application/vnd.google-apps.spreadsheet"
  if (!identical(mime_type, target)) {
    stop_glue(
      "Dribble input must refer to a Google Sheet, i.e. a file with MIME ",
      "type {sq(target)}.\n",
      "  * File id: {sq(x$id)}\n",
      "  * File name: {sq(x$name)}\n",
      "  * MIME TYPE: {sq(mime_type)}"
    )
  }
  new_sheets_id(x$id)
}

#' @export
as_sheets_id.default <- function(x, ...) {
  stop_glue(
    "Don't know how to coerce an object of class {class_collapse(x)} ",
    "into a 'sheets_id'"
  )
}

#' @export
as_sheets_id.character <- function(x, ...) {
  if (length(x) != 1) {
    stop_glue(
      "Character input must have length == 1.\n",
      "  * Actual input has length {length(x)}."
    )
  }
  out <- one_id(x)
  if (is.na(out)) {
    stop_glue(
      "Input does not match our regular expression for extracting ",
      "spreadsheet id.\n",
      "  * Input: {sq(x)}"
    )
  }
  sheets_id(out)
}

#' @export
as_sheets_id.googlesheets4_spreadsheet <- function(x, ...) {
  new_sheets_id(x$spreadsheet_id)
}

## copied from googledrive
one_id <- function(x) {
  if (!grepl("^http|/", x)) return(x)

  ## We expect the links to have /d/ before the file id, have /folders/
  ## before a folder id, or have id= before an uploaded blob
  id_loc <- regexpr("/d/([^/])+|/folders/([^/])+|id=([^/])+", x)
  if (id_loc == -1) {
    NA_character_
  } else {
    gsub("/d/|/folders/|id=", "", regmatches(x, id_loc))
  }
}

#' Extract the file id from Sheet metadata
#'
#' This method implements [googledrive::as_id()] for the class used here to hold
#' metadata for a Sheet. It just calls [as_sheets_id()], but it's handy in case
#' you forget that exists and hope that `as_id()` will "just work".
#'
#' @inheritParams googledrive::as_id
#' @param x An instance of `googlesheets4_spreadsheet`, which is returned by,
#'   e.g., [sheets_get()].
#' @inherit googledrive::as_id return
#' @importFrom googledrive as_id
#' @export
#' @examples
#' if (identical(Sys.getenv("IN_PKGDOWN"), "true")) {
#'   sheets_auth_docs(drive = TRUE)
#' }
#'
#' if (sheets_has_token()) {
#'   ss <- sheets_get(sheets_example("mini-gap"))
#'   class(ss)
#'   as_id(ss)
#' }
as_id.googlesheets4_spreadsheet <- function(x, ...) as_sheets_id(x)

#' @export
format.sheets_id <- function(x, ...) {
  meta <- tryCatch(
    with_abort(sheets_get(x)),
    rlang_error = function(e) e
  )

  if (inherits(meta, "googlesheets4_spreadsheet")) {
    return(format(meta))
  }

  # meta is an error, i.e. sheets_get() failed
  out <- new_googlesheets4_spreadsheet(list(spreadsheetId = x))
  c(
    format(out),
    "",
    "Unable to get metadata for this Sheet. Error details:",
    meta$message
  )
}

#' @export
print.sheets_id <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}
