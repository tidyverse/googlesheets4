# Example Sheets

An index of the official example and test Sheets. They are
world-readable, so we do
[`gs4_deauth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_deauth.md).

``` r

library(googlesheets4)

gs4_deauth()
```

## Example Sheets

| name (these are links) | id |
|:---|:---|
| [cell-contents-and-formats](https://docs.google.com/spreadsheets/d/1peJXEeAp5Qt3ENoTvkhvenQ36N3kLyq6sq9Dh2ufQ6E) | 1peJXEeAp5Qt3ENoTvkhvenQ36N3kLyq6sq9Dh2ufQ6E |
| [chicken-sheet](https://docs.google.com/spreadsheets/d/1ct9t1Efv8pAGN9YO5gC2QfRq2wT4XjNoTMXpVeUghJU) | 1ct9t1Efv8pAGN9YO5gC2QfRq2wT4XjNoTMXpVeUghJU |
| [deaths](https://docs.google.com/spreadsheets/d/1VTJjWoP1nshbyxmL9JqXgdVsimaYty21LGxxs018H2Y) | 1VTJjWoP1nshbyxmL9JqXgdVsimaYty21LGxxs018H2Y |
| [formulas-and-formats](https://docs.google.com/spreadsheets/d/1wPLrWOxxEjp3T1nv2YBxn63FX70Mz5W5Tm4tGc-lRms) | 1wPLrWOxxEjp3T1nv2YBxn63FX70Mz5W5Tm4tGc-lRms |
| [gapminder](https://docs.google.com/spreadsheets/d/1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY) | 1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY |
| [mini-gap](https://docs.google.com/spreadsheets/d/1k94ZVVl6sdj0AXfK9MQOuQ4rOhd1PULqpAu2_kr9MAU) | 1k94ZVVl6sdj0AXfK9MQOuQ4rOhd1PULqpAu2_kr9MAU |

### How to get hold of the example Sheets yourself

[`gs4_examples()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md)
returns a named vector of Sheet IDs. It is also an instance of
`drive_id`, to make good things happen with googledrive.

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

gs4_examples("and")
#> <drive_id[2]>
#>                    cell-contents-and-formats 
#> 1peJXEeAp5Qt3ENoTvkhvenQ36N3kLyq6sq9Dh2ufQ6E 
#>                         formulas-and-formats 
#> 1wPLrWOxxEjp3T1nv2YBxn63FX70Mz5W5Tm4tGc-lRms
```

[`gs4_example()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md)
returns exactly one Sheet ID (or errors). It is an instance of
`drive_id`. It is also an instance of `sheets_id`, which means printing
will (try to) reveal current metadata about the Sheet.

``` r

gs4_example("chicken")
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: chicken-sheet                               
#>               ID: 1ct9t1Efv8pAGN9YO5gC2QfRq2wT4XjNoTMXpVeUghJU
#>           Locale: en_US                                       
#>        Time zone: America/Los_Angeles                         
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>  chicken.csv: 1000 x 26

gs4_example("gap")
#> Error in `gs4_example()`:
#> ! Found multiple matching example Sheets:
#> • gapminder
#> • mini-gap
#> ℹ Make the `matches` regular expression more specific.
```

Here’s a handy snippet to open all the example Sheets in browser tabs.

``` r

lapply(gs4_examples(), gs4_browse)

# for tidyversers
gs4_examples() %>% 
  purrr::walk(gs4_browse)
```

## Test Sheets

These are more developer-facing, but it’s convenient to do them here
too.

| name (these are links) | id |
|:---|:---|
| [googlesheets4-cell-tests](https://docs.google.com/spreadsheets/d/1WRFIb11PJsNwx2tYBRn3uq8uHwWSI5ziSgbGjkOukmE) | 1WRFIb11PJsNwx2tYBRn3uq8uHwWSI5ziSgbGjkOukmE |
| [googlesheets4-col-types](https://docs.google.com/spreadsheets/d/1q-iRi1L3JugqHTtcjQ3DQOmOTuDnUsWi2AiG2eNyQkU) | 1q-iRi1L3JugqHTtcjQ3DQOmOTuDnUsWi2AiG2eNyQkU |
