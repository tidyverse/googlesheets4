# Flood or clear a range of cells

`range_flood()` "floods" a range of cells with the same content.
`range_clear()` is a wrapper that handles the common special case of
clearing the cell value. Both functions, by default, also clear the
format, but this can be specified via `reformat`.

## Usage

``` r
range_flood(ss, sheet = NULL, range = NULL, cell = NULL, reformat = TRUE)

range_clear(ss, sheet = NULL, range = NULL, reformat = TRUE)
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

  Sheet to write into, in the sense of "worksheet" or "tab". You can
  identify a sheet by name, with a string, or by position, with a
  number.

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

- cell:

  The value to fill the cells in the `range` with. If unspecified, the
  default of `NULL` results in clearing the existing value.

- reformat:

  Logical, indicates whether to reformat the affected cells. Currently
  googlesheets4 provides no real support for formatting, so
  `reformat = TRUE` effectively means that edited cells become
  unformatted.

## Value

The input `ss`, as an instance of
[`sheets_id`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

## See also

Makes a `RepeatCellRequest`:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#repeatcellrequest>

Other write functions:
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md),
[`gs4_formula()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_formula.md),
[`range_delete()`](https://googlesheets4.tidyverse.org/dev/reference/range_delete.md),
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

## Examples

``` r
# create a data frame to use as initial data
df <- gs4_fodder(10)

# create Sheet
ss <- gs4_create("range-flood-demo", sheets = list(df))
#> ✔ Creating new Sheet: range-flood-demo.

# default behavior (`cell = NULL`): clear value and format
range_flood(ss, range = "A1:B3")
#> ✔ Editing range-flood-demo.
#> ✔ Editing sheet Sheet1.

# clear value but preserve format
range_flood(ss, range = "C1:D3", reformat = FALSE)
#> ✔ Editing range-flood-demo.
#> ✔ Editing sheet Sheet1.

# send new value
range_flood(ss, range = "4:5", cell = ";-)")
#> ✔ Editing range-flood-demo.
#> ✔ Editing sheet Sheet1.

# send formatting
# WARNING: use these unexported, internal functions at your own risk!
# This not (yet) officially supported, but it's possible.
blue_background <- googlesheets4:::CellData(
  userEnteredFormat = googlesheets4:::new(
    "CellFormat",
    backgroundColor = googlesheets4:::new(
      "Color",
      red = 159 / 255, green = 183 / 255, blue = 196 / 255
    )
  )
)
range_flood(ss, range = "I:J", cell = blue_background)
#> ✔ Editing range-flood-demo.
#> ✔ Editing sheet Sheet1.

# range_clear() is a shortcut where `cell = NULL` always
range_clear(ss, range = "9:9")
#> ✔ Editing range-flood-demo.
#> ✔ Editing sheet Sheet1.
range_clear(ss, range = "10:10", reformat = FALSE)
#> ✔ Editing range-flood-demo.
#> ✔ Editing sheet Sheet1.

# clean up
gs4_find("range-flood-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • range-flood-demo <id: 1uZtj6WErI__8mv6eZVaOFYoDDlnanfMQNNcPP27q1WE>
```
