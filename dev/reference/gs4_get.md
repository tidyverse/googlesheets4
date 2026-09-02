# Get Sheet metadata

Retrieve spreadsheet-specific metadata, such as details on the
individual (work)sheets or named ranges.

- `gs4_get()` complements
  [`googledrive::drive_get()`](https://googledrive.tidyverse.org/reference/drive_get.html),
  which returns metadata that exists for any file on Drive.

## Usage

``` r
gs4_get(ss)
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
    `gs4_get()` returns

  Processed through
  [`as_sheets_id()`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md).

## Value

A list with S3 class `googlesheets4_spreadsheet`, for printing purposes.

## See also

Wraps the `spreadsheets.get` endpoint:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get>

## Examples

``` r
gs4_get(gs4_example("mini-gap"))
#> ✖ Request 1 failed [503: UNAVAILABLE].
#> ℹ Will retry in 1.9s.
#> ✖ Request 2 failed [503: UNAVAILABLE].
#> ℹ Will retry in 9.8s.
#> ⠙ Retry happens in  9s
#> ⠹ Retry happens in  9s
#> ⠸ Retry happens in  6s
#> ⠼ Retry happens in  3s
#> ✔ Request 3 successful!
#> ⠼ Retry happens in  3s
#> ⠼ Retry happens in  0s
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: mini-gap                                    
#>               ID: 1k94ZVVl6sdj0AXfK9MQOuQ4rOhd1PULqpAu2_kr9MAU
#>           Locale: en_US                                       
#>        Time zone: America/Los_Angeles                         
#>      # of sheets: 5                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       Africa: 6 x 6
#>     Americas: 6 x 6
#>         Asia: 6 x 6
#>       Europe: 6 x 6
#>      Oceania: 6 x 6
```
