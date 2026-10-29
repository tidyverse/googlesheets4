# Create a new Sheet

Creates an entirely new (spread)Sheet (or, in Excel-speak, workbook).
Optionally, you can also provide names and/or data for the initial set
of (work)sheets. Any initial data provided via `sheets` is styled as a
table, as described in
[`sheet_write()`](https://googlesheets4.tidyverse.org/reference/sheet_write.md).

## Usage

``` r
gs4_create(name = gs4_random(), ..., sheets = NULL)
```

## Arguments

- name:

  The name of the new spreadsheet.

- ...:

  Optional spreadsheet properties that can be set through this API
  endpoint, such as locale and time zone.

- sheets:

  Optional input for initializing (work)sheets. If unspecified, the
  Sheets API automatically creates an empty "Sheet1". You can provide a
  vector of sheet names, a data frame, or a (possibly named) list of
  data frames. See the examples.

## Value

The input `ss`, as an instance of
[`sheets_id`](https://googlesheets4.tidyverse.org/reference/sheets_id.md)

## See also

Wraps the `spreadsheets.create` endpoint:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create>

There is an article on writing Sheets:

- <https://googlesheets4.tidyverse.org/articles/articles/write-sheets.html>

Other write functions:
[`gs4_formula()`](https://googlesheets4.tidyverse.org/reference/gs4_formula.md),
[`range_delete()`](https://googlesheets4.tidyverse.org/reference/range_delete.md),
[`range_flood()`](https://googlesheets4.tidyverse.org/reference/range_flood.md),
[`range_write()`](https://googlesheets4.tidyverse.org/reference/range_write.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/reference/sheet_append.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/reference/sheet_write.md)

## Examples

``` r
gs4_create("gs4-create-demo-1")
#> ✔ Creating new Sheet: gs4-create-demo-1.

gs4_create("gs4-create-demo-2", locale = "en_CA")
#> ✔ Creating new Sheet: gs4-create-demo-2.

gs4_create(
  "gs4-create-demo-3",
  locale = "fr_FR",
  timeZone = "Europe/Paris"
)
#> ✔ Creating new Sheet: gs4-create-demo-3.

gs4_create(
  "gs4-create-demo-4",
  sheets = c("alpha", "beta")
)
#> ✔ Creating new Sheet: gs4-create-demo-4.

my_data <- data.frame(x = 1)
gs4_create(
  "gs4-create-demo-5",
  sheets = my_data
)
#> ✔ Creating new Sheet: gs4-create-demo-5.

gs4_create(
  "gs4-create-demo-6",
  sheets = list(chickwts = head(chickwts), mtcars = head(mtcars))
)
#> ✔ Creating new Sheet: gs4-create-demo-6.

# Clean up
gs4_find("gs4-create-demo") %>%
  googledrive::drive_trash()
#> Files trashed:
#> • gs4-create-demo-6 <id: 1aOwiHxULBx40cC1GSVYyNI1klecBlVqhU1egYioNxLs>
#> • gs4-create-demo-5 <id: 1V6qwCDkcebDGPPvRtWYu26sdRyU5H-1c0i1CTEKvBw0>
#> • gs4-create-demo-4 <id: 1ZV26D1uiZopunJetBc-1T_lnTGCzouS79zS2tZaO43k>
#> • gs4-create-demo-3 <id: 1tPpCE8W1q8C3KVLhaE7FeW6ndbDMZujziYyBZgN7Asc>
#> • gs4-create-demo-2 <id: 1kgo3EMcPgPiK-t6Uk3jX-Hsy0ywmA6FdTxax6-bBjmo>
#> • gs4-create-demo-1 <id: 1D-vvlmQlcVJmKnw3sW0BmpWZA0yCLuc6d2omAfTapLo>
```
