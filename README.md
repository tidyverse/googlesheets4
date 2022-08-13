
<!-- README.md is generated from README.Rmd. Please edit that file -->

# googlesheets4 <a href='https:/googlesheets4.tidyverse.org'><img src='man/figures/logo.png' align="right" height="138.5" /></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/googlesheets4)](https://CRAN.R-project.org/package=googlesheets4)
[![R-CMD-check](https://github.com/tidyverse/googlesheets4/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/tidyverse/googlesheets4/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/tidyverse/googlesheets4/branch/main/graph/badge.svg)](https://app.codecov.io/gh/tidyverse/googlesheets4?branch=main)
<!-- badges: end -->

## Overview

googlesheets4 provides an R interface to [Google
Sheets](https://docs.google.com/spreadsheets/) via the [Sheets API
v4](https://developers.google.com/sheets/api/). It is a reboot of an
earlier package called
[googlesheets](https://github.com/jennybc/googlesheets#readme).

*Why **4**? Why googlesheets**4**? Did I miss googlesheets1 through 3?
No. The idea is to name the package after the corresponding version of
the Sheets API. In hindsight, the original googlesheets should have been
googlesheets**3**.*

## Installation

You can install the released version of googlesheets4 from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("googlesheets4")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("tidyverse/googlesheets4")
```

## Cheatsheet

You can see how to read data with googlesheets4 in the **data import
cheatsheet**, which also covers similar functionality in the related
packages readr and readxl.

<a href="https://github.com/rstudio/cheatsheets/blob/master/data-import.pdf"><img src="https://raw.githubusercontent.com/rstudio/cheatsheets/master/pngs/thumbnails/data-import-cheatsheet-thumbs.png" width="630" height="252"/></a>

## Auth

googlesheets4 will, by default, help you interact with Sheets as an
authenticated Google user. If you don’t plan to write Sheets or to read
private Sheets, use `gs4_deauth()` to indicate there is no need for a
token. See the article [googlesheets4
auth](https://googlesheets4.tidyverse.org/articles/articles/auth.html)
for more.

For this overview, we’ve logged into Google as a specific user in a
hidden chunk.

## Attach googlesheets4

``` r
library(googlesheets4)
```

## Read

The main “read” function of the googlesheets4 package goes by two names,
because we want it to make sense in two contexts:

-   `read_sheet()` evokes other table-reading functions, like
    `readr::read_csv()` and `readxl::read_excel()`. The `sheet` in this
    case refers to a Google (spread)Sheet.
-   `range_read()` is the right name according to the [naming
    convention](https://googlesheets4.tidyverse.org/articles/articles/function-class-names.html)
    used throughout the googlesheets4 package.

`read_sheet()` and `range_read()` are synonyms and you can use either
one. Here we’ll use `read_sheet()`.

googlesheets4 is [pipe-friendly](https://r4ds.had.co.nz/pipes.html) (and
reexports `%>%`), but works just fine without the pipe.

Read from

-   a URL
-   a Sheet ID
-   a
    [`dribble`](https://googledrive.tidyverse.org/reference/dribble.html)
    produced by the googledrive package, which can lookup by file name

These all achieve the same thing:

``` r
# URL
read_sheet("https://docs.google.com/spreadsheets/d/1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY/edit#gid=780868077")
#> ✔ Reading from "gapminder".
#> ✔ Range 'Africa'.
#> # A tibble: 624 × 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> 5 Algeria Africa     1972    54.5 14760787     4183.
#> # … with 619 more rows
#> # ℹ Use `print(n = ...)` to see more rows

# Sheet ID
read_sheet("1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY")
#> ✔ Reading from "gapminder".
#> ✔ Range 'Africa'.
#> # A tibble: 624 × 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> 5 Algeria Africa     1972    54.5 14760787     4183.
#> # … with 619 more rows
#> # ℹ Use `print(n = ...)` to see more rows

# a googledrive "dribble"
googledrive::drive_get("gapminder") %>% 
  read_sheet()
#> ✔ The input `path` resolved to exactly 1 file.
#> ✔ Reading from "gapminder".
#> ✔ Range 'Africa'.
#> # A tibble: 624 × 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> 5 Algeria Africa     1972    54.5 14760787     4183.
#> # … with 619 more rows
#> # ℹ Use `print(n = ...)` to see more rows
```

*Note: the only reason we can read a sheet named “gapminder” (the last
example) is because the account we’re logged in as has a Sheet named
“gapminder”.*

See the article [Find and Identify
Sheets](https://googlesheets4.tidyverse.org/articles/articles/find-identify-sheets.html)
for more about specifying the Sheet you want to address. See the article
[Read
Sheets](https://googlesheets4.tidyverse.org/articles/articles/find-identify-sheets.html)
for more about reading from specific sheets or ranges, setting column
type, and getting low-level cell data.

## Write

`gs4_create()` creates a brand new Google Sheet and can optionally send
some initial data.

``` r
(ss <- gs4_create("fluffy-bunny", sheets = list(flowers = head(iris))))
#> ✔ Creating new Sheet: "fluffy-bunny".
#> Spreadsheet name: fluffy-bunny
#>               ID: 1YVHPcvzoM0SW4MKgQFoH8TQDtEnxnhHewOzWEj6Yz9k
#>           Locale: en_US
#>        Time zone: Etc/GMT
#>      # of sheets: 1
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>      flowers: 7 x 5
```

`sheet_write()` (over)writes a whole data frame into a (work)sheet
within a (spread)Sheet.

``` r
head(mtcars) %>% 
  sheet_write(ss, sheet = "autos")
#> ✔ Writing to "fluffy-bunny".
#> ✔ Writing to sheet 'autos'.
ss
#> Spreadsheet name: fluffy-bunny
#>               ID: 1YVHPcvzoM0SW4MKgQFoH8TQDtEnxnhHewOzWEj6Yz9k
#>           Locale: en_US
#>        Time zone: Etc/GMT
#>      # of sheets: 2
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>      flowers: 7 x 5
#>        autos: 7 x 11
```

`sheet_append()`, `range_write()`, `range_flood()`, and `range_clear()`
are more specialized writing functions. See the article [Write
Sheets](https://googlesheets4.tidyverse.org/articles/articles/write-sheets.html)
for more about writing to Sheets.

## Where to learn more

[Get
started](https://googlesheets4.tidyverse.org/articles/googlesheets4.html)
is a more extensive general introduction to googlesheets4.

Browse the [articles
index](https://googlesheets4.tidyverse.org/articles/index.html) to find
articles that cover various topics in more depth.

See the [function
index](https://googlesheets4.tidyverse.org/reference/index.html) for an
organized, exhaustive listing.

## Contributing

If you’d like to contribute to the development of googlesheets4, please
read [these
guidelines](https://googlesheets4.tidyverse.org/CONTRIBUTING.html).

Please note that the googlesheets4 project is released with a
[Contributor Code of
Conduct](https://googlesheets4.tidyverse.org/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

## Privacy

[Privacy policy](https://www.tidyverse.org/google_privacy_policy)

## Context

googlesheets4 draws on and complements / emulates other packages in the
tidyverse:

-   [googlesheets](https://cran.r-project.org/package=googlesheets) is
    the package that googlesheets4 replaces. Main improvements in
    googlesheets4: (1) wraps the current, most modern Sheets API; (2)
    leaves all “whole file” operations to googledrive; and (3) uses
    shared infrastructure for auth and more, from the gargle package.
    The v3 API wrapped by googlesheets is deprecated. [Starting in
    April/May
    2020](https://cloud.google.com/blog/products/g-suite/migrate-your-apps-use-latest-sheets-api),
    features will gradually be disabled and it’s anticipated the API
    will fully shutdown in September 2020. At that point, the original
    googlesheets package must be retired.
-   [googledrive](https://googledrive.tidyverse.org) provides a
    fully-featured interface to the Google Drive API. Any “whole file”
    operations can be accomplished with googledrive: upload or download
    or update a spreadsheet, copy, rename, move, change permission,
    delete, etc. googledrive supports Team Drives.
-   [readxl](https://readxl.tidyverse.org) is the tidyverse package for
    reading Excel files (xls or xlsx) into an R data frame.
    googlesheets4 takes cues from parts of the readxl interface,
    especially around specifying which cells to read.
-   [readr](https://readr.tidyverse.org) is the tidyverse package for
    reading delimited files (e.g., csv or tsv) into an R data frame.
    googlesheets4 takes cues from readr with respect to column type
    specification.
