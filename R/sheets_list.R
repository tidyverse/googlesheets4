#' List your Google Sheets
#'
#' Lists your Google Sheets. This is a very thin wrapper around
#' [googledrive::drive_find()], that specifies you want to list Drive files
#' where `type = "spreadsheet"`.
#'
#' @param ... Arguments (other than `type`, which is hard-wired as `type =
#'   "spreadsheet"`) that are passed along to [googledrive::drive_find()].
#'
#' @inherit googledrive::drive_find return
#' @export
#'
#' @examples
#' if (interactive()) {
#'   # see all your Sheets
#'   sheets_list()
#'
#'   # see 5 Sheets, prioritized by creation time
#'   x <- sheets_list(order_by = "createdTime desc", n_max = 5)
#'   x
#'
#'   # hoist the creation date, using other packages in the tidyverse
#'   # x %>%
#'   #   tidyr::hoist(drive_resource, created_on = "createdTime") %>%
#'   #   dplyr::mutate(created_on = as.Date(created_on))
#' }
sheets_list <- function(...) {
  googledrive::drive_find(..., type = "spreadsheet")
}
