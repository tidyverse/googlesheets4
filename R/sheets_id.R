#' sheets_id object
#'
#' Holds a spreadsheet identifier. This is what the Sheets and Drive APIs refer
#' to as `spreadsheetId` and `fileId`, respectively.
#'
#' @name sheets_id
#' @seealso [as_sheets_id()]
NULL

## implementing sheets_id as advised here:
## https://github.com/hadley/adv-r/blob/master/S3.Rmd

## constructor: efficiently creates new objects with the correct structure
new_sheets_id <- function(x) {
  stopifnot(is_string(x))
  structure(x, class = "sheets_id")
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
#'   * A URL, from which we can excavate a spreadsheet or file id. Example: <https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/edit#gid=1150108545>.
#'   * A one-row [`dribble`][googledrive::dribble], a "Drive tibble" used by the
#'   [googledrive] package. In general, a `dribble` can represent several files,
#'   one row per file. Since googlesheets4 is not vectorized over spreadsheets,
#'   we are only prepared to accept a one-row `dribble`.
#'
#' @description This is a generic function.
#'

#' @param x Something that uniquely identifies a Google Sheet (see below for
#'   anticipated inputs.
#' @param ... Other arguments passed down to methods. (Not used.)
#' @export
#' @examples
#' as_sheets_id("abc")
#' }
as_sheets_id <- function(x, ...) UseMethod("as_sheets_id")

#' @export
as_sheets_id.NULL <- function(x, ...) NULL

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
  stop_glue_data(
    list(x = collapse(class(x), sep = "/")),
    "Don't know how to coerce object of class {sq(x)} into a sheets_id"
  )
}

#' @export
as_sheets_id.character <- function(x, ...) {
  if (length(x) == 0L) return(x)
  if (length(x) > 1) {
    stop_glue(
      "Character input must not have length > 1.\n",
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

## currently just copied from googledrive
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
