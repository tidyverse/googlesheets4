# Read cells from a Sheet

This low-level function returns cell data in a tibble with one row per
cell. This tibble has integer variables `row` and `col` (referring to
location with the Google Sheet), an A1-style reference `loc`, and a
`cell` list-column. The flagship function
[`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md),
a.k.a.
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md),
is what most users are looking for, rather than `range_read_cells()`.
[`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
is basically `range_read_cells()` (this function), followed by
[`spread_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/spread_sheet.md),
which looks after reshaping and column typing. But if you really want
raw cell data from the API, `range_read_cells()` is for you!

## Usage

``` r
range_read_cells(
  ss,
  sheet = NULL,
  range = NULL,
  skip = 0,
  n_max = Inf,
  cell_data = c("default", "full"),
  discard_empty = TRUE
)
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

  Sheet to read, in the sense of "worksheet" or "tab". You can identify
  a sheet by name, with a string, or by position, with a number. Ignored
  if the sheet is specified via `range`. If neither argument specifies
  the sheet, defaults to the first visible sheet.

- range:

  A cell range to read from. If `NULL`, all non-empty cells are read.
  Otherwise specify `range` as described in [Sheets A1
  notation](https://developers.google.com/sheets/api/guides/concepts#a1_notation)
  or using the helpers documented in
  [cell-specification](https://googlesheets4.tidyverse.org/dev/reference/cell-specification.md).
  Sheets uses fairly standard spreadsheet range notation, although a bit
  different from Excel. Examples of valid ranges: `"Sheet1!A1:B2"`,
  `"Sheet1!A:A"`, `"Sheet1!1:2"`, `"Sheet1!A5:A"`, `"A1:B2"`,
  `"Sheet1"`. Interpreted strictly, even if the range forces the
  inclusion of leading, trailing, or embedded empty rows or columns.
  Takes precedence over `skip`, `n_max` and `sheet`. Note `range` can be
  a named range, like `"sales_data"`, without any cell reference.

- skip:

  Minimum number of rows to skip before reading anything, be it column
  names or data. Leading empty rows are automatically skipped, so this
  is a lower bound. Ignored if `range` is given.

- n_max:

  Maximum number of data rows to parse into the returned tibble.
  Trailing empty rows are automatically skipped, so this is an upper
  bound on the number of rows in the result. Ignored if `range` is
  given. `n_max` is imposed locally, after reading all non-empty cells,
  so, if speed is an issue, it is better to use `range`.

- cell_data:

  How much detail to get for each cell. `"default"` retrieves the fields
  actually used when googlesheets4 guesses or imposes cell and column
  types. `"full"` retrieves all fields in the [`CellData`
  schema](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/cells#CellData).
  The main differences relate to cell formatting.

- discard_empty:

  Whether to discard cells that have no data. Literally, we check for an
  `effectiveValue`, which is one of the fields in the [`CellData`
  schema](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/cells#CellData).

## Value

A tibble with one row per cell in the `range`.

## See also

Wraps the `spreadsheets.get` endpoint:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get>

## Examples

``` r
range_read_cells(gs4_example("deaths"), range = "arts_data")
#> ✔ Reading from deaths.
#> ✔ Range arts_data.
#> # A tibble: 66 × 4
#>      row   col loc   cell      
#>    <int> <int> <chr> <list>    
#>  1     5     1 A5    <CELL_TEX>
#>  2     5     2 B5    <CELL_TEX>
#>  3     5     3 C5    <CELL_TEX>
#>  4     5     4 D5    <CELL_TEX>
#>  5     5     5 E5    <CELL_TEX>
#>  6     5     6 F5    <CELL_TEX>
#>  7     6     1 A6    <CELL_TEX>
#>  8     6     2 B6    <CELL_TEX>
#>  9     6     3 C6    <CELL_NUM>
#> 10     6     4 D6    <CELL_LOG>
#> # ℹ 56 more rows

# if you want detailed and exhaustive cell data, do this
range_read_cells(
  gs4_example("formulas-and-formats"),
  cell_data = "full",
  discard_empty = FALSE
)
#> ✔ Reading from formulas-and-formats.
#> ✔ Range Sheet1.
#> ✖ Request 1 failed [503: UNAVAILABLE].
#> ℹ Will retry in 1s.
#> ✔ Request 2 successful!
#> # A tibble: 678 × 4
#>      row   col loc   cell      
#>    <int> <int> <chr> <list>    
#>  1     1     1 A1    <CELL_TEX>
#>  2     1     2 B1    <CELL_TEX>
#>  3     1     3 C1    <CELL_TEX>
#>  4     1     4 D1    <CELL_TEX>
#>  5     1     5 E1    <CELL_TEX>
#>  6     1     6 F1    <CELL_TEX>
#>  7     2     1 A2    <CELL_NUM>
#>  8     2     2 B2    <CELL_NUM>
#>  9     2     3 C2    <CELL_NUM>
#> 10     2     4 D2    <CELL_TEX>
#> # ℹ 668 more rows
```
