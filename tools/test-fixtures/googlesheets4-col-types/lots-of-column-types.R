devtools::load_all() # I assume we're in googlesheets4 source
library(googledrive)
library(tidyverse)

# googlesheets4:::gs4_auth_testing()

ss <- test_sheet_create("googlesheets4-col-types")
gs4_browse(ss)

df <- tibble(
  logical = c(TRUE, FALSE, NA, TRUE),
  character = c("apple", "banana", "cherry", "durian"),
  factor = factor(c("one", "two", "three", "four")),
  integer = 1:4,
  double = 4:1 - 2.5,
  date = as.Date(c("2003-06-06", "1982-12-05", "2014-02-14", "1999-08-27")),
  datetime = as.POSIXct(c("1978-05-31 04:24:32", "2006-07-19 23:27:37",
                          "2003-12-21 09:20:29", "1975-04-14 13:31:03"))
)

sheet_write(df, ss, sheet = "lots-of-types")
