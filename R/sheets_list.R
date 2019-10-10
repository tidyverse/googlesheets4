#' List your Google Sheets
#'
#' Lists your Google Sheets. This is a very thin wrapper around
#' [googledrive::drive_find()], that specifies you want to list Drive files
#' where `type = "spreadsheet"`. Therefore, note that this will require auth for
#' googledrive! See the article [Using googlesheets4 with
#' googledrive](https://googlesheets4.tidyverse.org/articles/articles/drive-and-sheets.html)
#' if you want to coordinate auth between googlesheets4 and googledrive.
#'
#' @param ... Arguments (other than `type`, which is hard-wired as `type =
#'   "spreadsheet"`) that are passed along to [googledrive::drive_find()].
#'
#' @inherit googledrive::drive_find return
#' @export
#'
#' @examples
#' if (sheets_has_token()) {
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
