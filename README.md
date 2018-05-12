
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/tidyverse/googlesheets4.svg?branch=master)](https://travis-ci.org/tidyverse/googlesheets4)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/tidyverse/googlesheets4?branch=master&svg=true)](https://ci.appveyor.com/project/tidyverse/googlesheets4)
[![Coverage
status](https://codecov.io/gh/tidyverse/googlesheets4/branch/master/graph/badge.svg)](https://codecov.io/github/tidyverse/googlesheets4?branch=master)

# googlesheets4

googlesheets4 provides an R interface to [Google
Sheets](https://spreadsheets.google.com/) via the [Sheets API
v4](https://developers.google.com/sheets/api/). It is a reboot of the
existing [googlesheets
package](https://cran.r-project.org/package=googlesheets).

*Why **4**? Why googlesheets**4**? Did I miss googlesheets1 through 3?
No. The idea is to name the package after the corresponding version of
the Sheets API. In hindsight, the original googlesheets should have
should have been googlesheets**3**.*

## Installation

You can install the released version of googlesheets4 from
[CRAN](https://CRAN.R-project.org) with:

``` r
## NO, NO YOU CANNOT
## install.packages("googlesheets4")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("tidyverse/googlesheets4")
```

## Read a public Sheet

``` r
library(googlesheets4)

## read worksheets out of a spreadsheet with excerpts from the Gapminder data
read_sheet(sheets_example("mini-gap"))
#> Reading from 'test-gs-mini-gapminder'
#> Range "'Africa'"
#> # A tibble: 5 x 6
#>   country      continent  year lifeExp     pop gdpPercap
#>   <chr>        <chr>     <dbl>   <dbl>   <dbl>     <dbl>
#> 1 Algeria      Africa     1952    43.1 9279525     2449.
#> 2 Angola       Africa     1952    30.0 4232095     3521.
#> 3 Benin        Africa     1952    38.2 1738315     1063.
#> 4 Botswana     Africa     1952    47.6  442308      851.
#> 5 Burkina Faso Africa     1952    32.0 4469979      543.
read_sheet(sheets_example("mini-gap"), sheet = 2)
#> Reading from 'test-gs-mini-gapminder'
#> Range "'Americas'"
#> # A tibble: 5 x 6
#>   country   continent  year lifeExp      pop gdpPercap
#>   <chr>     <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Argentina Americas   1952    62.5 17876956     5911.
#> 2 Bolivia   Americas   1952    40.4  2883315     2677.
#> 3 Brazil    Americas   1952    50.9 56602560     2109.
#> 4 Canada    Americas   1952    68.8 14785584    11367.
#> 5 Chile     Americas   1952    54.7  6377619     3940.
read_sheet(sheets_example("mini-gap"), sheet = "Oceania", n_max = 3)
#> Reading from 'test-gs-mini-gapminder'
#> Range "'Oceania'"
#> # A tibble: 3 x 6
#>   country     continent  year lifeExp     pop gdpPercap
#>   <chr>       <chr>     <dbl>   <dbl>   <dbl>     <dbl>
#> 1 Australia   Oceania    1952    69.1 8691212    10040.
#> 2 New Zealand Oceania    1952    69.4 1994794    10557.
#> 3 Australia   Oceania    1957    70.3 9712569    10950.

## read from a Sheets version of an example from readxl
## shows range support and column type specification, mixing types and "guess"
read_sheet(
  sheets_example("deaths"), range = "other!A5:F15", col_types = "?ci??D"
)
#> Reading from 'deaths.xlsx'
#> Range "'other'!A5:F15"
#> # A tibble: 10 x 6
#>    Name    Profession   Age `Has kids` `Date of birth`     `Date of death`
#>    <chr>   <chr>      <int> <lgl>      <dttm>              <date>         
#>  1 Vera R… scientist     88 TRUE       1928-07-23 00:00:00 2016-12-25     
#>  2 Mohame… athlete       74 TRUE       1942-01-17 00:00:00 2016-06-03     
#>  3 Morley… journalist    84 TRUE       1931-11-08 00:00:00 2016-05-19     
#>  4 Fidel … politician    90 TRUE       1926-08-13 00:00:00 2016-11-25     
#>  5 Antoni… lawyer        79 TRUE       1936-03-11 00:00:00 2016-02-13     
#>  6 Jo Cox  politician    41 TRUE       1974-06-22 00:00:00 2016-06-16     
#>  7 Janet … lawyer        78 FALSE      1938-07-21 00:00:00 2016-11-07     
#>  8 Gwen I… journalist    61 FALSE      1955-09-29 00:00:00 2016-11-14     
#>  9 John G… astronaut     95 TRUE       1921-07-28 00:00:00 2016-12-08     
#> 10 Pat Su… coach         64 TRUE       1952-06-14 00:00:00 2016-06-28
```

`read_sheet()` is the main “read” function and should evoke
`readr::read_csv()` and `readxl::read_excel()` for you. It’s an alias
for `sheets_read()`, since most functions in googlesheets actually start
with the `sheets_` prefix. googlesheets4 is pipe-friendly (and rexports
`%>%`), but works just fine without the pipe.

googlesheets4 draws on and complements / emulates other packages in the
tidyverse:

  - [googledrive](http://googledrive.tidyverse.org) already provides a
    fully-featured interface to the Google Drive API. Any “whole file”
    operations can already be accomplished *today* with googledrive:
    upload or download or update a spreadsheet, copy, rename, move,
    change permission, delete, etc. googledrive already supports OAuth2
    and Team Drives.
  - [readxl](https://github.com/tidyverse/readxl) is the tidyverse
    package for reading Excel files (xls or xlsx) into an R data frame.
    googlesheets4 takes cues from parts of the readxl interface,
    especially around specifying which cells to read.
  - [readr](http://readr.tidyverse.org) is the tidyverse package fro
    reading delimited files (e.g., csv or tsv) into an R data frame.
    googlesheets4 takes cues from readr with respect to column type
    specification.

## Other functions

googlesheets4 exposes Sheet metadata via `sheets_get()` and can also be
used to access raw cell data (one row per cell) via `sheets_cell()`.
That data can be post-processed with `spread_sheet()` to obtain the same
data frame you get from `read_sheet()`.

``` r
sheets_get(sheets_example("mini-gap"))
#>   Spreadsheet name: test-gs-mini-gapminder
#>                 ID: 1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY
#>             Locale: en_US
#>          Time zone: Etc/GMT
#>        # of sheets: 5
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>       Africa: 6 x 6
#>     Americas: 6 x 6
#>         Asia: 6 x 6
#>       Europe: 6 x 6
#>      Oceania: 6 x 6

sheets_get(sheets_example("deaths"))
#>   Spreadsheet name: deaths.xlsx
#>                 ID: 1cMH-nYGhhYlBU3wbi9OQ0hJDJn5qb8_kIvfNsGmX7UQ
#>             Locale: en
#>          Time zone: America/Los_Angeles
#>        # of sheets: 2
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>         arts: 1000 x 26
#>        other: 1000 x 26

(df <- sheets_cells(sheets_example("deaths"), range = "E5:E7"))
#> Reading from 'deaths.xlsx'
#> Range "E5:E7"
#> # A tibble: 3 x 4
#>     row   col loc   cell      
#>   <int> <dbl> <chr> <list>    
#> 1     5     5 E5    <list [3]>
#> 2     6     5 E6    <list [4]>
#> 3     7     5 E7    <list [4]>
df$cell[[3]]
#> $userEnteredValue
#> $userEnteredValue$numberValue
#> [1] 20749
#> 
#> 
#> $effectiveValue
#> $effectiveValue$numberValue
#> [1] 20749
#> 
#> 
#> $formattedValue
#> [1] "10/21/1956"
#> 
#> $effectiveFormat
#> $effectiveFormat$numberFormat
#> $effectiveFormat$numberFormat$type
#> [1] "DATE"
#> 
#> $effectiveFormat$numberFormat$pattern
#> [1] "M/D/YYYY"

spread_sheet(df, col_types = "D")
#> # A tibble: 2 x 1
#>   `Date of birth`
#>   <date>         
#> 1 1947-01-08     
#> 2 1956-10-21
read_sheet(sheets_example("deaths"), range = "E5:E7", col_types ="D")
#> Reading from 'deaths.xlsx'
#> Range "E5:E7"
#> # A tibble: 2 x 1
#>   `Date of birth`
#>   <date>         
#> 1 1947-01-08     
#> 2 1956-10-21
```

## What’s coming soon?

OAuth2

Writing to Sheets

*Please note that this project is released with a [Contributor Code of
Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project
you agree to abide by its terms.*
