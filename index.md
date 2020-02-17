
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
`sheets_deauth()` to indicate there is no need for a token.

Users can take control of auth proactively via the `sheets_auth*()`
family of functions, e.g., to specify your own OAuth app or service
account token or to explicitly deactivate auth. Auth is actually handled
by the gargle package ([gargle.r-lib.org](https://gargle.r-lib.org)),
similar to googledrive, bigrquery, and gmailr, and gargle’s
documentation and articles are the definitive guide to more advanced
topics.

It is common to use googlesheets4 together with the googledrive package
([googledrive.tidyverse.org](https://googledrive.tidyverse.org)). See
the article [Using googlesheets4 with
googledrive](https://googlesheets4.tidyverse.org/articles/articles/drive-and-sheets.html)
for advice on how to streamline auth in this case.

For this overview, we’ve logged into Google as a specific user in a
hidden chunk.

## Attach googlesheets4

``` r
library(googlesheets4)
```

## Example Sheets and `sheets_browse()`

We’ve made a few Sheets available to “anyone with a link”, for use in
examples and docs. Two helper functions make it easy to get your hands
on these file IDs.

`sheets_examples()` lists all the example Sheets and it can also filter
by matching names to a regular expression:

``` r
sheets_examples()
#>                                       mini-gap 
#> "1k94ZVVl6sdj0AXfK9MQOuQ4rOhd1PULqpAu2_kr9MAU" 
#>                                      gapminder 
#> "1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY" 
#>                                         deaths 
#> "1tuYKzSbLukDLe5ymf_ZKdQA8SfOyeMM7rmf6D6NJpxg" 
#>                                  chicken-sheet 
#> "1ct9t1Efv8pAGN9YO5gC2QfRq2wT4XjNoTMXpVeUghJU" 
#>                           formulas-and-formats 
#> "1wPLrWOxxEjp3T1nv2YBxn63FX70Mz5W5Tm4tGc-lRms" 
#>                      cell-contents-and-formats 
#> "1peJXEeAp5Qt3ENoTvkhvenQ36N3kLyq6sq9Dh2ufQ6E" 
#> attr(,"class")
#> [1] "drive_id"

sheets_examples("gap")
#>                                       mini-gap 
#> "1k94ZVVl6sdj0AXfK9MQOuQ4rOhd1PULqpAu2_kr9MAU" 
#>                                      gapminder 
#> "1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY" 
#> attr(,"class")
#> [1] "drive_id"
```

`sheets_example()` requires a regular expression and returns exactly 1
Sheet ID (or throws an error). The print method attempts to reveal the
Sheet metadata available via `sheets_get()`::

``` r
sheets_example("gapminder")
#>   Spreadsheet name: gapminder
#>                 ID: 1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY
#>             Locale: en_US
#>          Time zone: America/Los_Angeles
#>        # of sheets: 5
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>       Africa: 625 x 6
#>     Americas: 301 x 6
#>         Asia: 397 x 6
#>       Europe: 361 x 6
#>      Oceania: 25 x 6
#> 
#> (Named range): (A1 range)        
#>        canada: 'Americas'!A38:F49
```

If you’d like to see a Sheet in the browser, including our example
Sheets, use `sheets_browse()`:

``` r
sheets_example("deaths") %>%
  sheets_browse()
```

## `read_sheet()`

`read_sheet()` is the main “read” function and should evoke
`readr::read_csv()` and `readxl::read_excel()`. It’s an alias for
`sheets_read()`, because most functions in googlesheets4 actually start
with `sheets_`. googlesheets4 is pipe-friendly (and reexports `%>%`),
but works just fine without the pipe.

`read_sheet()` is designed to “just work”, for most people, most of the
time.

``` r
sheets_example("mini-gap") %>% 
  read_sheet()
#> Reading from 'mini-gap'
#> Range 'Africa'
#> # A tibble: 5 x 6
#>   country      continent  year lifeExp     pop gdpPercap
#>   <chr>        <chr>     <dbl>   <dbl>   <dbl>     <dbl>
#> 1 Algeria      Africa     1952    43.1 9279525     2449.
#> 2 Angola       Africa     1952    30.0 4232095     3521.
#> 3 Benin        Africa     1952    38.2 1738315     1063.
#> 4 Botswana     Africa     1952    47.6  442308      851.
#> 5 Burkina Faso Africa     1952    32.0 4469979      543.
```

### Identify and access your own Sheet

Let’s say you have a cheerful Sheet named “deaths”. If you want to
access it by name, use [googledrive](https://googledrive.tidyverse.org)
to identify the document (capture its metadata, especially file ID).

<!-- remove the 'message = 3' later -->

``` r
library(googledrive)

(deaths <- drive_get("deaths"))
#> # A tibble: 1 x 4
#>   name   path     id                                           drive_resource   
#>   <chr>  <chr>    <chr>                                        <list>           
#> 1 deaths ~/deaths 1tuYKzSbLukDLe5ymf_ZKdQA8SfOyeMM7rmf6D6NJpxg <named list [34]>
```

Pass the result to googlesheets4 functions such as:

  - `sheets_get()`: returns spreadsheet-specific metadata. This is also
    revealed whenever you print a `sheets_id` object.
  - `sheets_sheet_names()`: reveals just the (work)sheet names
  - `read_sheet()`: reads cells into a data frame. `sheets_read()` is an
    alias for this.

<!-- end list -->

``` r
sheets_get(deaths)
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

sheets_sheet_names(deaths)
#> [1] "arts"  "other"

read_sheet(deaths, range = "A5:F8")
#> Reading from 'deaths'
#> Range 'A5:F8'
#> # A tibble: 3 x 6
#>   Name       Profession   Age `Has kids` `Date of birth`     `Date of death`    
#>   <chr>      <chr>      <dbl> <lgl>      <dttm>              <dttm>             
#> 1 David Bow… musician      69 TRUE       1947-01-08 00:00:00 2016-01-10 00:00:00
#> 2 Carrie Fi… actor         60 TRUE       1956-10-21 00:00:00 2016-12-27 00:00:00
#> 3 Chuck Ber… musician      90 TRUE       1926-10-18 00:00:00 2017-03-18 00:00:00
```

If you’re willing to refer to the spreadsheet by ID (or URL), just
provide that directly to googlesheets4 functions and omit googledrive
from the workflow.

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

# a URL also works
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

Lesson: googledrive provides the most user-friendly way to refer to
files on Google Drive, including files that are Google Sheets.
googledrive lets you refer to files by name or path. googlesheets4 is
focused on operations specific to Sheets and is more programming
oriented. googlesheets4 requires a file ID or something that contains
the file ID, such as the URL or a `dribble` object obtained via
googledrive.

### Specify the range and column types

Here we read from the mini-Gapminder and `deaths` example Sheets to show
some of the different ways to specify (work)sheet and cell ranges. Note
also that `col_types` gives control of column types, similar to how
`col_types` works in readr.

``` r
read_sheet(sheets_example("mini-gap"), sheet = 2)
#> Reading from 'mini-gap'
#> Range '\'Americas\''
#> # A tibble: 5 x 6
#>   country   continent  year lifeExp      pop gdpPercap
#>   <chr>     <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Argentina Americas   1952    62.5 17876956     5911.
#> 2 Bolivia   Americas   1952    40.4  2883315     2677.
#> 3 Brazil    Americas   1952    50.9 56602560     2109.
#> 4 Canada    Americas   1952    68.8 14785584    11367.
#> 5 Chile     Americas   1952    54.7  6377619     3940.

read_sheet(sheets_example("mini-gap"), sheet = "Oceania", n_max = 3)
#> Reading from 'mini-gap'
#> Range '\'Oceania\''
#> # A tibble: 3 x 6
#>   country     continent  year lifeExp     pop gdpPercap
#>   <chr>       <chr>     <dbl>   <dbl>   <dbl>     <dbl>
#> 1 Australia   Oceania    1952    69.1 8691212    10040.
#> 2 New Zealand Oceania    1952    69.4 1994794    10557.
#> 3 Australia   Oceania    1957    70.3 9712569    10950.

read_sheet(sheets_example("deaths"), skip = 4, n_max = 10)
#> Reading from 'deaths'
#> Range '5:5000000'
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

read_sheet(
  sheets_example("deaths"), range = "other!A5:F15", col_types = "?ci??D"
)
#> Reading from 'deaths'
#> Range '\'other\'!A5:F15'
#> # A tibble: 10 x 6
#>    Name          Profession   Age `Has kids` `Date of birth`     `Date of death`
#>    <chr>         <chr>      <int> <lgl>      <dttm>              <date>         
#>  1 Vera Rubin    scientist     88 TRUE       1928-07-23 00:00:00 2016-12-25     
#>  2 Mohamed Ali   athlete       74 TRUE       1942-01-17 00:00:00 2016-06-03     
#>  3 Morley Safer  journalist    84 TRUE       1931-11-08 00:00:00 2016-05-19     
#>  4 Fidel Castro  politician    90 TRUE       1926-08-13 00:00:00 2016-11-25     
#>  5 Antonin Scal… lawyer        79 TRUE       1936-03-11 00:00:00 2016-02-13     
#>  6 Jo Cox        politician    41 TRUE       1974-06-22 00:00:00 2016-06-16     
#>  7 Janet Reno    lawyer        78 FALSE      1938-07-21 00:00:00 2016-11-07     
#>  8 Gwen Ifill    journalist    61 FALSE      1955-09-29 00:00:00 2016-11-14     
#>  9 John Glenn    astronaut     95 TRUE       1921-07-28 00:00:00 2016-12-08     
#> 10 Pat Summit    coach         64 TRUE       1952-06-14 00:00:00 2016-06-28
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
#> Reading from 'deaths'
#> Range 'arts_data'
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

The named ranges, if any exist, are part of the information returned by
`sheets_get()`.

## Sheet metadata

`sheets_get()` exposes Sheet metadata. It has a nice print method, but
there’s much more info in the object itself.

``` r
(deaths_meta <- sheets_example("deaths") %>% 
   sheets_get())
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

str(deaths_meta, max.level = 1)
#> List of 7
#>  $ spreadsheet_id : chr "1tuYKzSbLukDLe5ymf_ZKdQA8SfOyeMM7rmf6D6NJpxg"
#>  $ spreadsheet_url: chr "https://docs.google.com/spreadsheets/d/1tuYKzSbLukDLe5ymf_ZKdQA8SfOyeMM7rmf6D6NJpxg/edit"
#>  $ name           : chr "deaths"
#>  $ locale         : chr "en"
#>  $ time_zone      : chr "America/Los_Angeles"
#>  $ sheets         :Classes 'tbl_df', 'tbl' and 'data.frame': 2 obs. of  8 variables:
#>  $ named_ranges   :Classes 'tbl_df', 'tbl' and 'data.frame': 2 obs. of  10 variables:
#>  - attr(*, "class")= chr [1:2] "googlesheets4_spreadsheet" "list"

deaths_meta$sheets
#> # A tibble: 2 x 8
#>   name  index         id type  visible grid_rows grid_columns data  
#>   <chr> <int>      <int> <chr> <lgl>       <int>        <int> <list>
#> 1 arts      0 1210215306 GRID  TRUE         1000           26 <NULL>
#> 2 other     1   28655153 GRID  TRUE         1000           26 <NULL>

deaths_meta$named_ranges
#> # A tibble: 2 x 10
#>   name  id    sheet_id start_row end_row start_column end_column sheet_name
#>   <chr> <chr>    <int>     <int>   <int>        <int>      <int> <chr>     
#> 1 arts… ndmz…   1.21e9         5      15            1          6 arts      
#> 2 othe… r5yz…   2.87e7         5      15            1          6 other     
#> # … with 2 more variables: cell_range <chr>, A1_range <chr>
```

## Detailed cell data

`sheets_cells()` returns a data frame with one row per cell and it gives
access to raw cell data sent by the Sheets API.

``` r
(df <- sheets_cells(sheets_example("deaths"), range = "E5:E7"))
#> Reading from 'deaths'
#> Range 'E5:E7'
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
#> Reading from 'deaths'
#> Range 'E5:E7'
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
```

You’ll notice the new (spread)Sheet has a randomly generated name. If
that is a problem, use `sheets_create()` instead, which affords more
control over various aspects of the new Sheet.

Let’s start over: we delete that Sheet and call `sheets_create()`, so we
can specify the new Sheet’s name.

``` r
drive_rm(ss)
#> Files deleted:
#>   * cockeyed-nurseshark: 1on5cD3lg_rDpX-4j1ukBoecha2rUYMbU66Y9zSddmhU

ss <- sheets_create("fluffy-bunny", sheets = df)
```

`sheets_write()` can write to new or existing (work)sheets in this
Sheet. Let’s write the `chickwts` data to a new sheet in `ss`.

``` r
sheets_write(chickwts, ss)
#> Writing to 'fluffy-bunny'
#> Writing to sheet 'chickwts'
```

We can also use `sheets_write()` to replace the data in an existing
sheet.

``` r
sheets_write(data.frame(x = 4:10, letters[4:10]), ss, sheet = "df")
#> Writing to 'fluffy-bunny'
#> Writing to sheet 'df'
```

`sheets_append()` adds one or more rows to an existing sheet.

``` r
sheets_append(data.frame(x = 11, letters[11]), ss, sheet = "df")
#> Writing to 'fluffy-bunny'
#> Appending 1 row(s) to 'df'
```

There is also a family of `sheets_sheet_*()` functions that do pure
(work)sheet operations, such as add and delete.

We take one last look at the sheets we created in `ss`, then clean up.

``` r
sheets_sheet_properties(ss)
#> # A tibble: 2 x 8
#>   name     index         id type  visible grid_rows grid_columns data  
#>   <chr>    <int>      <int> <chr> <lgl>       <int>        <int> <list>
#> 1 df           0 1442873589 GRID  TRUE            9            2 <NULL>
#> 2 chickwts     1  636082063 GRID  TRUE           72            2 <NULL>

drive_rm(ss)
#> Files deleted:
#>   * fluffy-bunny: 1zM5-iQspVyngGchDfmbh4BoA-Li4BkWaxn_kYlzU66I
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
