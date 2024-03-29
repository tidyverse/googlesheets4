% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gs4_find.R
\name{gs4_find}
\alias{gs4_find}
\title{Find Google Sheets}
\usage{
gs4_find(...)
}
\arguments{
\item{...}{Arguments (other than \code{type}, which is hard-wired as \code{type = "spreadsheet"}) that are passed along to \code{\link[googledrive:drive_find]{googledrive::drive_find()}}.}
}
\value{
An object of class \code{\link[googledrive]{dribble}}, a tibble with one row per file.
}
\description{
Finds your Google Sheets. This is a very thin wrapper around
\code{\link[googledrive:drive_find]{googledrive::drive_find()}}, that specifies you want to list Drive files
where \code{type = "spreadsheet"}. Therefore, note that this will require auth for
googledrive! See the article \href{https://googlesheets4.tidyverse.org/articles/articles/drive-and-sheets.html}{Using googlesheets4 with googledrive}
if you want to coordinate auth between googlesheets4 and googledrive. This
function will emit an informational message if you are currently logged in
with both googlesheets4 and googledrive, but as different users.
}
\examples{
\dontshow{if (gs4_has_token()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
# see all your Sheets
gs4_find()

# see 5 Sheets, prioritized by creation time
x <- gs4_find(order_by = "createdTime desc", n_max = 5)
x

# hoist the creation date, using other packages in the tidyverse
# x \%>\%
#   tidyr::hoist(drive_resource, created_on = "createdTime") \%>\%
#   dplyr::mutate(created_on = as.Date(created_on))
\dontshow{\}) # examplesIf}
}
