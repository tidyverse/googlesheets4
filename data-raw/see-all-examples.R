library(devtools)
library(fs)
library(here)
library(purrr)

# setup and/or clean
here("examples") %>%
  dir_create() %>%
  dir_ls() %>%
  file_delete()

rd_files <- here("man") %>% dir_ls(regex = "[.][Rr]d$")

do_one <- function(x) {
  print(path_file(x))
  tmp <- file_temp()
  tools::Rd2ex(x, out = tmp)
  if (file_exists(tmp)) {
    cat(
      readLines(tmp),
      file = here("examples", "googlesheets4-examples.R"),
      append = TRUE,
      sep = "\n"
    )
  } else {
    print("  ^ no examples!!")
  }
}
walk(rd_files, do_one)
