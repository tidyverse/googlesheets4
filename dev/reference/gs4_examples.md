# Example Sheets

googlesheets4 makes a variety of world-readable example Sheets available
for use in documentation and reprexes. These functions help you access
the example Sheets. See
`vignette("example-sheets", package = "googlesheets4")` for more.

## Usage

``` r
gs4_examples(matches)

gs4_example(matches)
```

## Arguments

- matches:

  A regular expression that matches the name of the desired example
  Sheet(s). `matches` is optional for the plural `gs4_examples()` and,
  if provided, it can match multiple Sheets. The singular
  `gs4_example()` requires `matches` and it must match exactly one
  Sheet.

## Value

- `gs4_example()`: a
  [sheets_id](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

- `gs4_examples()`: a named vector of all built-in examples, with class
  [`drive_id`](https://googledrive.tidyverse.org/reference/drive_id.html)

## Examples

``` r
gs4_examples()
#> <drive_id[6]>
#>                    cell-contents-and-formats 
#> 1peJXEeAp5Qt3ENoTvkhvenQ36N3kLyq6sq9Dh2ufQ6E 
#>                                chicken-sheet 
#> 1ct9t1Efv8pAGN9YO5gC2QfRq2wT4XjNoTMXpVeUghJU 
#>                                       deaths 
#> 1VTJjWoP1nshbyxmL9JqXgdVsimaYty21LGxxs018H2Y 
#>                         formulas-and-formats 
#> 1wPLrWOxxEjp3T1nv2YBxn63FX70Mz5W5Tm4tGc-lRms 
#>                                    gapminder 
#> 1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY 
#>                                     mini-gap 
#> 1k94ZVVl6sdj0AXfK9MQOuQ4rOhd1PULqpAu2_kr9MAU 
gs4_examples("gap")
#> <drive_id[2]>
#>                                    gapminder 
#> 1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY 
#>                                     mini-gap 
#> 1k94ZVVl6sdj0AXfK9MQOuQ4rOhd1PULqpAu2_kr9MAU 

gs4_example("gapminder")
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#>  Spreadsheet name: gapminder                                   
#>                ID: 1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY
#>            Locale: en_US                                       
#>         Time zone: America/Los_Angeles                         
#>       # of sheets: 5                                           
#> # of named ranges: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       Africa: 625 x 6
#>     Americas: 301 x 6
#>         Asia: 397 x 6
#>       Europe: 361 x 6
#>      Oceania: 25 x 6
#> 
#> ── <named ranges> ─────────────────────────────────────────────────────
#> (Named range): (A1 range)        
#>        canada: 'Americas'!A38:F49
gs4_example("deaths")
#> ✖ Request 1 failed [503: UNAVAILABLE].
#> ℹ Will retry in 2.6s.
#> ⠙ Retry happens in  2s
#> ✖ Request 2 failed [503: UNAVAILABLE].
#> ⠙ Retry happens in  2s
#> ℹ Will retry in 13s.
#> ⠙ Retry happens in  2s
#> ⠙ Retry happens in  3s
#> ⠙ Retry happens in 12s
#> ⠹ Retry happens in  9s
#> ⠸ Retry happens in  6s
#> ⠼ Retry happens in  3s
#> ⠴ Retry happens in  0s
#> ✔ Request 3 successful!
#> ⠴ Retry happens in  0s
#> ⠴ Retry happens in  0s
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#>  Spreadsheet name: deaths                                      
#>                ID: 1VTJjWoP1nshbyxmL9JqXgdVsimaYty21LGxxs018H2Y
#>            Locale: en_US                                       
#>         Time zone: America/Los_Angeles                         
#>       # of sheets: 2                                           
#> # of named ranges: 2                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>         arts: 1000 x 26
#>        other: 1000 x 26
#> 
#> ── <named ranges> ─────────────────────────────────────────────────────
#> (Named range): (A1 range)    
#>     arts_data: 'arts'!A5:F15 
#>    other_data: 'other'!A5:F15
```
