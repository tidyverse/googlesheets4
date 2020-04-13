library(tidyverse)
devtools::load_all() # I assume we're in googlesheets4 source
library(googledrive)

gs4_auth_testing()

ss <- test_sheet_create()
gs4_browse(ss)

# TODO: I created this worksheet in the browser, by copying from
# gs4_example("formulas-and-formats")
# add code here once possible
# most challenging cell is B4, the one that contains
# =IMAGE("https://www.google.com/images/srpr/logo3w.png")
# i.e. a formula that evaluates to an image
