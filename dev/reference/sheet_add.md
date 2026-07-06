# Add one or more (work)sheets

Adds one or more (work)sheets to an existing (spread)Sheet. Note that
sheet names must be unique.

## Usage

``` r
sheet_add(ss, sheet = NULL, ..., .before = NULL, .after = NULL)
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

  One or more new sheet names. If unspecified, one new sheet is added
  and Sheets autogenerates a name of the form "SheetN".

- ...:

  Optional parameters to specify additional properties, common to all of
  the new sheet(s). Not relevant to most users. Specify fields of the
  [`SheetProperties`
  schema](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#SheetProperties)
  in `name = value` form.

- .before, .after:

  Optional specification of where to put the new sheet(s). Specify, at
  most, one of `.before` and `.after`. Refer to an existing sheet by
  name (via a string) or by position (via a number). If unspecified,
  Sheets puts the new sheet(s) at the end.

## Value

The input `ss`, as an instance of
[`sheets_id`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

## See also

Makes a batch of `AddSheetRequest`s (one per sheet):

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#addsheetrequest>

Other worksheet functions:
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
[`sheet_copy()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_copy.md),
[`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md),
[`sheet_properties()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md),
[`sheet_relocate()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_relocate.md),
[`sheet_rename()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_rename.md),
[`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

## Examples

``` r
ss <- gs4_create("add-sheets-to-me")
#> ✔ Creating new Sheet: add-sheets-to-me.

# the only required argument is the target spreadsheet
ss %>% sheet_add()
#> ✔ Adding 1 sheet to add-sheets-to-me:
#> • Sheet2

# but you CAN specify sheet name and/or position
ss %>% sheet_add("apple", .after = 1)
#> ✔ Adding 1 sheet to add-sheets-to-me:
#> • apple
ss %>% sheet_add("banana", .after = "apple")
#> ✔ Adding 1 sheet to add-sheets-to-me:
#> • banana

# add multiple sheets at once
ss %>% sheet_add(c("coconut", "dragonfruit"))
#> ✔ Adding 2 sheets to add-sheets-to-me:
#> • coconut
#> • dragonfruit

# keeners can even specify additional sheet properties
ss %>%
  sheet_add(
    sheet = "eggplant",
    .before = 1,
    gridProperties = list(
      rowCount = 3, columnCount = 6, frozenRowCount = 1
    )
  )
#> ✔ Adding 1 sheet to add-sheets-to-me:
#> • eggplant

# get an overview of the sheets
sheet_properties(ss)
#> # A tibble: 7 × 8
#>   name        index      id type  visible grid_rows grid_columns data  
#>   <chr>       <int>   <int> <chr> <lgl>       <int>        <int> <list>
#> 1 eggplant        0  2.03e9 GRID  TRUE            3            6 <NULL>
#> 2 Sheet1          1  0      GRID  TRUE         1000           26 <NULL>
#> 3 apple           2  2.10e9 GRID  TRUE         1000           26 <NULL>
#> 4 banana          3  6.54e8 GRID  TRUE         1000           26 <NULL>
#> 5 Sheet2          4  5.16e8 GRID  TRUE         1000           26 <NULL>
#> 6 coconut         5  1.81e9 GRID  TRUE         1000           26 <NULL>
#> 7 dragonfruit     6  8.45e8 GRID  TRUE         1000           26 <NULL>

# clean up
gs4_find("add-sheets-to-me") %>%
  googledrive::drive_trash()
#> File trashed:
#> • add-sheets-to-me <id: 1ZyynSgmkU2_sNZeh6P-3QZaXCLY0kvMgzBlUOgkueOs>
```
