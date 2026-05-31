# Create a new Sheet

Creates an entirely new (spread)Sheet (or, in Excel-speak, workbook).
Optionally, you can also provide names and/or data for the initial set
of (work)sheets. Any initial data provided via `sheets` is styled as a
table, as described in
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md).

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
[`sheets_id`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

## See also

Wraps the `spreadsheets.create` endpoint:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create>

There is an article on writing Sheets:

- <https://googlesheets4.tidyverse.org/articles/articles/write-sheets.html>

Other write functions:
[`gs4_formula()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_formula.md),
[`range_delete()`](https://googlesheets4.tidyverse.org/dev/reference/range_delete.md),
[`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md),
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

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
#> • gs4-create-demo-6 <id: 1K7FdsQKBi_DBU2k5aoHZLdldch-opveRDWSvdAJjPUA>
#> • gs4-create-demo-5 <id: 1msZrkg0pJ6s9EhT-UT506WNZ8gZ-dprXVcHpHkj2VFg>
#> • gs4-create-demo-4 <id: 1rDLZV8QMvFYOOAli3Z2lGrAKw9p9jRFOQ2v-E42YbdU>
#> • gs4-create-demo-3 <id: 1DLOOPlsxHVUQojhFx0xL45JwRJSIz1Okmh3ZAAbvT1o>
#> • gs4-create-demo-2 <id: 1W836bHiwf6rYW1WYgxbea0j7dMmNDc5ICSzsCu6pAcw>
#> • gs4-create-demo-1 <id: 1nfAZnMq3AUw-8HMhC_aYlTKRPjNdUj8qldYddRsyb68>
```
