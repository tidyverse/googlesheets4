# Find Google Sheets

Finds your Google Sheets. This is a very thin wrapper around
[`googledrive::drive_find()`](https://googledrive.tidyverse.org/reference/drive_find.html),
that specifies you want to list Drive files where
`type = "spreadsheet"`. Therefore, note that this will require auth for
googledrive! See the article [Using googlesheets4 with
googledrive](https://googlesheets4.tidyverse.org/articles/articles/drive-and-sheets.html)
if you want to coordinate auth between googlesheets4 and googledrive.
This function will emit an informational message if you are currently
logged in with both googlesheets4 and googledrive, but as different
users.

## Usage

``` r
gs4_find(...)
```

## Arguments

- ...:

  Arguments (other than `type`, which is hard-wired as
  `type = "spreadsheet"`) that are passed along to
  [`googledrive::drive_find()`](https://googledrive.tidyverse.org/reference/drive_find.html).

## Value

An object of class
[`dribble`](https://googledrive.tidyverse.org/reference/dribble.html), a
tibble with one row per file.

## Examples

``` r
# see all your Sheets
gs4_find()
#> # A dribble: 9 × 3
#>   name               id       drive_resource   
#>   <chr>              <drv_id> <list>           
#> 1 geological-canary  13fmUp0… <named list [38]>
#> 2 blubbery-lobo      1foTYXQ… <named list [37]>
#> 3 bacciform-booby    15WqCxH… <named list [36]>
#> 4 childsafe-squid    1uGu_BH… <named list [37]>
#> 5 fiery-hart         18KiiL2… <named list [37]>
#> 6 chicken-sheet      1StV8oq… <named list [37]>
#> 7 releasable-rooster 1cMnXxJ… <named list [37]>
#> 8 eonian-atlasmoth   1BMEsbT… <named list [37]>
#> 9 gapminder          1ksUQqF… <named list [35]>

# see 5 Sheets, prioritized by creation time
x <- gs4_find(order_by = "createdTime desc", n_max = 5)
#> ✖ Request 1 failed [500: DATA_LOSS].
#> ℹ Will retry in 1.9s.
#> ✔ Request 2 successful!
x
#> # A dribble: 5 × 3
#>   name              id       drive_resource   
#>   <chr>             <drv_id> <list>           
#> 1 geological-canary 13fmUp0… <named list [38]>
#> 2 blubbery-lobo     1foTYXQ… <named list [37]>
#> 3 bacciform-booby   15WqCxH… <named list [36]>
#> 4 childsafe-squid   1uGu_BH… <named list [37]>
#> 5 fiery-hart        18KiiL2… <named list [37]>

# hoist the creation date, using other packages in the tidyverse
# x %>%
#   tidyr::hoist(drive_resource, created_on = "createdTime") %>%
#   dplyr::mutate(created_on = as.Date(created_on))
```
