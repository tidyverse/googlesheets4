
# googlesheets4

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

## `read_sheet()`, a.k.a. `sheets_read()`

`read_sheet()` is the main “read” function and should evoke
`readr::read_csv()` and `readxl::read_excel()`. It’s an alias for
`sheets_read()`, because most functions in googlesheets4 actually start
with `sheets_`. googlesheets4 is pipe-friendly (and reexports `%>%`),
but works just fine without the pipe.

`read_sheet()` is designed to “just work”, for most purposes, most of
the time. It can read straight from a Sheets browser URL:

``` r
sheets_read("https://docs.google.com/spreadsheets/d/1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY/edit#gid=780868077")
#> Reading from "gapminder"
#> Range "Africa"
#> # A tibble: 624 x 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> # … with 620 more rows
```

However, these URLs are not pleasant to work with. More often, you will
want to identify a Sheet by its ID:

``` r
sheets_read("1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY")
#> Reading from "gapminder"
#> Range "Africa"
#> # A tibble: 624 x 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> # … with 620 more rows
```

or by its name, which requires an assist from the googledrive package
([googledrive.tidyverse.org](https://googledrive.tidyverse.org)):

<!-- remove the 'message = i' later -->

``` r
library(googledrive)

drive_get("gapminder") %>% 
  sheets_read()
#> Range "Africa"
#> # A tibble: 624 x 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> # … with 620 more rows
```

Note that the name-based approach above will only work if **you** have
access to a Sheet named “gapminder”. Sheet names cannot be used as
absolute identifiers; only a Sheet ID can play that role.

For more Sheet identification concepts and strategies, see the article
[Find and Identify
Sheets](https://googlesheets4.tidyverse.org/articles/articles/find-identify-sheets.html).

## Example Sheets and `sheets_browse()`

We’ve made a few Sheets available to “anyone with a link”, for use in
examples and docs. Two helper functions make it easy to get your hands
on these file IDs.

  - `sheets_examples()` lists all the example Sheets and it can also
    filter by matching names to a regular expression.
  - `sheets_example()` requires a regular expression and returns exactly
    1 Sheet ID (or throws an error).

<!-- end list -->

``` r
sheets_example("chicken-sheet") %>% 
  sheets_read()
#> Reading from "chicken-sheet"
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

If you’d like to see a Sheet in the browser, including our example
Sheets, use `sheets_browse()`:

``` r
sheets_example("deaths") %>%
  sheets_browse()
```

## Sheet metadata

`sheets_get()` exposes Sheet metadata, such as details on worksheets and
named ranges.

``` r
ss <- sheets_example("deaths")

sheets_get(ss)
#>   Spreadsheet name: deaths
#>                 ID: 1tuYKzSbLukDLe5ymf_ZKdQA8SfOyeMM7rmf6D6NJpxg
#>             Locale: en
#>          Time zone: America/Los_Angeles
#>        # of sheets: 2
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>         arts: 1000 x 26
#>        other: 1000 x 26
#> 
#> (Named range): (A1 range)    
#>     arts_data: 'arts'!A5:F15 
#>    other_data: 'other'!A5:F15

sheets_sheet_properties(ss)
#> # A tibble: 2 x 8
#>   name  index         id type  visible grid_rows grid_columns data  
#>   <chr> <int>      <int> <chr> <lgl>       <int>        <int> <list>
#> 1 arts      0 1210215306 GRID  TRUE         1000           26 <NULL>
#> 2 other     1   28655153 GRID  TRUE         1000           26 <NULL>

sheets_sheet_names(ss)
#> [1] "arts"  "other"
```

`sheets_sheet_properties()` and `sheets_sheet_names()` are two members
of a family of functions for dealing with the (work)sheets within a
(spread)Sheet.

## Identify and access your own Sheet

## Specify the range and column types

Here we read from the mini-Gapminder and `deaths` example Sheets to show
some of the different ways to specify (work)sheet and cell ranges. Note
also that `col_types` gives control of column types, similar to how
`col_types` works in readr.

``` r
read_sheet(sheets_example("mini-gap"), sheet = 2)
#> Reading from "mini-gap"
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
#> Reading from "mini-gap"
#> Range "'Oceania'"
#> # A tibble: 3 x 6
#>   country     continent  year lifeExp     pop gdpPercap
#>   <chr>       <chr>     <dbl>   <dbl>   <dbl>     <dbl>
#> 1 Australia   Oceania    1952    69.1 8691212    10040.
#> 2 New Zealand Oceania    1952    69.4 1994794    10557.
#> 3 Australia   Oceania    1957    70.3 9712569    10950.

read_sheet(sheets_example("deaths"), skip = 4, n_max = 10)
#> Reading from "deaths"
#> Range "5:5000000"
#> # A tibble: 10 x 6
#>   Name       Profession   Age `Has kids` `Date of birth`     `Date of death`    
#>   <chr>      <chr>      <dbl> <lgl>      <dttm>              <dttm>             
#> 1 David Bow… musician      69 TRUE       1947-01-08 00:00:00 2016-01-10 00:00:00
#> 2 Carrie Fi… actor         60 TRUE       1956-10-21 00:00:00 2016-12-27 00:00:00
#> 3 Chuck Ber… musician      90 TRUE       1926-10-18 00:00:00 2017-03-18 00:00:00
#> 4 Bill Paxt… actor         61 TRUE       1955-05-17 00:00:00 2017-02-25 00:00:00
#> # … with 6 more rows

read_sheet(
  sheets_example("deaths"), range = "other!A5:F15", col_types = "?ci??D"
)
#> Reading from "deaths"
#> Range "'other'!A5:F15"
#> # A tibble: 10 x 6
#>   Name         Profession   Age `Has kids` `Date of birth`     `Date of death`
#>   <chr>        <chr>      <int> <lgl>      <dttm>              <date>         
#> 1 Vera Rubin   scientist     88 TRUE       1928-07-23 00:00:00 2016-12-25     
#> 2 Mohamed Ali  athlete       74 TRUE       1942-01-17 00:00:00 2016-06-03     
#> 3 Morley Safer journalist    84 TRUE       1931-11-08 00:00:00 2016-05-19     
#> 4 Fidel Castro politician    90 TRUE       1926-08-13 00:00:00 2016-11-25     
#> # … with 6 more rows
```

If you looked at the `deaths` spreadsheet in the browser (it’s
[here](https://docs.google.com/spreadsheets/d/1tuYKzSbLukDLe5ymf_ZKdQA8SfOyeMM7rmf6D6NJpxg/edit#gid=1210215306)),
you know that it has some of the typical features of real world
spreadsheets: the main data rectangle has prose intended for
human-consumption before and after it. That’s why we have to specify the
range when we read from it.

We’ve designated the data rectangles as [named
ranges](https://support.google.com/docs/answer/63175?co=GENIE.Platform%3DDesktop&hl=en),
which provides a very slick way to read them – definitely less brittle
and mysterious than approaches like `range = "other!A5:F15"` or `skip
= 4, n_max = 10`. A named range can be passed via the `range =`
argument:

``` r
sheets_example("deaths") %>% 
  read_sheet(range = "arts_data")
#> Reading from "deaths"
#> Range "arts_data"
#> # A tibble: 10 x 6
#>   Name       Profession   Age `Has kids` `Date of birth`     `Date of death`    
#>   <chr>      <chr>      <dbl> <lgl>      <dttm>              <dttm>             
#> 1 David Bow… musician      69 TRUE       1947-01-08 00:00:00 2016-01-10 00:00:00
#> 2 Carrie Fi… actor         60 TRUE       1956-10-21 00:00:00 2016-12-27 00:00:00
#> 3 Chuck Ber… musician      90 TRUE       1926-10-18 00:00:00 2017-03-18 00:00:00
#> 4 Bill Paxt… actor         61 TRUE       1955-05-17 00:00:00 2017-02-25 00:00:00
#> # … with 6 more rows
```

The named ranges, if any exist, are part of the information returned by
`sheets_get()`.

## Detailed cell data

`sheets_cells()` returns a data frame with one row per cell and it gives
access to raw cell data sent by the Sheets API.

``` r
(df <- sheets_cells(sheets_example("deaths"), range = "E5:E7"))
#> Reading from "deaths"
#> Range "E5:E7"
#> # A tibble: 3 x 4
#>     row   col loc   cell      
#>   <int> <dbl> <chr> <list>    
#> 1     5     5 E5    <CELL_TEX>
#> 2     6     5 E6    <CELL_DAT>
#> 3     7     5 E7    <CELL_DAT>
df$cell[[3]]
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

Specify `cell_data = "full", discard_empty = FALSE` to get even more
data if you, for example, need access to cell formulas or formatting.

`spread_sheet()` 😉 converts data in the “one row per cell” form into the
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
#> Reading from "deaths"
#> Range "E5:E7"
#> # A tibble: 2 x 1
#>   `Date of birth`
#>   <date>         
#> 1 1947-01-08     
#> 2 1956-10-21
```

## Writing Sheets

*The writing functions are still under heavy development, so you can
expect some refinements re: user interface and which function does
what.*

`sheets_write()` writes a data frame into a Sheet. The only required
argument is the data.

``` r
df <- data.frame(x = 1:3, y = letters[1:3])

ss <- sheets_write(df)
ss
#>   Spreadsheet name: sensualist-finch
#>                 ID: 1te2DMex_bnMS_nC4uRfh-F3xMGLFnGQUJ4Moy0oSPNs
#>             Locale: en_US
#>          Time zone: Etc/GMT
#>        # of sheets: 1
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>           df: 4 x 2
```

You’ll notice the new (spread)Sheet has a randomly generated name. If
that is a problem, use `sheets_create()` instead, which affords more
control over various aspects of the new Sheet.

Let’s start over: we delete that Sheet and call `sheets_create()`, so we
can specify the new Sheet’s name.

``` r
drive_rm(ss)
#> Files deleted:
#>   * sensualist-finch: 1te2DMex_bnMS_nC4uRfh-F3xMGLFnGQUJ4Moy0oSPNs

ss <- sheets_create("fluffy-bunny", sheets = df)
```

`sheets_write()` can write to new or existing (work)sheets in this
Sheet. Let’s write the `chickwts` data to a new sheet in `ss`.

``` r
sheets_write(chickwts, ss)
#> Writing to "fluffy-bunny"
#> Writing to sheet "chickwts"
```

We can also use `sheets_write()` to replace the data in an existing
sheet.

``` r
sheets_write(data.frame(x = 4:10, letters[4:10]), ss, sheet = "df")
#> Writing to "fluffy-bunny"
#> Writing to sheet "df"
```

`sheets_append()` adds one or more rows to an existing sheet.

``` r
sheets_append(data.frame(x = 11, letters[11]), ss, sheet = "df")
#> Writing to "fluffy-bunny"
#> Appending 1 row(s) to "df"
```

There is also a family of `sheets_sheet_*()` functions that do pure
(work)sheet operations, such as add and delete.

We take one last look at the sheets we created in `ss`, then clean up.

``` r
sheets_sheet_properties(ss)
#> # A tibble: 2 x 8
#>   name     index         id type  visible grid_rows grid_columns data  
#>   <chr>    <int>      <int> <chr> <lgl>       <int>        <int> <list>
#> 1 df           0 1955382877 GRID  TRUE            9            2 <NULL>
#> 2 chickwts     1  796602399 GRID  TRUE           72            2 <NULL>

drive_rm(ss)
#> Files deleted:
#>   * fluffy-bunny: 11yoA0KiudssULi---ZH3Nwpr3DanuLrhFvH5hw9MER0
```

See also the article [Write
Sheets](https://googlesheets4.tidyverse.org/articles/articles/write-sheets.html).

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
  - [googledrive](https://googledrive.tidyverse.org) already provides a
    fully-featured interface to the Google Drive API. Any “whole file”
    operations can already be accomplished *today* with googledrive:
    upload or download or update a spreadsheet, copy, rename, move,
    change permission, delete, etc. googledrive already supports Team
    Drives.
  - [readxl](https://readxl.tidyverse.org) is the tidyverse package for
    reading Excel files (xls or xlsx) into an R data frame.
    googlesheets4 takes cues from parts of the readxl interface,
    especially around specifying which cells to read.
  - [readr](https://readr.tidyverse.org) is the tidyverse package for
    reading delimited files (e.g., csv or tsv) into an R data frame.
    googlesheets4 takes cues from readr with respect to column type
    specification.
