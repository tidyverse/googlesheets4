library(tidyverse)
devtools::load_all() # I assume we're in googlesheets4 source
library(googledrive)

googlesheets4:::sheets_auth_testing()

ss <- test_sheet_create()
sheets_browse(ss)

n <- 5
df <- expand_grid(column = LETTERS[seq_len(n)], row = seq_len(n) + 1) %>%
  unite("cell", sep = "", remove = FALSE) %>%
  pivot_wider(id_cols = row, names_from = column, values_from = cell) %>%
  select(-row)
sheets_write(df, ss, sheet = "range-experimentation")
