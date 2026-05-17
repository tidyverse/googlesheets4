# googlesheets4 configuration

Some aspects of googlesheets4 behaviour can be controlled via an option.

## Usage

``` r
local_gs4_quiet(env = parent.frame())

with_gs4_quiet(code)
```

## Arguments

- env:

  The environment to use for scoping

- code:

  Code to execute quietly

## Messages

The `googlesheets4_quiet` option can be used to suppress messages from
googlesheets4. By default, googlesheets4 always messages, i.e. it is
*not* quiet.

Set `googlesheets4_quiet` to `TRUE` to suppress messages, by one of
these means, in order of decreasing scope:

- Put `options(googlesheets4_quiet = TRUE)` in a start-up file, such as
  `.Rprofile`, or in your R script

- Use `local_gs4_quiet()` to silence googlesheets4 in a specific scope

- Use `with_gs4_quiet()` to run a small bit of code silently

`local_gs4_quiet()` and `with_gs4_quiet()` follow the conventions of the
the withr package (<https://withr.r-lib.org>).

## Auth

Read about googlesheets4's main auth function,
[`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md).
It is powered by the gargle package, which consults several options:

- Default Google user or, more precisely, `email`: see
  [`gargle::gargle_oauth_email()`](https://gargle.r-lib.org/reference/gargle_options.html)

- Whether or where to cache OAuth tokens: see
  [`gargle::gargle_oauth_cache()`](https://gargle.r-lib.org/reference/gargle_options.html)

- Whether to prefer "out-of-band" auth: see
  [`gargle::gargle_oob_default()`](https://gargle.r-lib.org/reference/gargle_options.html)

- Application Default Credentials: see
  [`gargle::credentials_app_default()`](https://gargle.r-lib.org/reference/credentials_app_default.html)

## Examples

``` r
# message: "Creating new Sheet ..."
(ss <- gs4_create("gs4-quiet-demo", sheets = "alpha"))
#> ✔ Creating new Sheet: gs4-quiet-demo.
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: gs4-quiet-demo                              
#>               ID: 1lMXwl0bz9fa7zUXT_q9amrmoM08nowdKgh5z4TvYREw
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>        alpha: 1000 x 26

# message: "Editing ..., Writing ..."
range_write(ss, data = data.frame(x = 1, y = "a"))
#> ✔ Editing gs4-quiet-demo.
#> ✔ Writing to sheet alpha.

# suppress messages for a small amount of code
with_gs4_quiet(
  ss %>% sheet_append(data.frame(x = 2, y = "b"))
)

# message: "Writing ..., Appending ..."
ss %>% sheet_append(data.frame(x = 3, y = "c"))
#> ✔ Writing to gs4-quiet-demo.
#> ✔ Appending 1 row to alpha.

# suppress messages until end of current scope
local_gs4_quiet()
ss %>% sheet_append(data.frame(x = 4, y = "d"))
#> ✔ Writing to gs4-quiet-demo.
#> ✔ Appending 1 row to alpha.

# see that all the data was, in fact, written
read_sheet(ss)
#> ✔ Reading from gs4-quiet-demo.
#> ✔ Range alpha.
#> # A tibble: 4 × 2
#>       x y    
#>   <dbl> <chr>
#> 1     1 a    
#> 2     2 b    
#> 3     3 c    
#> 4     4 d    

# clean up
gs4_find("gs4-quiet-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • gs4-quiet-demo <id: 1lMXwl0bz9fa7zUXT_q9amrmoM08nowdKgh5z4TvYREw>
```
