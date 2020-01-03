library(tidyverse)

source(
  system.file("discovery-doc-ingest", "ingest-functions.R", package = "gargle")
)

# if my use of schemas works out well, maybe this will migrate upstream into
# gargle and join the other ingest helpers
source(here::here("data-raw", "schema-rectangling.R"))

existing <- list_discovery_documents("sheets")
if (length(existing) > 1) {
  rlang::warn("MULTIPLE DISCOVERY DOCUMENTS FOUND. FIX THIS!")
}

if (length(existing) < 1) {
  rlang::inform("Downloading Discovery Document")
  x <- download_discovery_document("sheets:v4")
} else {
  msg <- glue::glue("
    Using existing Discovery Document:
      * {existing}
    ")
  rlang::inform(msg)
  x <- here::here("data-raw", existing)
}

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
  "GridRange",
  "RepeatCellRequest",
  "CellData",
  "RowData",
  "CellFormat",
  "Color",
  "TextFormat",
  "UpdateCellsRequest",
  "UpdateSheetPropertiesRequest",
  "GridCoordinate",
  "DeleteDimensionRequest",
  "InsertDimensionRequest",
  "DimensionRange",
  "GridProperties"
)

.tidy_schemas <- these %>%
  set_names() %>%
  map(schema_rectangle)
# View(.tidy_schemas)

fs::dir_create(here::here("data-raw", "schemas"))
write_one <- function(data, id) {
  sink(here::here("data-raw", "schemas", id))
  withr::local_options(list(width = 150))
  cat("#", id, " \n")
  print(data, n = Inf, width = Inf)
  sink()
}
iwalk(.tidy_schemas, write_one)

usethis::use_data(
  .endpoints, .schemas, .tidy_schemas,
  internal = TRUE, overwrite = TRUE
)
