library(tidyverse)
devtools::load_all() # I assume we're in googlesheets4 source
library(googledrive)

sheets_auth_testing()

ss <- test_sheet_create()
sheets_browse(ss)

# TODO: I created this worksheet in the browser; add code here once possible

# I riffed on the original Sheet provided by @nadnudus in
# https://github.com/tidyverse/googlesheets4/issues/4
# ssid <- as_sheets_id("1UbdlyITXLvsxQt6kpszu5gfiDmF5Q-wOrNC7l4E9jOg")
# sheets_browse(ss)
# I copied the "legend" worksheet.
# Added a note to C1.
# Added a comment (as rstudio jenny) to C2.
