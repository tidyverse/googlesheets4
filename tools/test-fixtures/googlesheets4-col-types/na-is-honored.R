# https://github.com/tidyverse/googlesheets4/issues/73
devtools::load_all() # I assume we're in googlesheets4 source
library(googledrive)
library(tidyverse)

googlesheets4:::gs4_auth_testing()

ss <- test_sheet_create("googlesheets4-col-types")
gs4_browse(ss)

df <- tibble(
  A = list(1, "Missing", 3),
  B = list(1, "NA", 3),
  C = c(1, NA, 3),
  D = 1:3
)
sheet_add(ss, sheet = "NAs")
sheet_write(df, ss, sheet = "NAs")
