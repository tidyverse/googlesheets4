library(tidyverse)
devtools::load_all() # I assume we're in googlesheets4 source
library(googledrive)

sheets_auth_testing()

ss <- test_sheet_create()
sheets_browse(ss)

# TODO: I created this worksheet in the browser, by copying from
# sheets_example("formulas-and-formats")
# add code here once possible
# most challenging cell is B4, the one that contains
# =IMAGE("https://www.google.com/images/srpr/logo3w.png")
# i.e. a formula that evaluates to an image
