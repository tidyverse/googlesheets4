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
#> • gs4-create-demo-6 <id: 1jfvkNBWxOlfisXYhD05tiSPxLBB-8gJ791WkK6YWAs0>
#> • gs4-create-demo-5 <id: 1k3RZPnCABvELfKrAnEdjAJMnBP70hVkJxkNNSSvwWXg>
#> • gs4-create-demo-4 <id: 1zJDhi_jikNaQEkchBH1XNHqezCj6Bn7y9-NrbZYpYIg>
#> • gs4-create-demo-3 <id: 1x_OfziPkHsN2a6Uo8zJLqC-c7XfnVLGxW95wU4aMxvE>
#> • gs4-create-demo-2 <id: 1rdWTjupUnqWrWGrB8tvxt6K1nHMhmrBy9ynbJCck_uM>
#> • gs4-create-demo-1 <id: 1A34NAZ7rp6uc053yce8O2BavymHSi8s2rooIze0VZ8M>
```
