
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
the Sheets API. In hindsight, the original googlesheets should have been
googlesheets**3**.*

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

## Auth

googlesheets4 will, by default, help you interact with Sheets as an
authenticated Google user. The package facilitates this process upon
first need.

Users can take control of auth proactively via the `sheets_auth*()`
family of functions, e.g. to specify your own OAuth app or service
account token. Auth is actually handled by the gargle package
(<https://gargle.r-lib.org>), similar to googledrive, bigrquery, and
gmailr, and gargle’s documentation and articles are the definitive guide
to more advanced topics.

For this overview, we’ve logged into Google as a specific user in a
hidden chunk.

## `read_sheet()`

`read_sheet()` is the main “read” function and should evoke
`readr::read_csv()` and `readxl::read_excel()`. It’s an alias for
`sheets_read()`. Most functions in googlesheets4 actually start with
`sheets_`. googlesheets4 is pipe-friendly (and reexports `%>%`), but
works just fine without the pipe.

### Identify and access your own Sheet

Let’s say you have a cheerful Google Sheet named “deaths”. If you want
to access it by name, use
[googledrive](https://googledrive.tidyverse.org) to identify the
document (capture its metadata, especially file id).

<!-- remove the 'message = 4' later -->

``` r
library(googledrive)
library(googlesheets4)

(deaths <- drive_get("deaths"))
#> # A tibble: 1 x 4
#>   name   path     id                                       drive_resource  
#>   <chr>  <chr>    <chr>                                    <list>          
#> 1 deaths ~/deaths 1ESTf_tH08qzWwFYRC1NVWJjswtLdZn9EGw5e3Z… <named list [35…
```

Pass the result to googlesheets4 functions such as:

  - `sheets_get()`: gets spreadsheet-specific metadata
  - `read_sheet()`: reads cells into a data frame. `sheets_read()` is an
    alias for this.

<!-- end list -->

``` r
sheets_get(deaths)
#>   Spreadsheet name: deaths
#>                 ID: 1ESTf_tH08qzWwFYRC1NVWJjswtLdZn9EGw5e3Z5wMzA
#>             Locale: en
#>          Time zone: America/Los_Angeles
#>        # of sheets: 2
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>         arts: 1000 x 26
#>        other: 1000 x 26

read_sheet(deaths, range = "A5:F8")
#> Reading from 'deaths'
#> Range "'arts'!A5:F8"
#> # A tibble: 3 x 6
#>   Name  Profession   Age `Has kids` `Date of birth`     `Date of death`    
#>   <chr> <chr>      <dbl> <lgl>      <dttm>              <dttm>             
#> 1 Davi… musician      69 TRUE       1947-01-08 00:00:00 2016-01-10 00:00:00
#> 2 Carr… actor         60 TRUE       1956-10-21 00:00:00 2016-12-27 00:00:00
#> 3 Chuc… musician      90 TRUE       1926-10-18 00:00:00 2017-03-18 00:00:00
```

If you’re willing to refer to the spreadsheet by id (or URL), just
provide that directly to googlesheets4 functions and omit googledrive.

``` r
sheets_get("1ESTf_tH08qzWwFYRC1NVWJjswtLdZn9EGw5e3Z5wMzA")
#>   Spreadsheet name: deaths
#>                 ID: 1ESTf_tH08qzWwFYRC1NVWJjswtLdZn9EGw5e3Z5wMzA
#>             Locale: en
#>          Time zone: America/Los_Angeles
#>        # of sheets: 2
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>         arts: 1000 x 26
#>        other: 1000 x 26

# the URL also works
sheets_get("https://docs.google.com/spreadsheets/d/1ESTf_tH08qzWwFYRC1NVWJjswtLdZn9EGw5e3Z5wMzA/edit#gid=1210215306")
#>   Spreadsheet name: deaths
#>                 ID: 1ESTf_tH08qzWwFYRC1NVWJjswtLdZn9EGw5e3Z5wMzA
#>             Locale: en
#>          Time zone: America/Los_Angeles
#>        # of sheets: 2
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>         arts: 1000 x 26
#>        other: 1000 x 26
```

Lesson: googledrive provides the user-friendliest way to refer to files
on Google Drive, including files that are Google Sheets. googledrive
lets you refer to files by name or path. googlesheets4 is focused on
operations specific to Sheets and is more programming oriented. You must
pass a file id or something that contains the file id, such as the URL
or a `dribble` object obtained via googledrive.

### Specify the range and column types

We’ve made a few world-readable Sheets easy to access via
`sheets_example()`.

``` r
library(googlesheets4)

sheets_example()
#>                                      gapminder 
#> "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ" 
#>                                       mini-gap 
#> "1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY" 
#>                                             ff 
#> "132Ij_8ggTKVLnLqCOM3ima6mV9F8rmY7HEcR-5hjWoQ" 
#>                                   design-dates 
#> "1xTUxWGcFLtDIHoYJ1WsjQuLmpUtBf--8Bcu5lQ302SU" 
#>                                         deaths 
#> "1ESTf_tH08qzWwFYRC1NVWJjswtLdZn9EGw5e3Z5wMzA"
```

Here we read from a mini-Gapminder Sheet to show some of the different
ways to specify (work)sheet and cell ranges. Note also that `col_types`
gives control of column types, similar to `col_types` works in readr.

``` r
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

read_sheet(sheets_example("deaths"), skip = 4, n_max = 10)
#> Reading from 'deaths'
#> Range "'arts'!5:1000"
#> # A tibble: 10 x 6
#>    Name  Profession   Age `Has kids` `Date of birth`    
#>    <chr> <chr>      <dbl> <lgl>      <dttm>             
#>  1 Davi… musician      69 TRUE       1947-01-08 00:00:00
#>  2 Carr… actor         60 TRUE       1956-10-21 00:00:00
#>  3 Chuc… musician      90 TRUE       1926-10-18 00:00:00
#>  4 Bill… actor         61 TRUE       1955-05-17 00:00:00
#>  5 Prin… musician      57 TRUE       1958-06-07 00:00:00
#>  6 Alan… actor         69 FALSE      1946-02-21 00:00:00
#>  7 Flor… actor         82 TRUE       1934-02-14 00:00:00
#>  8 Harp… author        89 FALSE      1926-04-28 00:00:00
#>  9 Zsa … actor         99 TRUE       1917-02-06 00:00:00
#> 10 Geor… musician      53 FALSE      1963-06-25 00:00:00
#> # … with 1 more variable: `Date of death` <dttm>

read_sheet(
  sheets_example("deaths"), range = "other!A5:F15", col_types = "?ci??D"
)
#> Reading from 'deaths'
#> Range "'other'!A5:F15"
#> # A tibble: 10 x 6
#>    Name     Profession   Age `Has kids` `Date of birth`     `Date of death`
#>    <chr>    <chr>      <int> <lgl>      <dttm>              <date>         
#>  1 Vera Ru… scientist     88 TRUE       1928-07-23 00:00:00 2016-12-25     
#>  2 Mohamed… athlete       74 TRUE       1942-01-17 00:00:00 2016-06-03     
#>  3 Morley … journalist    84 TRUE       1931-11-08 00:00:00 2016-05-19     
#>  4 Fidel C… politician    90 TRUE       1926-08-13 00:00:00 2016-11-25     
#>  5 Antonin… lawyer        79 TRUE       1936-03-11 00:00:00 2016-02-13     
#>  6 Jo Cox   politician    41 TRUE       1974-06-22 00:00:00 2016-06-16     
#>  7 Janet R… lawyer        78 FALSE      1938-07-21 00:00:00 2016-11-07     
#>  8 Gwen If… journalist    61 FALSE      1955-09-29 00:00:00 2016-11-14     
#>  9 John Gl… astronaut     95 TRUE       1921-07-28 00:00:00 2016-12-08     
#> 10 Pat Sum… coach         64 TRUE       1952-06-14 00:00:00 2016-06-28
```

## Roundtripping with a private Sheet

Here is a demo of putting the iris data into a new, private Sheet. Then
reading it back into R and exporting as an Excel workbook. Then reading
that back into R\!

First, put the iris data into a csv file.

``` r
(iris_tempfile <- tempfile(pattern = "iris-", fileext = ".csv"))
#> [1] "/var/folders/yx/3p5dt4jj1019st0x90vhm9rr0000gn/T//RtmpMebA2C/iris-73b57a343fad.csv"
write.csv(iris, iris_tempfile, row.names = FALSE)
```

Use `googledrive::drive_upload()` to upload the csv and simultaneously
convert to a Sheet.

``` r
(iris_ss <- drive_upload(iris_tempfile, type = "spreadsheet"))
#> Local file:
#>   * /var/folders/yx/3p5dt4jj1019st0x90vhm9rr0000gn/T//RtmpMebA2C/iris-73b57a343fad.csv
#> uploaded into Drive file:
#>   * iris-73b57a343fad: 1YMcbAgaeEFaGyCQXfYtbodAhhl7HT3iTF1GP1BfsRvE
#> with MIME type:
#>   * application/vnd.google-apps.spreadsheet
#> # A tibble: 1 x 3
#>   name             id                                      drive_resource  
#> * <chr>            <chr>                                   <list>          
#> 1 iris-73b57a343f… 1YMcbAgaeEFaGyCQXfYtbodAhhl7HT3iTF1GP1… <named list [34…

## visit the new Sheet in the browser, in an interactive session!
drive_browse(iris_ss)
```

Read data from the private Sheet into R.

``` r
read_sheet(iris_ss, range = "B1:D6")
#> Reading from 'iris-73b57a343fad'
#> Range "'iris-73b57a343fad.csv'!B1:D6"
#> # A tibble: 5 x 3
#>   Sepal.Width Petal.Length Petal.Width
#>         <dbl>        <dbl>       <dbl>
#> 1         3.5          1.4         0.2
#> 2         3            1.4         0.2
#> 3         3.2          1.3         0.2
#> 4         3.1          1.5         0.2
#> 5         3.6          1.4         0.2
```

Download the Sheet as an Excel workbook and read it back in via
`readxl::read_excel()`.

``` r
(iris_xlsxfile <- sub("[.]csv", ".xlsx", iris_tempfile))
#> [1] "/var/folders/yx/3p5dt4jj1019st0x90vhm9rr0000gn/T//RtmpMebA2C/iris-73b57a343fad.xlsx"
drive_download(iris_ss, path = iris_xlsxfile, overwrite = TRUE)
#> File downloaded:
#>   * iris-73b57a343fad
#> Saved locally as:
#>   * /var/folders/yx/3p5dt4jj1019st0x90vhm9rr0000gn/T//RtmpMebA2C/iris-73b57a343fad.xlsx
readxl::read_excel(iris_xlsxfile)
#> # A tibble: 150 x 5
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>           <dbl>       <dbl>        <dbl>       <dbl> <chr>  
#>  1          5.1         3.5          1.4         0.2 setosa 
#>  2          4.9         3            1.4         0.2 setosa 
#>  3          4.7         3.2          1.3         0.2 setosa 
#>  4          4.6         3.1          1.5         0.2 setosa 
#>  5          5           3.6          1.4         0.2 setosa 
#>  6          5.4         3.9          1.7         0.4 setosa 
#>  7          4.6         3.4          1.4         0.3 setosa 
#>  8          5           3.4          1.5         0.2 setosa 
#>  9          4.4         2.9          1.4         0.2 setosa 
#> 10          4.9         3.1          1.5         0.1 setosa 
#> # … with 140 more rows
```

Clean up.

``` r
file.remove(iris_tempfile, iris_xlsxfile)
#> [1] TRUE TRUE
drive_rm(iris_ss)
#> Files deleted:
#>   * iris-73b57a343fad: 1YMcbAgaeEFaGyCQXfYtbodAhhl7HT3iTF1GP1BfsRvE
```

## Get Sheet metadata or detailed cell data

`sheets_get()` exposes Sheet metadata. It has a nice print method, but
there’s much more info in the object itself.

``` r
(mini_gap_meta <- sheets_get(sheets_example("mini-gap")))
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

str(mini_gap_meta, max.level = 1)
#> List of 7
#>  $ spreadsheet_id : chr "1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY"
#>  $ spreadsheet_url: chr "https://docs.google.com/a/rstudio.com/spreadsheets/d/1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY/edit"
#>  $ name           : chr "test-gs-mini-gapminder"
#>  $ locale         : chr "en_US"
#>  $ time_zone      : chr "Etc/GMT"
#>  $ sheets         :Classes 'tbl_df', 'tbl' and 'data.frame': 5 obs. of  7 variables:
#>  $ named_ranges   :List of 4
#>  - attr(*, "class")= chr [1:2] "sheets_meta" "list"

mini_gap_meta$sheets
#> # A tibble: 5 x 7
#>   name     index id         type  visible grid_rows grid_columns
#>   <chr>    <int> <chr>      <chr> <lgl>       <int>        <int>
#> 1 Africa       0 2141688971 GRID  TRUE            6            6
#> 2 Americas     1 2105295598 GRID  TRUE            6            6
#> 3 Asia         2 1349264090 GRID  TRUE            6            6
#> 4 Europe       3 1394602536 GRID  TRUE            6            6
#> 5 Oceania      4 1167867454 GRID  TRUE            6            6
```

`sheets_cells()` returns a data frame with one row per cell and it gives
access to raw cell data sent by the Sheets API.

``` r
(df <- sheets_cells(sheets_example("deaths"), range = "E5:E7"))
#> Reading from 'deaths'
#> Range "'arts'!E5:E7"
#> # A tibble: 3 x 4
#>     row   col loc   cell      
#>   <int> <dbl> <chr> <list>    
#> 1     5     5 E5    <CELL_TEX>
#> 2     6     5 E6    <CELL_DAT>
#> 3     7     5 E7    <CELL_DAT>
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
#> 
#> 
#> 
#> attr(,"class")
#> [1] "CELL_DATE"   "SHEETS_CELL"
```

`spread_sheet()` converts data in the “one row per cell” form into the
data frame you get from `read_sheet()`, which involves reshaping and
column typing.

``` r
df %>% spread_sheet(col_types = "D")
#> # A tibble: 2 x 1
#>   `Date of birth`
#>   <date>         
#> 1 1947-01-08     
#> 2 1956-10-21
## is same as ...
read_sheet(sheets_example("deaths"), range = "E5:E7", col_types ="D")
#> Reading from 'deaths'
#> Range "'arts'!E5:E7"
#> # A tibble: 2 x 1
#>   `Date of birth`
#>   <date>         
#> 1 1947-01-08     
#> 2 1956-10-21
```

## What’s yet to come?

Writing into Sheets. As shown above, googledrive can already be used to
write into Sheets at the “whole file” level, because that is carried out
via the Drive API. `googledrive::drive_upload()` and
`googledrive::drive_update()` are very useful for this.

But, if you need more granular control, such as writing to specific
worksheets or cells, that requires the Sheets API. This is not yet
implemented in googlesheets4, but will be.

## Context

googlesheets4 draws on and complements / emulates other packages in the
tidyverse:

  - [googledrive](http://googledrive.tidyverse.org) already provides a
    fully-featured interface to the Google Drive API. Any “whole file”
    operations can already be accomplished *today* with googledrive:
    upload or download or update a spreadsheet, copy, rename, move,
    change permission, delete, etc. googledrive already supports OAuth2
    and Team Drives.
  - [readxl](http://readxl.tidyverse.org) is the tidyverse package for
    reading Excel files (xls or xlsx) into an R data frame.
    googlesheets4 takes cues from parts of the readxl interface,
    especially around specifying which cells to read.
  - [readr](http://readr.tidyverse.org) is the tidyverse package for
    reading delimited files (e.g., csv or tsv) into an R data frame.
    googlesheets4 takes cues from readr with respect to column type
    specification.

*Please note that this project is released with a [Contributor Code of
Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project
you agree to abide by its terms.*

[Privacy policy](https://www.tidyverse.org/google_privacy_policy)
