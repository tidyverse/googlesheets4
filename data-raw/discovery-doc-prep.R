library(tidyverse)

source(
  system.file("discovery-doc-ingest", "ingest-functions.R", package = "gargle")
)

# if my use of schemas works out well, maybe this will migrate upstream into
# gargle and join the other ingest helpers
source(here::here("data-raw", "schema-rectangling.R"))

x <- download_discovery_document("sheets:v4")
dd <- read_discovery_document(x)

methods      <- get_raw_methods(dd)
more_methods <- get_raw_methods(pluck(dd, "resources", "spreadsheets"))
methods <- c(methods, more_methods)

methods <- methods %>% map(groom_properties,  dd)
methods <- methods %>% map(add_schema_params, dd)
methods <- methods %>% map(add_global_params, dd)

.endpoints <- methods
attr(.endpoints, "base_url") <- dd$rootUrl
# View(.endpoints)

# I'm exploring the pros/cons of working with these more properly, as opposed
# to the "flattened" or "inlined" representation currently in .endpoints
.schemas <- pluck(dd, "schemas")

these <- c(
  "Spreadsheet",
  "SpreadsheetProperties",
  "Sheet",
  "SheetProperties",
  "NamedRange",
  "GridRange"
)

.tidy_schemas <- these %>%
  set_names() %>%
  map(schema_rectangle)
# View(.tidy_schemas)

usethis::use_data(
  .endpoints, .schemas, .tidy_schemas,
  internal = TRUE, overwrite = TRUE
)
