# Delete one or more (work)sheets

Deletes one or more (work)sheets from a (spread)Sheet.

## Usage

``` r
sheet_delete(ss, sheet)
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

  Sheet to delete, in the sense of "worksheet" or "tab". You can
  identify a sheet by name, with a string, or by position, with a
  number. You can pass a vector to delete multiple sheets at once or
  even a list, if you need to mix names and positions.

## Value

The input `ss`, as an instance of
[`sheets_id`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

## See also

Makes an `DeleteSheetsRequest`:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#DeleteSheetRequest>

Other worksheet functions:
[`sheet_add()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_add.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
[`sheet_copy()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_copy.md),
[`sheet_properties()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md),
[`sheet_relocate()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_relocate.md),
[`sheet_rename()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_rename.md),
[`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

## Examples

``` r
ss <- gs4_create("delete-sheets-from-me")
#> ✔ Creating new Sheet: delete-sheets-from-me.
sheet_add(ss, c("alpha", "beta", "gamma", "delta"))
#> ✔ Adding 4 sheets to delete-sheets-from-me:
#> • alpha
#> • beta
#> • gamma
#> • delta

# get an overview of the sheets
sheet_properties(ss)
#> # A tibble: 5 × 8
#>   name   index         id type  visible grid_rows grid_columns data  
#>   <chr>  <int>      <int> <chr> <lgl>       <int>        <int> <list>
#> 1 Sheet1     0          0 GRID  TRUE         1000           26 <NULL>
#> 2 alpha      1 1643479576 GRID  TRUE         1000           26 <NULL>
#> 3 beta       2  540142766 GRID  TRUE         1000           26 <NULL>
#> 4 gamma      3  145473789 GRID  TRUE         1000           26 <NULL>
#> 5 delta      4 1275759356 GRID  TRUE         1000           26 <NULL>

# delete sheets
sheet_delete(ss, 1)
#> ✔ Deleting 1 sheet from delete-sheets-from-me:
#> • Sheet1
sheet_delete(ss, "gamma")
#> ✔ Deleting 1 sheet from delete-sheets-from-me:
#> • gamma
sheet_delete(ss, list("alpha", 2))
#> ✔ Deleting 2 sheets from delete-sheets-from-me:
#> • alpha
#> • beta

# get an overview of the sheets
sheet_properties(ss)
#> # A tibble: 1 × 8
#>   name  index         id type  visible grid_rows grid_columns data  
#>   <chr> <int>      <int> <chr> <lgl>       <int>        <int> <list>
#> 1 delta     0 1275759356 GRID  TRUE         1000           26 <NULL>

# clean up
gs4_find("delete-sheets-from-me") %>%
  googledrive::drive_trash()
#> File trashed:
#> • delete-sheets-from-me
#>   <id: 11FeX2_g62Sh32CFPOGToyjyHdjD8Ik0cQdrdHDg6Y0U>
```
