# `sheets_id` class

`sheets_id` is an S3 class that marks a string as a Google Sheet's id,
which the Sheets API docs refer to as `spreadsheetId`.

Any object of class `sheets_id` also has the
[`drive_id`](https://googledrive.tidyverse.org/reference/drive_id.html)
class, which is used by
[googledrive::googledrive](https://googledrive.tidyverse.org/reference/googledrive-package.html)
for the same purpose. This means you can provide a `sheets_id` to
[googledrive::googledrive](https://googledrive.tidyverse.org/reference/googledrive-package.html)
functions, in order to do anything with your Sheet that has nothing to
do with it being a spreadsheet. Examples: change the Sheet's name,
parent folder, or permissions. Read more about using
[googlesheets4](https://googlesheets4.tidyverse.org/dev/reference/googlesheets4-package.md)
and
[googledrive::googledrive](https://googledrive.tidyverse.org/reference/googledrive-package.html)
together in `vignette("drive-and-sheets")`. Note that a `sheets_id`
object is intended to hold **just one** id, while the parent class
`drive_id` can be used for multiple ids.

`as_sheets_id()` is a generic function that converts various inputs into
an instance of `sheets_id`. See more below.

When you print a `sheets_id`, we attempt to reveal the Sheet's current
metadata, via
[`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md).
This can fail for a variety of reasons (e.g. if you're offline), but the
input `sheets_id` is always revealed and returned, invisibly.

## Usage

``` r
as_sheets_id(x, ...)
```

## Arguments

- x:

  Something that contains a Google Sheet id: an id string, a
  [`drive_id`](https://googledrive.tidyverse.org/reference/drive_id.html),
  a URL, a one-row
  [`dribble`](https://googledrive.tidyverse.org/reference/dribble.html),
  or a `googlesheets4_spreadsheet`.

- ...:

  Other arguments passed down to methods. (Not used.)

## `as_sheets_id()`

These inputs can be converted to a `sheets_id`:

- Spreadsheet id, "a string containing letters, numbers, and some
  special characters", typically 44 characters long, in our experience.
  Example: `1qpyC0XzvTcKT6EISywvqESX3A0MwQoFDE8p-Bll4hps`.

- A URL, from which we can excavate a spreadsheet or file id. Example:
  `"https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/edit#gid=1150108545"`.

- A one-row
  [`dribble`](https://googledrive.tidyverse.org/reference/dribble.html),
  a "Drive tibble" used by the
  [googledrive::googledrive](https://googledrive.tidyverse.org/reference/googledrive-package.html)
  package. In general, a `dribble` can represent several files, one row
  per file. Since googlesheets4 is not vectorized over spreadsheets, we
  are only prepared to accept a one-row `dribble`.

  - [`googledrive::drive_get("YOUR_SHEET_NAME")`](https://googledrive.tidyverse.org/reference/drive_get.html)
    is a great way to look up a Sheet via its name.

  - [`gs4_find("YOUR_SHEET_NAME")`](https://googlesheets4.tidyverse.org/dev/reference/gs4_find.md)
    is another good way to get your hands on a Sheet.

- Spreadsheet meta data, as returned by, e.g.,
  [`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md).
  Literally, this is an object of class `googlesheets4_spreadsheet`.

## See also

[googledrive::as_id](https://googledrive.tidyverse.org/reference/drive_id.html)

## Examples

``` r
mini_gap_id <- gs4_example("mini-gap")
class(mini_gap_id)
#> [1] "sheets_id"  "drive_id"   "vctrs_vctr" "character" 
mini_gap_id
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

as_sheets_id("abc")
#> ✖ Request 1 failed [503: UNAVAILABLE].
#> ℹ Will retry in 2.6s.
#> ⠙ Retry happens in  2s
#> ✔ Request 2 failed :(
#> ⠙ Retry happens in  2s
#> ⠙ Retry happens in  0s
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: "<unknown>"
#>               ID: abc        
#>           Locale: <unknown>  
#>        Time zone: <unknown>  
#>      # of sheets: <unknown>  
#> 
#> Unable to get metadata for this Sheet. Error details:
#> Client error: (404) NOT_FOUND
#> • A specified resource is not found, or the request is rejected by
#>   undisclosed reasons, such as whitelisting.
#> • Requested entity was not found.
```
