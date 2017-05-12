## used to control whether we run tests that
##   * call the Sheets API
Sys.setenv("GOOGLESHEETS_HIT_API" = TRUE)
hit_api <- function() {
  as.logical(Sys.getenv("GOOGLESHEETS_HIT_API", unset = "FALSE"))
}
##   * call the Sheets API AND send an OAuth token
Sys.setenv("GOOGLESHEETS_USE_AUTH" = FALSE)
use_auth <- function() {
  hit_api() &&
  as.logical(Sys.getenv("GOOGLESHEETS_USE_AUTH", unset = "FALSE"))
}

## usage:
## to skip a test if GOOGLESHEETS_HIT_API is not TRUE, use
## skip_if_not(hit_api())
## to skip a test if either GOOGLESHEETS_HIT_API or GOOGLESHEETS_USE_AUTH
## is not true, use
## skip_if_not(use_auth())
