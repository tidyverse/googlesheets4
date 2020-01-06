
<!-- README.md is generated from README.Rmd. Please edit that file -->

# googlesheets4 <a href='https:/googlesheets4.tidyverse.org'><img src='man/figures/logo.png' align="right" height="138.5" /></a>

<!-- badges: start -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/googlesheets4)](https://CRAN.R-project.org/package=googlesheets4)
[![Travis build
status](https://travis-ci.org/tidyverse/googlesheets4.svg?branch=master)](https://travis-ci.org/tidyverse/googlesheets4)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/tidyverse/googlesheets4?branch=master&svg=true)](https://ci.appveyor.com/project/tidyverse/googlesheets4)
[![Coverage
status](https://codecov.io/gh/tidyverse/googlesheets4/branch/master/graph/badge.svg)](https://codecov.io/github/tidyverse/googlesheets4?branch=master)
<!-- badges: end -->

googlesheets4 provides an R interface to [Google
Sheets](https://spreadsheets.google.com/) via the [Sheets API
v4](https://developers.google.com/sheets/api/). It is a reboot of the
existing [googlesheets
package](https://cran.r-project.org/package=googlesheets).

*Why **4**? Why googlesheets**4**? Did I miss googlesheets1 through 3?
No. The idea is to name the package after the corresponding version of
the Sheets API. In hindsight, the original googlesheets should have been
googlesheets**3**.*

The best source of information is always the package website:
[googlesheets4.tidyverse.org](https://googlesheets4.tidyverse.org)

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

## Load googlesheets4

``` r
library(googlesheets4)
```

## Auth

googlesheets4 will, by default, help you interact with Sheets as an
authenticated Google user. The package facilitates this process upon
first need. For this overview, we’ve logged into Google as a specific
user in a hidden chunk. For more about auth, visit the package website:
[googlesheets4.tidyverse.org](https://googlesheets4.tidyverse.org).

## `read_sheet()`

`read_sheet()` is the main “read” function and should evoke
`readr::read_csv()` and `readxl::read_excel()`. It’s an alias for
`sheets_read()`. Most functions in googlesheets4 actually start with
`sheets_`. googlesheets4 is pipe-friendly (and reexports `%>%`), but
works just fine without the pipe.

We demonstrate basic functionality using some world-readable example
sheets accessed via `sheets_examples()` and `sheets_example()`.

Read everything:

``` r
sheets_example("chicken-sheet") %>% 
  read_sheet() # or use sheets_read()
#> Reading from 'chicken-sheet'
#> Range "chicken.csv"
#> # A tibble: 5 x 4
#>   chicken            breed         sex    motto                                 
#>   <chr>              <chr>         <chr>  <chr>                                 
#> 1 Foghorn Leghorn    Leghorn       roost… That's a joke, ah say, that's a joke,…
#> 2 Chicken Little     unknown       hen    The sky is falling!                   
#> 3 Ginger             Rhode Island… hen    Listen. We'll either die free chicken…
#> 4 Camilla the Chick… Chantecler    hen    Bawk, buck, ba-gawk.                  
#> 5 Ernie The Giant C… Brahma        roost… Put Captain Solo in the cargo hold.
```

Read specific cells, from a specific sheet, using an A1-style notation:

``` r
sheets_example("deaths") %>% 
  read_sheet(range = "arts!A5:F15")
#> Reading from 'deaths'
#> Range "'arts'!A5:F15"
#> # A tibble: 10 x 6
#>    Name      Profession   Age `Has kids` `Date of birth`     `Date of death`    
#>    <chr>     <chr>      <dbl> <lgl>      <dttm>              <dttm>             
#>  1 David Bo… musician      69 TRUE       1947-01-08 00:00:00 2016-01-10 00:00:00
#>  2 Carrie F… actor         60 TRUE       1956-10-21 00:00:00 2016-12-27 00:00:00
#>  3 Chuck Be… musician      90 TRUE       1926-10-18 00:00:00 2017-03-18 00:00:00
#>  4 Bill Pax… actor         61 TRUE       1955-05-17 00:00:00 2017-02-25 00:00:00
#>  5 Prince    musician      57 TRUE       1958-06-07 00:00:00 2016-04-21 00:00:00
#>  6 Alan Ric… actor         69 FALSE      1946-02-21 00:00:00 2016-01-14 00:00:00
#>  7 Florence… actor         82 TRUE       1934-02-14 00:00:00 2016-11-24 00:00:00
#>  8 Harper L… author        89 FALSE      1926-04-28 00:00:00 2016-02-19 00:00:00
#>  9 Zsa Zsa … actor         99 TRUE       1917-02-06 00:00:00 2016-12-18 00:00:00
#> 10 George M… musician      53 FALSE      1963-06-25 00:00:00 2016-12-25 00:00:00
```

Read from a named range or region and specify (some of the ) column
types:

``` r
sheets_example("deaths") %>% 
  read_sheet(range = "arts_data", col_types = "??i?DD")
#> Reading from 'deaths'
#> Range "arts_data"
#> # A tibble: 10 x 6
#>    Name              Profession   Age `Has kids` `Date of birth` `Date of death`
#>    <chr>             <chr>      <int> <lgl>      <date>          <date>         
#>  1 David Bowie       musician      69 TRUE       1947-01-08      2016-01-10     
#>  2 Carrie Fisher     actor         60 TRUE       1956-10-21      2016-12-27     
#>  3 Chuck Berry       musician      90 TRUE       1926-10-18      2017-03-18     
#>  4 Bill Paxton       actor         61 TRUE       1955-05-17      2017-02-25     
#>  5 Prince            musician      57 TRUE       1958-06-07      2016-04-21     
#>  6 Alan Rickman      actor         69 FALSE      1946-02-21      2016-01-14     
#>  7 Florence Henders… actor         82 TRUE       1934-02-14      2016-11-24     
#>  8 Harper Lee        author        89 FALSE      1926-04-28      2016-02-19     
#>  9 Zsa Zsa Gábor     actor         99 TRUE       1917-02-06      2016-12-18     
#> 10 George Michael    musician      53 FALSE      1963-06-25      2016-12-25
```

There are various ways to specify the target Sheet. The simplest, but
ugliest, is to provide the URL.

``` r
# url of the 'chicken-sheet' example
url <- "https://docs.google.com/spreadsheets/d/1ct9t1Efv8pAGN9YO5gC2QfRq2wT4XjNoTMXpVeUghJU"
read_sheet(url)
#> Reading from 'chicken-sheet'
#> Range "chicken.csv"
#> # A tibble: 5 x 4
#>   chicken            breed         sex    motto                                 
#>   <chr>              <chr>         <chr>  <chr>                                 
#> 1 Foghorn Leghorn    Leghorn       roost… That's a joke, ah say, that's a joke,…
#> 2 Chicken Little     unknown       hen    The sky is falling!                   
#> 3 Ginger             Rhode Island… hen    Listen. We'll either die free chicken…
#> 4 Camilla the Chick… Chantecler    hen    Bawk, buck, ba-gawk.                  
#> 5 Ernie The Giant C… Brahma        roost… Put Captain Solo in the cargo hold.
```

## Writing Sheets

Write to Sheets with `sheets_write()`, `sheets_create()`, and
`sheets_append()`.

The writing / modifying functionality is under very active development
and is still taking shape. There is a dedicated article: [Write
Sheets](https://googlesheets4.tidyverse.org/articles/articles/write-sheets.html).

Also note that the googledrive package
([googledrive.tidyverse.org](https://googledrive.tidyverse.org)) can be
used to write into Sheets at the “whole file” level, for example, to
upload a local `.csv` or `.xlsx` into a Sheet. See
`googledrive::drive_upload()` and `googledrive::drive_update()`.

## Contributing

If you’d like to contribute to the development of googlesheets4, please
read [these
guidelines](https://googlesheets4.tidyverse.org/CONTRIBUTING.html).

Please note that the ‘googlesheets4’ project is released with a
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
    fully-featured interface to the Google Drive API. Use googledrive
    for all “whole file” operations: upload or download or update a
    spreadsheet, copy, rename, move, change permission, delete, etc.
    googledrive supports Team Drives.
  - [readxl](https://readxl.tidyverse.org) is the tidyverse package for
    reading Excel files (xls or xlsx) into an R data frame.
    googlesheets4 takes cues from parts of the readxl interface,
    especially around specifying which cells to read.
  - [readr](https://readr.tidyverse.org) is the tidyverse package for
    reading delimited files (e.g., csv or tsv) into an R data frame.
    googlesheets4 takes cues from readr with respect to column type
    specification.
