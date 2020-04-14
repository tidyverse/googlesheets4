library(tidyverse)
library(googledrive)
library(googlesheets4)
library(gapminder)

googlesheets4:::gs4_auth_docs()

# if I were making the gapminder sheet from scratch, here's what I would do now:
ss <- gs4_create(
  "gapminder-reboot",
  sheets = split(gapminder, gapminder$continent)
)
drive_trash(ss)
# but I am not doing this -- I want to keep the existing Sheet ID
# instead I will edit it (and mini-gap) in situ

## Update gapminder example Sheet ----
ss <- gs4_find("gapminder") %>% as_sheets_id()
# gs4_browse(ss)

gapminder_split <- split(gapminder, gapminder$continent)
sheet_write(gapminder_split$Africa,   ss = ss, sheet = "Africa")
sheet_write(gapminder_split$Americas, ss = ss, sheet = "Americas")
sheet_write(gapminder_split$Asia,     ss = ss, sheet = "Asia")
sheet_write(gapminder_split$Europe,   ss = ss, sheet = "Europe")
sheet_write(gapminder_split$Oceania,  ss = ss, sheet = "Oceania")

## Update mini-gap example Sheet ----
mini_gap <- gapminder %>%
  arrange(year) %>%
  group_by(continent) %>%
  slice(1:5) %>%
  split(.$continent)

(ss <- gs4_find("mini-gap") %>% as_sheets_id())
# gs4_browse(ss)

sheet_write(mini_gap$Africa,   ss = ss, sheet = "Africa")
sheet_write(mini_gap$Americas, ss = ss, sheet = "Americas")
sheet_write(mini_gap$Asia,     ss = ss, sheet = "Asia")
sheet_write(mini_gap$Europe,   ss = ss, sheet = "Europe")
sheet_write(mini_gap$Oceania,  ss = ss, sheet = "Oceania")
