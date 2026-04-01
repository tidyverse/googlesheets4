# Read Sheet as CSV

This function uses a quick-and-dirty method to read a Sheet that
bypasses the Sheets API and, instead, parses a CSV representation of the
data. This can be much faster than
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
– noticeably so for "large" spreadsheets. There are real downsides,
though, so we recommend this approach only when the speed difference
justifies it. Here are the limitations we must accept to get faster
reading:

- Only formatted cell values are available, not underlying values or
  details on the formats.

- We can't target a named range as the `range`.

- We have no access to the data type of a cell, i.e. we don't know that
  it's logical, numeric, or datetime. That must be re-discovered based
  on the CSV data (or specified by the user).

- Auth and error handling have to be handled a bit differently
  internally, which may lead to behaviour that differs from other
  functions in googlesheets4.

Note that the Sheets API is still used to retrieve metadata on the
target Sheet, in order to support range specification.
`range_speedread()` also sends an auth token with the request, unless a
previous call to
[`gs4_deauth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_deauth.md)
has put googlesheets4 into a de-authorized state.

## Usage

``` r
range_speedread(ss, sheet = NULL, range = NULL, skip = 0, ...)
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

- ...:

  Passed along to the CSV parsing function (currently
  [`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)).

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
if (require("readr")) {
  # since cell type is not available, use readr's col type specification
  range_speedread(
    gs4_example("deaths"),
    sheet = "other",
    range = "A5:F15",
    col_types = cols(
      Age = col_integer(),
      `Date of birth` = col_date("%m/%d/%Y"),
      `Date of death` = col_date("%m/%d/%Y")
    )
  )
}
#> Loading required package: readr
#> ✔ Reading from deaths, sheet other, range A5:F15.
#> ℹ Export URL:
#>   <https://docs.google.com/spreadsheets/d/1VTJjWoP1nshbyxmL9JqXgdVsimaYty21LGxxs018H2Y/export?format=csv&range=A5%3AF15&gid=278837031>
#> # A tibble: 10 × 6
#>    Name     Profession   Age `Has kids` `Date of birth` `Date of death`
#>    <chr>    <chr>      <int> <lgl>      <date>          <date>         
#>  1 Vera Ru… scientist     88 TRUE       1928-07-23      2016-12-25     
#>  2 Mohamed… athlete       74 TRUE       1942-01-17      2016-06-03     
#>  3 Morley … journalist    84 TRUE       1931-11-08      2016-05-19     
#>  4 Fidel C… politician    90 TRUE       1926-08-13      2016-11-25     
#>  5 Antonin… lawyer        79 TRUE       1936-03-11      2016-02-13     
#>  6 Jo Cox   politician    41 TRUE       1974-06-22      2016-06-16     
#>  7 Janet R… lawyer        78 FALSE      1938-07-21      2016-11-07     
#>  8 Gwen If… journalist    61 FALSE      1955-09-29      2016-11-14     
#>  9 John Gl… astronaut     95 TRUE       1921-07-28      2016-12-08     
#> 10 Pat Sum… coach         64 TRUE       1952-06-14      2016-06-28     

# write a Sheet that, by default, is NOT world-readable
(ss <- sheet_write(chickwts))
#> ✔ Creating new Sheet: fiery-hart.
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: fiery-hart                                  
#>               ID: 16VvZRdK35I6wywu3-tjYFrnS7y9fOEK_7q2wPpRT4-4
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>     chickwts: 72 x 2

# demo that range_speedread() sends a token, which is why we can read this
range_speedread(ss)
#> ✔ Reading from fiery-hart.
#> ℹ Export URL:
#>   <https://docs.google.com/spreadsheets/d/16VvZRdK35I6wywu3-tjYFrnS7y9fOEK_7q2wPpRT4-4/export?format=csv>
#> Rows: 71 Columns: 2
#> ── Column specification ───────────────────────────────────────────────
#> Delimiter: ","
#> chr (1): feed
#> dbl (1): weight
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 71 × 2
#>    weight feed     
#>     <dbl> <chr>    
#>  1    179 horsebean
#>  2    160 horsebean
#>  3    136 horsebean
#>  4    227 horsebean
#>  5    217 horsebean
#>  6    168 horsebean
#>  7    108 horsebean
#>  8    124 horsebean
#>  9    143 horsebean
#> 10    140 horsebean
#> # ℹ 61 more rows

# clean up
googledrive::drive_trash(ss)
#> File trashed:
#> • fiery-hart <id: 16VvZRdK35I6wywu3-tjYFrnS7y9fOEK_7q2wPpRT4-4>
```
