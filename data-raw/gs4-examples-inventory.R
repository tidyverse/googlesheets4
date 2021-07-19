# given the files owned by the googlesheets4-sheet-keeper service account,
# create/update an inventory file consulted by gs4_examples()

library(here)
library(googledrive)
library(tidyverse)
library(googlesheets4)

# auth with the special-purpose service account
gs4_auth(
  path = "~/.R/gargle/googlesheets4-sheet-keeper.json",
  scopes = "https://www.googleapis.com/auth/drive"
)
gs4_user()
drive_auth(token = gs4_token())
drive_user()

# exclude the inventory Sheet ... too meta!
dat <- drive_find(q = "not name contains 'gs4_example_and_test_sheets'")

if (anyDuplicated(dat$name)) {
  stop("Duplicated file names! You are making a huge mistake.")
}

dat <- dat %>%
  mutate(
    purpose = if_else(str_detect(name, "^googlesheets4"), "test", "example")
  ) %>%
  select(name, purpose, id) %>%
  arrange(purpose, name)

# record in local csv, because the visibility afforded by a plain old csv file
# is useful to me, e.g. easy to see change over time
write_csv(
  dat,
  file = here("inst", "extdata", "example_and_test_sheets.csv")
)

# initial creation

# ss <- gs4_create(
#   "gs4_example_and_test_sheets",
#   sheets = list(gs4_example_and_test_sheets = dat)
# )
# drive_share_anyone(ss)
# drive_publish(ss)

# as_id(ss)
# 1dSIZ2NkEPDWiEbsg9G80Hr9Xe7HZglEAPwGhVa-OSyA

# in future, write over the data to update
ssid <- as_sheets_id("1dSIZ2NkEPDWiEbsg9G80Hr9Xe7HZglEAPwGhVa-OSyA")
ss <- gs4_get(ssid)
ss

# range_autofit(ss)
drive_browse(ssid)
