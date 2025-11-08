# Package index

## Reading

Import data from a Sheet into a local data frame

- [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  [`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  : Read a Sheet into a data frame
- [`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
  : Read Sheet as CSV
- [`range_read_cells()`](https://googlesheets4.tidyverse.org/dev/reference/range_read_cells.md)
  : Read cells from a Sheet
- [`spread_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/spread_sheet.md)
  : Spread a data frame of cells into spreadsheet shape
- [`cell-specification`](https://googlesheets4.tidyverse.org/dev/reference/cell-specification.md)
  [`cell_limits`](https://googlesheets4.tidyverse.org/dev/reference/cell-specification.md)
  [`cell_rows`](https://googlesheets4.tidyverse.org/dev/reference/cell-specification.md)
  [`cell_cols`](https://googlesheets4.tidyverse.org/dev/reference/cell-specification.md)
  [`anchored`](https://googlesheets4.tidyverse.org/dev/reference/cell-specification.md)
  : Specify cells

## Writing

Write data into a Sheet

- [`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
  [`write_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
  : (Over)write new data into a Sheet
- [`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
  : Create a new Sheet
- [`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)
  : Append rows to a sheet
- [`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
  : (Over)write new data into a range
- [`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md)
  [`range_clear()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md)
  : Flood or clear a range of cells

## Data preparation

Helpers for preparing data to write into Sheets

- [`gs4_fodder()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_fodder.md)
  : Create useful spreadsheet filler
- [`gs4_formula()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_formula.md)
  : Class for Google Sheets formulas

## Metadata on Sheets

Helpers for accessing Sheets and their metadata

- [`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
  : Get Sheet metadata

- [`gs4_find()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_find.md)
  : Find Google Sheets

- [`gs4_browse()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_browse.md)
  : Visit a Sheet in a web browser

- [`as_sheets_id()`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)
  :

  `sheets_id` class

- [`gs4_random()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_random.md)
  : Generate a random Sheet name

## Modify a Sheet

Make changes to a (spread)Sheet or to the (work)sheets it contains

- [`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
  : Create a new Sheet

- [`range_delete()`](https://googlesheets4.tidyverse.org/dev/reference/range_delete.md)
  : Delete cells

- [`sheet_add()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_add.md)
  : Add one or more (work)sheets

- [`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)
  : Append rows to a sheet

- [`sheet_copy()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_copy.md)
  : Copy a (work)sheet

- [`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md)
  : Delete one or more (work)sheets

- [`sheet_properties()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md)
  [`sheet_names()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md)
  : Get data about (work)sheets

- [`sheet_relocate()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_relocate.md)
  : Relocate one or more (work)sheets

- [`sheet_rename()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_rename.md)
  : Rename a (work)sheet

- [`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md)
  : Change the size of a (work)sheet

- [`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
  [`write_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
  : (Over)write new data into a Sheet

- [`as_sheets_id()`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)
  :

  `sheets_id` class

## Formatting and aesthetics

Change how a Sheet appears in the browser UI

- [`range_autofit()`](https://googlesheets4.tidyverse.org/dev/reference/range_autofit.md)
  : Auto-fit columns or rows to the data

## Example Sheets

World-readable Sheets to use in examples and reprexes

- [`gs4_examples()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md)
  [`gs4_example()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md)
  : Example Sheets

## Auth

Take explicit control of the googlesheets4 auth status or examine
current state

- [`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md)
  : Authorize googlesheets4
- [`gs4_deauth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_deauth.md)
  : Suspend authorization
- [`gs4_user()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_user.md)
  : Get info on current user
- [`gs4_auth_configure()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md)
  [`gs4_api_key()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md)
  [`gs4_oauth_client()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md)
  : Edit and view auth configuration
- [`gs4_scopes()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_scopes.md)
  : Produce scopes specific to the Sheets API
- [`local_gs4_quiet()`](https://googlesheets4.tidyverse.org/dev/reference/googlesheets4-configuration.md)
  [`with_gs4_quiet()`](https://googlesheets4.tidyverse.org/dev/reference/googlesheets4-configuration.md)
  : googlesheets4 configuration

## Programming around the Sheets API

Low-level functions used internally and made available for programming

- [`request_generate()`](https://googlesheets4.tidyverse.org/dev/reference/request_generate.md)
  : Generate a Google Sheets API request
- [`request_make()`](https://googlesheets4.tidyverse.org/dev/reference/request_make.md)
  : Make a Google Sheets API request
- [`gs4_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_token.md)
  : Produce configured token
- [`gs4_has_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_has_token.md)
  : Is there a token on hand?
- [`gs4_endpoints()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_endpoints.md)
  : List Sheets endpoints
- [`local_gs4_quiet()`](https://googlesheets4.tidyverse.org/dev/reference/googlesheets4-configuration.md)
  [`with_gs4_quiet()`](https://googlesheets4.tidyverse.org/dev/reference/googlesheets4-configuration.md)
  : googlesheets4 configuration

## Operate on (spread)Sheets or the Sheets API

Functions that operate at the level of a (spread)sheet or the whole
API/package

- [`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md)
  : Authorize googlesheets4
- [`gs4_auth_configure()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md)
  [`gs4_api_key()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md)
  [`gs4_oauth_client()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md)
  : Edit and view auth configuration
- [`gs4_browse()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_browse.md)
  : Visit a Sheet in a web browser
- [`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
  : Create a new Sheet
- [`gs4_deauth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_deauth.md)
  : Suspend authorization
- [`gs4_endpoints()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_endpoints.md)
  : List Sheets endpoints
- [`gs4_examples()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md)
  [`gs4_example()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md)
  : Example Sheets
- [`gs4_find()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_find.md)
  : Find Google Sheets
- [`gs4_fodder()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_fodder.md)
  : Create useful spreadsheet filler
- [`gs4_formula()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_formula.md)
  : Class for Google Sheets formulas
- [`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
  : Get Sheet metadata
- [`gs4_has_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_has_token.md)
  : Is there a token on hand?
- [`gs4_random()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_random.md)
  : Generate a random Sheet name
- [`gs4_scopes()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_scopes.md)
  : Produce scopes specific to the Sheets API
- [`gs4_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_token.md)
  : Produce configured token
- [`gs4_user()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_user.md)
  : Get info on current user

## Operate on (work)sheets

Functions that operate on whole (work)sheets

- [`sheet_add()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_add.md)
  : Add one or more (work)sheets
- [`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)
  : Append rows to a sheet
- [`sheet_copy()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_copy.md)
  : Copy a (work)sheet
- [`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md)
  : Delete one or more (work)sheets
- [`sheet_properties()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md)
  [`sheet_names()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md)
  : Get data about (work)sheets
- [`sheet_relocate()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_relocate.md)
  : Relocate one or more (work)sheets
- [`sheet_rename()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_rename.md)
  : Rename a (work)sheet
- [`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md)
  : Change the size of a (work)sheet
- [`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
  [`write_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
  : (Over)write new data into a Sheet

## Operate on a range of cells

Functions that can target a cell range

- [`range_autofit()`](https://googlesheets4.tidyverse.org/dev/reference/range_autofit.md)
  : Auto-fit columns or rows to the data
- [`range_delete()`](https://googlesheets4.tidyverse.org/dev/reference/range_delete.md)
  : Delete cells
- [`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md)
  [`range_clear()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md)
  : Flood or clear a range of cells
- [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  [`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  : Read a Sheet into a data frame
- [`range_read_cells()`](https://googlesheets4.tidyverse.org/dev/reference/range_read_cells.md)
  : Read cells from a Sheet
- [`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
  : Read Sheet as CSV
- [`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
  : (Over)write new data into a range
