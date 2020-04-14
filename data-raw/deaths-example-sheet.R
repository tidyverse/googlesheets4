library(tidyverse)
library(googledrive)
library(googlesheets4)
library(readxl)

googlesheets4:::gs4_auth_docs()
gs4_user()

x <- gs4_find()

if ("deaths" %in% x$name) {
  stop("Yo, 'deaths' already exists. Are you sure you want to do this?")
}

# to work on an existing 'deaths' Sheet
# ss <- gs4_find("deaths") %>% as_sheets_id()

# to create one from scratch
deaths_xlsx <- readxl_example("deaths.xlsx")
ss <- drive_upload(deaths_xlsx, name = "deaths", type = "spreadsheet")

googlesheets4:::gs4_share(ss)

gs4_browse(ss)

googlesheets4:::range_add_named(ss, name = "arts_data", range = "arts!A5:F15")
googlesheets4:::range_add_named(ss, name = "other_data", range = "other!A5:F15")

ss

unclass(ss)
