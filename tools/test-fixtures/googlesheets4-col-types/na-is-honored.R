# https://github.com/tidyverse/googlesheets4/issues/73
devtools::load_all() # I assume we're in googlesheets4 source
library(googledrive)
library(tidyverse)

googlesheets4:::sheets_auth_testing()

ss <- test_sheet_create("googlesheets4-col-types")
sheets_browse(ss)

df <- tibble(
  A = list(1, "Missing", 3),
  B = list(1, "NA", 3),
  C = c(1, NA, 3),
  D = 1:3
)
sheets_sheet_add(ss, sheet = "NAs")
sheets_write(df, ss, sheet = "NAs")
