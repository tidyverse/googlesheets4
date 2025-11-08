# Get data about (work)sheets

Reveals full metadata or just the names for the (work)sheets inside a
(spread)Sheet.

## Usage

``` r
sheet_properties(ss)

sheet_names(ss)
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

## Value

- `sheet_properties()`: A tibble with one row per (work)sheet.

- `sheet_names()`: A character vector of (work)sheet names.

## See also

Other worksheet functions:
[`sheet_add()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_add.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
[`sheet_copy()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_copy.md),
[`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md),
[`sheet_relocate()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_relocate.md),
[`sheet_rename()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_rename.md),
[`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

## Examples

``` r
ss <- gs4_example("gapminder")
sheet_properties(ss)
#> # A tibble: 5 × 8
#>   name     index         id type  visible grid_rows grid_columns data  
#>   <chr>    <int>      <int> <chr> <lgl>       <int>        <int> <list>
#> 1 Africa       0  780868077 GRID  TRUE          625            6 <NULL>
#> 2 Americas     1   45759261 GRID  TRUE          301            6 <NULL>
#> 3 Asia         2 1984823455 GRID  TRUE          397            6 <NULL>
#> 4 Europe       3 1503562052 GRID  TRUE          361            6 <NULL>
#> 5 Oceania      4 1796776040 GRID  TRUE           25            6 <NULL>
sheet_names(ss)
#> [1] "Africa"   "Americas" "Asia"     "Europe"   "Oceania" 
```
