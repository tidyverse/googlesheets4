library(tidyverse)
library(googledrive)
library(googlesheets4)
library(readxl)

googlesheets4:::gs4_auth_docs()
gs4_user()

deaths_xlsx <- readxl_example("deaths.xlsx")

ss <- drive_upload(deaths_xlsx, name = "deaths", type = "spreadsheet")

gs4_share(ss, type = "user", emailAddress = "jenny@rstudio.com", role = "writer")

# in the browser, I created named data ranges 'arts_data' and 'other_data'
