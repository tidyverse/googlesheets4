# (Over)write new data into a range

Writes a data frame into a range of cells. Main differences from
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
(a.k.a.
[`write_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)):

- Narrower scope. `range_write()` literally targets some cells, not a
  whole (work)sheet.

- The edited rectangle is not explicitly styled as a table. Nothing
  special is done re: formatting a header row or freezing rows.

- Column names can be suppressed. This means that, although `data` must
  be a data frame (at least for now), `range_write()` can actually be
  used to write arbitrary data.

- The target (spread)Sheet and (work)sheet must already exist. There is
  no ability to create a Sheet or add a worksheet.

- The target sheet dimensions are not "trimmed" to shrink-wrap the
  `data`. However, the sheet might gain rows and/or columns, in order to
  write `data` to the user-specified `range`.

If you just want to add rows to an existing table, the function you
probably want is
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md).

## Usage

``` r
range_write(
  ss,
  data,
  sheet = NULL,
  range = NULL,
  col_names = TRUE,
  reformat = TRUE
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

- data:

  A data frame.

- sheet:

  Sheet to write into, in the sense of "worksheet" or "tab". You can
  identify a sheet by name, with a string, or by position, with a
  number. Ignored if the sheet is specified via `range`. If neither
  argument specifies the sheet, defaults to the first visible sheet.

- range:

  Where to write. This `range` argument has important similarities and
  differences to `range` elsewhere (e.g.
  [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)):

  - Similarities: Can be a cell range, using A1 notation ("A1:D3") or
    using the helpers in
    [`cell-specification`](https://googlesheets4.tidyverse.org/dev/reference/cell-specification.md).
    Can combine sheet name and cell range ("Sheet1!A5:A") or refer to a
    sheet by name (`range = "Sheet1"`, although `sheet = "Sheet1"` is
    preferred for clarity).

  - Difference: Can NOT be a named range.

  - Difference: `range` can be interpreted as the *start* of the target
    rectangle (the upper left corner) or, more literally, as the actual
    target rectangle. See the "Range specification" section for details.

- col_names:

  Logical, indicates whether to send the column names of `data`.

- reformat:

  Logical, indicates whether to reformat the affected cells. Currently
  googlesheets4 provides no real support for formatting, so
  `reformat = TRUE` effectively means that edited cells become
  unformatted.

## Value

The input `ss`, as an instance of
[`sheets_id`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

## Range specification

The `range` argument of `range_write()` is special, because the Sheets
API can implement it in 2 different ways:

- If `range` represents exactly 1 cell, like "B3", it is taken as the
  *start* (or upper left corner) of the targeted cell rectangle. The
  edited cells are determined implicitly by the extent of the `data` we
  are writing. This frees you from doing fiddly range computations based
  on the dimensions of the `data`.

- If `range` describes a rectangle with multiple cells, it is
  interpreted as the *actual* rectangle to edit. It is possible to
  describe a rectangle that is unbounded on the right (e.g. "B2:4"), on
  the bottom (e.g. "A4:C"), or on both the right and the bottom (e.g.
  `cell_limits(c(2, 3), c(NA, NA))`. Note that **all cells** inside the
  rectangle receive updated data and format. Important implication: if
  the `data` object isn't big enough to fill the target rectangle, the
  cells that don't receive new data are effectively cleared, i.e. the
  existing value and format are deleted.

## See also

If sheet size needs to change, makes an `UpdateSheetPropertiesRequest`:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest>

The main data write is done via an `UpdateCellsRequest`:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#updatecellsrequest>

Other write functions:
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md),
[`gs4_formula()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_formula.md),
[`range_delete()`](https://googlesheets4.tidyverse.org/dev/reference/range_delete.md),
[`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

## Examples

``` r
# create a Sheet with some initial, empty (work)sheets
(ss <- gs4_create("range-write-demo", sheets = c("alpha", "beta")))
#> ✔ Creating new Sheet: range-write-demo.
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: range-write-demo                            
#>               ID: 1UsLI2eNWv9J3CoeNc-Y72wU3zywMaCKFxxC9vm0CTOw
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 2                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>        alpha: 1000 x 26
#>         beta: 1000 x 26

df <- data.frame(
  x = 1:3,
  y = letters[1:3]
)

#  write df somewhere other than the "upper left corner"
range_write(ss, data = df, range = "D6")
#> ✔ Editing range-write-demo.
#> ✔ Writing to sheet alpha.

# view your magnificent creation in the browser
gs4_browse(ss)

# send data of disparate types to a 1-row rectangle
dat <- tibble::tibble(
  string = "string",
  logical = TRUE,
  datetime = Sys.time()
)
range_write(ss, data = dat, sheet = "beta", col_names = FALSE)
#> ✔ Editing range-write-demo.
#> ✔ Writing to sheet beta.

# send data of disparate types to a 1-column rectangle
dat <- tibble::tibble(
  x = list(Sys.time(), FALSE, "string")
)
range_write(ss, data = dat, range = "beta!C5", col_names = FALSE)
#> ✔ Editing range-write-demo.
#> ✔ Writing to sheet beta.

# clean up
gs4_find("range-write-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • range-write-demo <id: 1UsLI2eNWv9J3CoeNc-Y72wU3zywMaCKFxxC9vm0CTOw>
```
