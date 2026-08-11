# Auto-fit columns or rows to the data

Applies automatic resizing to either columns or rows of a (work)sheet.
The width or height of targeted columns or rows, respectively, is
determined from the current cell contents. This only affects the
appearance of a sheet in the browser and doesn't affect its values or
dimensions in any way.

## Usage

``` r
range_autofit(ss, sheet = NULL, range = NULL, dimension = c("columns", "rows"))
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

  Sheet to modify, in the sense of "worksheet" or "tab". You can
  identify a sheet by name, with a string, or by position, with a
  number. Ignored if the sheet is specified via `range`. If neither
  argument specifies the sheet, defaults to the first visible sheet.

- range:

  Which columns or rows to resize. Optional. If you want to resize all
  columns or all rows, use `dimension` instead. All the usual `range`
  specifications are accepted, but the targeted range must specify only
  columns (e.g. "B:F") or only rows (e.g. "2:7").

- dimension:

  Ignored if `range` is given. If consulted, `dimension` must be either
  `"columns"` (the default) or `"rows"`. This is the simplest way to
  request auto-resize for all columns or all rows.

## Value

The input `ss`, as an instance of
[`sheets_id`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

## See also

Makes an `AutoResizeDimensionsRequest`:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#autoresizedimensionsrequest>

## Examples

``` r
dat <- tibble::tibble(
  fruit = c("date", "lime", "pear", "plum")
)

ss <- gs4_create("range-autofit-demo", sheets = dat)
#> ✔ Creating new Sheet: range-autofit-demo.
ss
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: range-autofit-demo                          
#>               ID: 1w1zIs46lz0C8s-0K8lx5b3YMcQpe8DxGpXxaD9Xw7kM
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>          dat: 5 x 1

# open in the browser
gs4_browse(ss)

# shrink column A to fit the short fruit names
range_autofit(ss)
#> ✔ Editing range-autofit-demo.
#> ✔ Resizing one or more columns in dat.
# in the browser, notice how the column width shrank

# send some longer fruit names
dat2 <- tibble::tibble(
  fruit = c("cucumber", "honeydew")
)
ss %>% sheet_append(dat2)
#> ✔ Writing to range-autofit-demo.
#> ✔ Appending 2 rows to dat.
# in the browser, see that column A is now too narrow to show the data

range_autofit(ss)
#> ✔ Editing range-autofit-demo.
#> ✔ Resizing one or more columns in dat.
# in the browser, see the column A reveals all the data now

# clean up
gs4_find("range-autofit-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • range-autofit-demo
#>   <id: 1w1zIs46lz0C8s-0K8lx5b3YMcQpe8DxGpXxaD9Xw7kM>
```
