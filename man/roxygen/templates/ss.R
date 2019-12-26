#' @param ss Something that identifies a Google Sheet: its file ID, a URL from
#'   which we can recover the ID, an instance of `googlesheets4_spreadsheet`
#'   (returned by [sheets_get()], or a [`dribble`][googledrive::dribble], which
#'   is how googledrive represents Drive files. Processed through
#'   [as_sheets_id()].
