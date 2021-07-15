# making some changes to
# test Sheet: googlesheets4-col-types
# sheet: NAs

# I want the ID to remain the same, so will modify existing Sheet
library(googlesheets4)
library(googledrive)
library(tidyverse)

gs4_auth(
  path = "~/.R/gargle/googlesheets4-sheet-keeper.json",
  scopes = "https://www.googleapis.com/auth/drive"
)
gs4_user()

examples <- googlesheets4:::.test_sheets
ssid <- examples["googlesheets4-col-types"]
(ss <- gs4_get(ssid))

dat <- tribble(
  ~...Missing,  ~...NA,  ~space, ~empty_string, ~truly_empty, ~complete,
        "one",   "one",   "one",         "one",        "one",     "one",
    "Missing",    "NA",     " ",            "",           NA,     "two",
      "three", "three", "three",       "three",      "three",   "three"
)

write_sheet(dat, ssid, sheet = "NAs")

range_read(ssid)
