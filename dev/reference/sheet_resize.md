# Change the size of a (work)sheet

Changes the number of rows and/or columns in a (work)sheet.

## Usage

``` r
sheet_resize(ss, sheet = NULL, nrow = NULL, ncol = NULL, exact = FALSE)
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

  Sheet to resize, in the sense of "worksheet" or "tab". You can
  identify a sheet by name, with a string, or by position, with a
  number.

- nrow, ncol:

  Desired number of rows or columns, respectively. The default of `NULL`
  means to leave unchanged.

- exact:

  Logical, indicating whether to impose `nrow` and `ncol` exactly or to
  treat them as lower bounds. If `exact = FALSE`, `sheet_resize()` can
  only add cells. If `exact = TRUE`, cells can be deleted and their
  contents are lost.

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
[`sheet_rename()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_rename.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

## Examples

``` r
# create a Sheet with the default initial worksheet
(ss <- gs4_create("sheet-resize-demo"))
#> ✔ Creating new Sheet: sheet-resize-demo.
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheet-resize-demo                           
#>               ID: 1dreT6zi1Q7_6cYd7goJRGXtz1viCXREaMongZAwrhVI
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       Sheet1: 1000 x 26

# see (work)sheet dims
sheet_properties(ss)
#> # A tibble: 1 × 8
#>   name   index    id type  visible grid_rows grid_columns data  
#>   <chr>  <int> <int> <chr> <lgl>       <int>        <int> <list>
#> 1 Sheet1     0     0 GRID  TRUE         1000           26 <NULL>

# no resize occurs
sheet_resize(ss, nrow = 2, ncol = 6)
#> ✔ Resizing sheet Sheet1 in sheet-resize-demo.
#> ℹ No need to change existing dims (1000 x 26).

# reduce sheet size
sheet_resize(ss, nrow = 5, ncol = 7, exact = TRUE)
#> ✔ Resizing sheet Sheet1 in sheet-resize-demo.
#> ✔ Changing dims: (1000 x 26) --> (5 x 7).

# add rows
sheet_resize(ss, nrow = 7)
#> ✔ Resizing sheet Sheet1 in sheet-resize-demo.
#> ✔ Changing dims: (5 x 7) --> (7 x 7).

# add columns
sheet_resize(ss, ncol = 10)
#> ✔ Resizing sheet Sheet1 in sheet-resize-demo.
#> ✔ Changing dims: (7 x 7) --> (7 x 10).

# add rows and columns
sheet_resize(ss, nrow = 9, ncol = 12)
#> ✔ Resizing sheet Sheet1 in sheet-resize-demo.
#> ✔ Changing dims: (7 x 10) --> (9 x 12).

# re-inspect (work)sheet dims
sheet_properties(ss)
#> # A tibble: 1 × 8
#>   name   index    id type  visible grid_rows grid_columns data  
#>   <chr>  <int> <int> <chr> <lgl>       <int>        <int> <list>
#> 1 Sheet1     0     0 GRID  TRUE            9           12 <NULL>

# clean up
gs4_find("sheet-resize-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • sheet-resize-demo <id: 1dreT6zi1Q7_6cYd7goJRGXtz1viCXREaMongZAwrhVI>
```
