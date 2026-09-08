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
#> ✖ Request 1 failed [503: UNAVAILABLE].
#> ℹ Will retry in 1.8s.
#> ✖ Request 2 failed [503: UNAVAILABLE].
#> ℹ Will retry in 8s.
#> ⠙ Retry happens in  7s
#> ⠹ Retry happens in  6s
#> ⠸ Retry happens in  3s
#> ⠼ Retry happens in  0s
#> ✖ Request 3 failed [503: UNAVAILABLE].
#> ⠼ Retry happens in  0s
#> ℹ Will retry in 4.2s.
#> ⠼ Retry happens in  0s
#> ⠼ Retry happens in  0s
#> ⠙ Retry happens in  2s
#> ✔ Request 4 successful!
#> ⠙ Retry happens in  2s
#> ⠙ Retry happens in  0s

# Clean up
gs4_find("gs4-create-demo") %>%
  googledrive::drive_trash()
#> Files trashed:
#> • gs4-create-demo-6 <id: 1ljAi9LbhMEiH5OTbWzdfCDZUOKWxhi0LGXq2wMJ4wGE>
#> • gs4-create-demo-5 <id: 1lermV7UUb-GT_O9ayCDAT70_S1J47_L6ChIQPShA-Hk>
#> • gs4-create-demo-4 <id: 1AN0hGMlLMZ5Cb1t0feb9jC6bpK_xia_a_GiGSDcxjo4>
#> • gs4-create-demo-3 <id: 1KSRoSrxEJ4uLbH6pAPj0VVYVJ2T2dGbr1P3sMVWlkA4>
#> • gs4-create-demo-2 <id: 1QlSsFvbqRQd5t1MruMN8FyFzmjRPpLJqxR1DpMX8jyU>
#> • gs4-create-demo-1 <id: 1uFKtlVs_wKFONVtN6yG_IcW6iwZ8cbe8qFNp-57Fkqk>
```
