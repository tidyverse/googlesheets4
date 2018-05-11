#' Visit Sheet in browser
#'
#' Visits a Google Sheet in your default browser. TODO: Note that there is no
#' provision for auth yet, so will only work for a Sheet that is readable to
#' anyone.
#'
#' @inheritParams sheets_cells
#'
#' @return Character vector of file hyperlinks, from
#'   [googledrive::drive_link()], invisibly.
#' @export
#' @examples
#' \dontrun{
#' sheets_example("mini-gap") %>% sheets_browse()
#' }
sheets_browse <- function(ss) {
  googledrive::drive_browse(as_sheets_id(ss))
}
