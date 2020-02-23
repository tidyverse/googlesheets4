
<!-- README.md is generated from README.Rmd. Please edit that file -->

# googlesheets4 <a href='https:/googlesheets4.tidyverse.org'><img src='man/figures/logo.png' align="right" height="138.5" /></a>

<!-- badges: start -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/googlesheets4)](https://CRAN.R-project.org/package=googlesheets4)
[![R build
status](https://github.com/tidyverse/googlesheets4/workflows/R-CMD-check/badge.svg)](https://github.com/tidyverse/googlesheets4/actions)
[![Coverage
status](https://codecov.io/gh/tidyverse/googlesheets4/branch/master/graph/badge.svg)](https://codecov.io/github/tidyverse/googlesheets4?branch=master)
<!-- badges: end -->

## Overview

googlesheets4 provides an R interface to [Google
Sheets](https://spreadsheets.google.com/) via the [Sheets API
v4](https://developers.google.com/sheets/api/). It is a reboot of an
earlier package called
[googlesheets](https://cran.r-project.org/package=googlesheets).

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

## Auth

googlesheets4 will, by default, help you interact with Sheets as an
authenticated Google user. The package facilitates this process upon
first need. If you don’t need to access private Sheets, use
`sheets_deauth()` to indicate there is no need for a token. See the
article [googlesheets4
auth](https://googlesheets4.tidyverse.org/articles/articles/auth.html)
for more.

For this overview, we’ve logged into Google as a specific user in a
hidden chunk.

## Attach googlesheets4

``` r
library(googlesheets4)
```

## Read

`read_sheet()` is the main “read” function and should evoke
`readr::read_csv()` and `readxl::read_excel()`. It’s an alias for
`sheets_read()`, because most functions in googlesheets4 actually start
with `sheets_`. googlesheets4 is pipe-friendly (and reexports `%>%`),
but works just fine without the pipe.

Read from a URL, a Sheet ID, or a googledrive-produced `dribble`. These
all achieve the same thing:

``` r
read_sheet("https://docs.google.com/spreadsheets/d/1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY/edit#gid=780868077")
#> Reading from "gapminder"
#> Range "Africa"
#> # A tibble: 624 x 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> 5 Algeria Africa     1972    54.5 14760787     4183.
#> # … with 619 more rows

read_sheet("1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY")
#> Reading from "gapminder"
#> Range "Africa"
#> # A tibble: 624 x 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> 5 Algeria Africa     1972    54.5 14760787     4183.
#> # … with 619 more rows

googledrive::drive_get("gapminder") %>% 
  sheets_read()
#> Reading from "gapminder"
#> Range "Africa"
#> # A tibble: 624 x 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> 5 Algeria Africa     1972    54.5 14760787     4183.
#> # … with 619 more rows
```

## Write

`sheets_create()` creates a brand new (spread)Sheet and can optionally
send some initial data.

``` r
(ss <- sheets_create("fluffy-bunny", sheets = list(flowers = head(iris))))
#>   Spreadsheet name: fluffy-bunny
#>                 ID: 18rx-V15FzVM6BZtuV0HLmE7eBS7JbiDrR1BswMFcplE
#>             Locale: en_US
#>          Time zone: Etc/GMT
#>        # of sheets: 1
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>      flowers: 7 x 5
```

`sheets_write()` (over)writes a whole data frame into a (work)sheet
within a (spread)Sheet.

``` r
head(mtcars) %>% 
  sheets_write(ss, sheet = "autos")
#> Writing to "fluffy-bunny"
#> Writing to sheet "autos"
ss
#>   Spreadsheet name: fluffy-bunny
#>                 ID: 18rx-V15FzVM6BZtuV0HLmE7eBS7JbiDrR1BswMFcplE
#>             Locale: en_US
#>          Time zone: Etc/GMT
#>        # of sheets: 2
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>      flowers: 7 x 5
#>        autos: 7 x 11
```

`sheets_edit()` and `sheets_append()` are more writing functions that
are useful in specific situations.

## Where to learn more

Learn more about googlesheets4 by reading articles and function docs:

  - [Get started](articles/googlesheets4.html)
  - [googlesheets4 auth](articles/articles/auth.html)
  - [Find and Identify
    Sheets](articles/articles/find-identify-sheets.html)
  - [Write Sheets](articles/articles/write-sheets.html)
  - [Using googlesheets4 with
    googledrive](articles/articles/drive-and-sheets.html)
  - [Fun with googledrive and
    readxl](articles/articles/fun-with-googledrive-and-readxl.html)
  - [How to create a googlesheets4
    reprex](articles/articles/googlesheets4-reprex.html)
  - [All the functions](reference)

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

  - [googlesheets](https://cran.r-project.org/package=googlesheets) is
    the package that googlesheets4 is replacing. Main improvements in
    googlesheets4: (1) wraps the current, most modern Sheets API; (2)
    leans on googledrive for all “whole file” operations; and (3) uses
    shared infrastructure for auth and more, from the gargle package.
    The v3 API wrapped by googlesheets goes offline in March 2020, at
    which point the package must be retired.
  - [googledrive](https://googledrive.tidyverse.org) provides a
    fully-featured interface to the Google Drive API. Any “whole file”
    operations can be accomplished with googledrive: upload or download
    or update a spreadsheet, copy, rename, move, change permission,
    delete, etc. googledrive supports Team Drives.
  - [readxl](https://readxl.tidyverse.org) is the tidyverse package for
    reading Excel files (xls or xlsx) into an R data frame.
    googlesheets4 takes cues from parts of the readxl interface,
    especially around specifying which cells to read.
  - [readr](https://readr.tidyverse.org) is the tidyverse package for
    reading delimited files (e.g., csv or tsv) into an R data frame.
    googlesheets4 takes cues from readr with respect to column type
    specification.
