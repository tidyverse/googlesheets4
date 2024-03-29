% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gs4_create.R
\name{gs4_create}
\alias{gs4_create}
\title{Create a new Sheet}
\usage{
gs4_create(name = gs4_random(), ..., sheets = NULL)
}
\arguments{
\item{name}{The name of the new spreadsheet.}

\item{...}{Optional spreadsheet properties that can be set through this API
endpoint, such as locale and time zone.}

\item{sheets}{Optional input for initializing (work)sheets. If unspecified,
the Sheets API automatically creates an empty "Sheet1". You can provide a
vector of sheet names, a data frame, or a (possibly named) list of data
frames. See the examples.}
}
\value{
The input \code{ss}, as an instance of \code{\link{sheets_id}}
}
\description{
Creates an entirely new (spread)Sheet (or, in Excel-speak, workbook).
Optionally, you can also provide names and/or data for the initial set of
(work)sheets. Any initial data provided via \code{sheets} is styled as a table,
as described in \code{\link[=sheet_write]{sheet_write()}}.
}
\examples{
\dontshow{if (gs4_has_token()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
gs4_create("gs4-create-demo-1")

gs4_create("gs4-create-demo-2", locale = "en_CA")

gs4_create(
  "gs4-create-demo-3",
  locale = "fr_FR",
  timeZone = "Europe/Paris"
)

gs4_create(
  "gs4-create-demo-4",
  sheets = c("alpha", "beta")
)

my_data <- data.frame(x = 1)
gs4_create(
  "gs4-create-demo-5",
  sheets = my_data
)

gs4_create(
  "gs4-create-demo-6",
  sheets = list(chickwts = head(chickwts), mtcars = head(mtcars))
)

# Clean up
gs4_find("gs4-create-demo") \%>\%
  googledrive::drive_trash()
\dontshow{\}) # examplesIf}
}
\seealso{
Wraps the \code{spreadsheets.create} endpoint:
\itemize{
\item \url{https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create}
}

There is an article on writing Sheets:
\itemize{
\item \url{https://googlesheets4.tidyverse.org/articles/articles/write-sheets.html}
}

Other write functions: 
\code{\link{gs4_formula}()},
\code{\link{range_delete}()},
\code{\link{range_flood}()},
\code{\link{range_write}()},
\code{\link{sheet_append}()},
\code{\link{sheet_write}()}
}
\concept{write functions}
