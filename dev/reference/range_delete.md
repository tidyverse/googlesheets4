# Delete cells

Deletes a range of cells and shifts other cells into the deleted area.
There are several related tasks that are implemented by other functions:

- To clear cells of their value and/or format, use
  [`range_clear()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md).

- To delete an entire (work)sheet, use
  [`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md).

- To change the dimensions of a (work)sheet, use
  [`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md).

## Usage

``` r
range_delete(ss, sheet = NULL, range, shift = NULL)
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
  number. Ignored if the sheet is specified via `range`. If neither
  argument specifies the sheet, defaults to the first visible sheet.

- range:

  Cells to delete. There are a couple differences between `range` here
  and how it works in other functions (e.g.
  [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)):

  - `range` must be specified.

  - `range` must not be a named range.

  - `range` must not be the name of a (work) sheet. Instead, use
    [`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md)
    to delete an entire sheet. Row-only and column-only ranges are
    especially relevant, such as "2:6" or "D". Remember you can also use
    the helpers in
    [`cell-specification`](https://googlesheets4.tidyverse.org/dev/reference/cell-specification.md),
    such as `cell_cols(4:6)`, or `cell_rows(5)`.

- shift:

  Must be one of "up" or "left", if specified. Required if `range` is
  NOT a rows-only or column-only range (in which case, we can figure it
  out for you). Determines whether the deleted area is filled by
  shifting surrounding cells up or to the left.

## Value

The input `ss`, as an instance of
[`sheets_id`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

## See also

Makes a `DeleteRangeRequest`:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#DeleteRangeRequest>

Other write functions:
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md),
[`gs4_formula()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_formula.md),
[`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md),
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

## Examples

``` r
# create a data frame to use as initial data
df <- gs4_fodder(10)

# create Sheet
ss <- gs4_create("range-delete-example", sheets = list(df))
#> ✔ Creating new Sheet: range-delete-example.

# delete some rows
range_delete(ss, range = "2:4")
#> ✔ Editing range-delete-example.
#> ✔ Deleting cells in sheet Sheet1.

# delete a column
range_delete(ss, range = "C")
#> ✔ Editing range-delete-example.
#> ✔ Deleting cells in sheet Sheet1.

# delete a rectangle and specify how to shift remaining cells
range_delete(ss, range = "B3:F4", shift = "left")
#> ✔ Editing range-delete-example.
#> ✔ Deleting cells in sheet Sheet1.

# clean up
gs4_find("range-delete-example") %>%
  googledrive::drive_trash()
#> File trashed:
#> • range-delete-example
#>   <id: 1h9eC4YQhsV2QMYsCjaM83YIHCO1EiME55IeNlUpupGw>
```
