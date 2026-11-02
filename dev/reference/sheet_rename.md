# Rename a (work)sheet

Changes the name of a (work)sheet.

## Usage

``` r
sheet_rename(ss, sheet = NULL, new_name)
```

## Arguments

- ss:

  Something that identifies a Google Sheet:

  - its file id as a string or
    [`drive_id`](https://googledrive.tidyverse.org/reference/drive_id.html)

  - a URL from which we can recover the id

  - a one-row
    [`dribble`](https://googledrive.tidyverse.org/reference/dribble.html),
    which is how googledrive represents Drive files

  - an instance of `googlesheets4_spreadsheet`, which is what
    [`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
    returns

  Processed through
  [`as_sheets_id()`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md).

- sheet:

  Sheet to rename, in the sense of "worksheet" or "tab". You can
  identify a sheet by name, with a string, or by position, with a
  number. Defaults to the first visible sheet.

- new_name:

  New name of the sheet, as a string. This is required.

## Value

The input `ss`, as an instance of
[`sheets_id`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

## See also

Makes an `UpdateSheetPropertiesRequest`:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest>

Other worksheet functions:
[`sheet_add()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_add.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
[`sheet_copy()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_copy.md),
[`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md),
[`sheet_properties()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md),
[`sheet_relocate()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_relocate.md),
[`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

## Examples

``` r
ss <- gs4_create(
  "sheet-rename-demo",
  sheets = list(cars = head(cars), chickwts = head(chickwts))
)
#> ✔ Creating new Sheet: sheet-rename-demo.
sheet_names(ss)
#> ✖ Request 1 failed [429: RESOURCE_EXHAUSTED, per user quota].
#> ℹ Will retry in 61.5s.
#> ⠙ Retry happens in  1m
#> ⠹ Retry happens in  1m
#> ⠸ Retry happens in  1m
#> ⠼ Retry happens in  1m
#> ⠴ Retry happens in  1m
#> ⠦ Retry happens in 49s
#> ⠧ Retry happens in 46s
#> ⠇ Retry happens in 43s
#> ⠏ Retry happens in 40s
#> ⠋ Retry happens in 37s
#> ⠙ Retry happens in 34s
#> ⠹ Retry happens in 31s
#> ⠸ Retry happens in 28s
#> ⠼ Retry happens in 25s
#> ⠴ Retry happens in 22s
#> ⠦ Retry happens in 19s
#> ⠧ Retry happens in 16s
#> ⠇ Retry happens in 13s
#> ⠏ Retry happens in 10s
#> ⠋ Retry happens in  7s
#> ⠙ Retry happens in  4s
#> ⠹ Retry happens in  1s
#> ⠹ Retry happens in  0s
#> ✖ Request 2 failed [429: RESOURCE_EXHAUSTED, per user quota].
#> ℹ Will retry in 3.9s.
#> ⠙ Retry happens in  2s
#> ⠙ Retry happens in  0s
#> ✔ Request 3 successful!
#> [1] "cars"     "chickwts"

ss %>%
  sheet_rename(1, new_name = "automobiles") %>%
  sheet_rename("chickwts", new_name = "poultry")
#> ✔ Renaming sheet cars to automobiles.
#> ✔ Renaming sheet chickwts to poultry.

# clean up
gs4_find("sheet-rename-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • sheet-rename-demo <id: 1UWXwMs5Z7V7AiAiolYzvsiMr6vySfyWCWywaSt13k44>
```
