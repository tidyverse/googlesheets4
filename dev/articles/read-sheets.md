# Read Sheets

``` r
library(googlesheets4)
```

Basic Sheet reading is shown in the [Get
started](https://googlesheets4.tidyverse.org/articles/googlesheets4.html)
article. Here we show how to target a specific (work)sheet or cell
range, how to deal with column types, and how to get detailed cell data.

## Auth

As a regular, interactive user, you can just let googlesheets4 prompt
you for anything it needs re: auth.

Since this article is compiled noninteractively on a server, we have
arranged for googlesheets4 to use a service account token (not shown).

## `read_sheet()` and `range_read()` are synonyms

The main “read” function of the googlesheets4 package goes by two names,
because we want it to make sense in two contexts:

- [`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  evokes other table-reading functions, like
  [`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)
  and
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).
  The `sheet` in this case refers to a Google (spread)Sheet.

- [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  is technically the right name according to the naming convention used
  throughout the googlesheets4 package, because we can read from an
  arbitrary cell range.

[`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
and
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
are synonyms and you can use either one. Throughout this article, we’re
going to use
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md).

Note: The first release of googlesheets used a `sheets_` prefix
everywhere, so we had `sheets_read()`. It still works, but it’s
deprecated and will go away rather swiftly.

## Specify the range and column types

Here we read from the “mini-gap” and “deaths” example Sheets to show
some of the different ways to specify (work)sheet and cell ranges.

``` r
range_read(gs4_example("mini-gap"), sheet = 2)
#> ✔ Reading from mini-gap.
#> ✔ Range ''Americas''.
#> # A tibble: 5 × 6
#>   country   continent  year lifeExp      pop gdpPercap
#>   <chr>     <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Argentina Americas   1952    62.5 17876956     5911.
#> 2 Bolivia   Americas   1952    40.4  2883315     2677.
#> 3 Brazil    Americas   1952    50.9 56602560     2109.
#> 4 Canada    Americas   1952    68.8 14785584    11367.
#> 5 Chile     Americas   1952    54.7  6377619     3940.

range_read(gs4_example("mini-gap"), sheet = "Oceania", n_max = 3)
#> ✔ Reading from mini-gap.
#> ✔ Range ''Oceania''.
#> # A tibble: 3 × 6
#>   country     continent  year lifeExp     pop gdpPercap
#>   <chr>       <chr>     <dbl>   <dbl>   <dbl>     <dbl>
#> 1 Australia   Oceania    1952    69.1 8691212    10040.
#> 2 New Zealand Oceania    1952    69.4 1994794    10557.
#> 3 Australia   Oceania    1957    70.3 9712569    10950.

range_read(gs4_example("deaths"), skip = 4, n_max = 10)
#> ✔ Reading from deaths.
#> ✔ Range 5:10000000.
#> # A tibble: 10 × 6
#>    Name               Profession   Age `Has kids` `Date of birth`    
#>    <chr>              <chr>      <dbl> <lgl>      <dttm>             
#>  1 David Bowie        musician      69 TRUE       1947-01-08 00:00:00
#>  2 Carrie Fisher      actor         60 TRUE       1956-10-21 00:00:00
#>  3 Chuck Berry        musician      90 TRUE       1926-10-18 00:00:00
#>  4 Bill Paxton        actor         61 TRUE       1955-05-17 00:00:00
#>  5 Prince             musician      57 TRUE       1958-06-07 00:00:00
#>  6 Alan Rickman       actor         69 FALSE      1946-02-21 00:00:00
#>  7 Florence Henderson actor         82 TRUE       1934-02-14 00:00:00
#>  8 Harper Lee         author        89 FALSE      1926-04-28 00:00:00
#>  9 Zsa Zsa Gábor      actor         99 TRUE       1917-02-06 00:00:00
#> 10 George Michael     musician      53 FALSE      1963-06-25 00:00:00
#> # ℹ 1 more variable: `Date of death` <dttm>
```

The example below shows the use of `range` to specify both the
(work)sheet and an A1-style cell range.

It also demonstrates how `col_types` gives control of column types,
similar to how `col_types` works in readr and readxl. Note that
currently there is only support for the “shortcode” style of column
specification and we plan to align better with readr’s capabilities in a
future release.

- For the full list of column types and how to specify them, see the
  [Column
  specification](https://googlesheets4.tidyverse.org/reference/range_read.html#column-specification)
  section of the help for
  [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md).

``` r
range_read(
  gs4_example("deaths"), range = "other!A5:F15", col_types = "?ci??D"
)
#> ✔ Reading from deaths.
#> ✔ Range ''other'!A5:F15'.
#> # A tibble: 10 × 6
#>    Name           Profession   Age `Has kids` `Date of birth`    
#>    <chr>          <chr>      <int> <lgl>      <dttm>             
#>  1 Vera Rubin     scientist     88 TRUE       1928-07-23 00:00:00
#>  2 Mohamed Ali    athlete       74 TRUE       1942-01-17 00:00:00
#>  3 Morley Safer   journalist    84 TRUE       1931-11-08 00:00:00
#>  4 Fidel Castro   politician    90 TRUE       1926-08-13 00:00:00
#>  5 Antonin Scalia lawyer        79 TRUE       1936-03-11 00:00:00
#>  6 Jo Cox         politician    41 TRUE       1974-06-22 00:00:00
#>  7 Janet Reno     lawyer        78 FALSE      1938-07-21 00:00:00
#>  8 Gwen Ifill     journalist    61 FALSE      1955-09-29 00:00:00
#>  9 John Glenn     astronaut     95 TRUE       1921-07-28 00:00:00
#> 10 Pat Summit     coach         64 TRUE       1952-06-14 00:00:00
#> # ℹ 1 more variable: `Date of death` <date>
```

If you looked at the “deaths” spreadsheet in the browser (it’s
[here](https://docs.google.com/spreadsheets/d/1VTJjWoP1nshbyxmL9JqXgdVsimaYty21LGxxs018H2Y)),
you know that it has some of the typical features of real world
spreadsheets: the main data rectangle has prose intended for
human-consumption before and after it. That’s why we have to specify the
range when we read from it.

We’ve designated the data rectangles as [named
ranges](https://support.google.com/docs/answer/63175?co=GENIE.Platform%3DDesktop&hl=en),
which provides a very slick way to read them – definitely less brittle
and mysterious than approaches like `range = "other!A5:F15"` or
`skip = 4, n_max = 10`. A named range can be passed via the `range =`
argument:

``` r
gs4_example("deaths") %>% 
  range_read(range = "arts_data")
#> ✔ Reading from deaths.
#> ✔ Range arts_data.
#> # A tibble: 10 × 6
#>    Name               Profession   Age `Has kids` `Date of birth`    
#>    <chr>              <chr>      <dbl> <lgl>      <dttm>             
#>  1 David Bowie        musician      69 TRUE       1947-01-08 00:00:00
#>  2 Carrie Fisher      actor         60 TRUE       1956-10-21 00:00:00
#>  3 Chuck Berry        musician      90 TRUE       1926-10-18 00:00:00
#>  4 Bill Paxton        actor         61 TRUE       1955-05-17 00:00:00
#>  5 Prince             musician      57 TRUE       1958-06-07 00:00:00
#>  6 Alan Rickman       actor         69 FALSE      1946-02-21 00:00:00
#>  7 Florence Henderson actor         82 TRUE       1934-02-14 00:00:00
#>  8 Harper Lee         author        89 FALSE      1926-04-28 00:00:00
#>  9 Zsa Zsa Gábor      actor         99 TRUE       1917-02-06 00:00:00
#> 10 George Michael     musician      53 FALSE      1963-06-25 00:00:00
#> # ℹ 1 more variable: `Date of death` <dttm>
```

The named ranges, if any exist, are part of the information returned by
[`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md).

## Detailed cell data

[`range_read_cells()`](https://googlesheets4.tidyverse.org/dev/reference/range_read_cells.md)
returns a data frame with one row per cell and it gives access to raw
cell data sent by the Sheets API.

``` r
(df <- range_read_cells(gs4_example("deaths"), range = "E5:E7"))
#> ✔ Reading from deaths.
#> ✔ Range E5:E7.
#> # A tibble: 3 × 4
#>     row   col loc   cell      
#>   <int> <int> <chr> <list>    
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

[`spread_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/spread_sheet.md)
converts data in the “one row per cell” form into the data frame you get
from
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md),
which involves reshaping and column typing.

``` r
df %>% spread_sheet(col_types = "D")
#> # A tibble: 2 × 1
#>   `Date of birth`
#>   <date>         
#> 1 1947-01-08     
#> 2 1956-10-21
## is same as ...
range_read(gs4_example("deaths"), range = "E5:E7", col_types ="D")
#> ✔ Reading from deaths.
#> ✔ Range E5:E7.
#> # A tibble: 2 × 1
#>   `Date of birth`
#>   <date>         
#> 1 1947-01-08     
#> 2 1956-10-21
```

## When speed matters

If your Sheet is so large that the speed of
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
is causing problems, consider
[`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md).
It uses a special URL that allows a Sheet to be read as comma-separated
values (CSV). Access via this URL doesn’t use the Sheets API (although
[`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
still makes an API call to retrieve Sheet metadata). As an example, on a
Sheet with around 57,000 rows and 25 columns (over 1.4 million cells),
[`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
takes ~5 seconds, whereas
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
takes closer to 3 minutes. Why wouldn’t we always take the faster
option?!? Because the speed difference is imperceptible for many Sheets
and there are some downsides (described later).

[`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
has much the same interface as
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md).

``` r
gs4_example("gapminder") %>% 
  range_speedread(sheet = "Oceania", n_max = 3)
#> ✔ Reading from gapminder, sheet Oceania.
#> ℹ Export URL:
#>   <https://docs.google.com/spreadsheets/d/1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY/export?format=csv&gid=1796776040>
#> Rows: 3 Columns: 6
#> ── Column specification ───────────────────────────────────────────────
#> Delimiter: ","
#> chr (2): country, continent
#> dbl (4): year, lifeExp, pop, gdpPercap
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> # A tibble: 3 × 6
#>   country   continent  year lifeExp      pop gdpPercap
#>   <chr>     <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Australia Oceania    1952    69.1  8691212    10040.
#> 2 Australia Oceania    1957    70.3  9712569    10950.
#> 3 Australia Oceania    1962    70.9 10794968    12217.
```

The output above reveals that, under the hood,
[`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
calls an external function for CSV parsing (namely,
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)).
An important consequence is that all arguments around column type
specification are passed along to the CSV-parsing function. Here is a
demo using readr-style column specification:

``` r
gs4_example("deaths") %>% 
  range_speedread(
    range = "other!A5:F15",
    col_types = readr::cols(
      Age = readr::col_integer(),
      `Date of birth` = readr::col_date("%m/%d/%Y"),
      `Date of death` = readr::col_date("%m/%d/%Y")
    )
  )
#> ✔ Reading from deaths, sheet other, range A5:F15.
#> ℹ Export URL:
#>   <https://docs.google.com/spreadsheets/d/1VTJjWoP1nshbyxmL9JqXgdVsimaYty21LGxxs018H2Y/export?format=csv&range=A5%3AF15&gid=278837031>
#> # A tibble: 10 × 6
#>    Name     Profession   Age `Has kids` `Date of birth` `Date of death`
#>    <chr>    <chr>      <int> <lgl>      <date>          <date>         
#>  1 Vera Ru… scientist     88 TRUE       1928-07-23      2016-12-25     
#>  2 Mohamed… athlete       74 TRUE       1942-01-17      2016-06-03     
#>  3 Morley … journalist    84 TRUE       1931-11-08      2016-05-19     
#>  4 Fidel C… politician    90 TRUE       1926-08-13      2016-11-25     
#>  5 Antonin… lawyer        79 TRUE       1936-03-11      2016-02-13     
#>  6 Jo Cox   politician    41 TRUE       1974-06-22      2016-06-16     
#>  7 Janet R… lawyer        78 FALSE      1938-07-21      2016-11-07     
#>  8 Gwen If… journalist    61 FALSE      1955-09-29      2016-11-14     
#>  9 John Gl… astronaut     95 TRUE       1921-07-28      2016-12-08     
#> 10 Pat Sum… coach         64 TRUE       1952-06-14      2016-06-28
```

Compare that to how we would read the same data with
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md):

``` r
gs4_example("deaths") %>% 
  range_read(range = "other_data", col_types = "??i?DD")
#> ✔ Reading from deaths.
#> ✔ Range other_data.
#> # A tibble: 10 × 6
#>    Name     Profession   Age `Has kids` `Date of birth` `Date of death`
#>    <chr>    <chr>      <int> <lgl>      <date>          <date>         
#>  1 Vera Ru… scientist     88 TRUE       1928-07-23      2016-12-25     
#>  2 Mohamed… athlete       74 TRUE       1942-01-17      2016-06-03     
#>  3 Morley … journalist    84 TRUE       1931-11-08      2016-05-19     
#>  4 Fidel C… politician    90 TRUE       1926-08-13      2016-11-25     
#>  5 Antonin… lawyer        79 TRUE       1936-03-11      2016-02-13     
#>  6 Jo Cox   politician    41 TRUE       1974-06-22      2016-06-16     
#>  7 Janet R… lawyer        78 FALSE      1938-07-21      2016-11-07     
#>  8 Gwen If… journalist    61 FALSE      1955-09-29      2016-11-14     
#>  9 John Gl… astronaut     95 TRUE       1921-07-28      2016-12-08     
#> 10 Pat Sum… coach         64 TRUE       1952-06-14      2016-06-28
```

This example highlights two important differences:

- `range = "other!A5:F15"` versus `range = "other_data"`:
  [`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
  can’t access a named range, whereas
  [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  can.
- `readr::col_date("%m/%d/%Y")` vs `D`:
  [`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
  must parse a character representation of all cell data, including
  datetimes, whereas
  [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  has access to the actual cell data and its type.

What’s the speed difference for something like the Africa sheet in the
“gapminder” example Sheet? (around 625 rows x 6 columns, or 3700 cells)

``` r
system.time(
  gs4_example("gapminder") %>% range_speedread(sheet = "Africa")
)
#> ✔ Reading from gapminder, sheet Africa.
#> ℹ Export URL:
#>   <https://docs.google.com/spreadsheets/d/1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY/export?format=csv&gid=780868077>
#> Rows: 624 Columns: 6
#> ── Column specification ───────────────────────────────────────────────
#> Delimiter: ","
#> chr (2): country, continent
#> dbl (4): year, lifeExp, pop, gdpPercap
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#>    user  system elapsed 
#>   0.078   0.015   0.633
system.time(
  gs4_example("gapminder") %>% range_read(sheet = "Africa")
)
#> ✔ Reading from gapminder.
#> ✔ Range ''Africa''.
#>    user  system elapsed 
#>   0.274   0.020   0.676
```

The modest difference above shows that the speed difference is unlikely
to be a gamechanger in many settings.

Summary of how to think about
[`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
vs
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md):

- Both use auth (literally, send a token), unless there was a prior to
  call to
  [`gs4_deauth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_deauth.md).
- [`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
  is faster, but it’s not noticeable for typical Sheets.
- [`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
  uses readr-style column type specification, which is actually more
  flexible than what
  [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  currently does. In future googlesheets4 releases, we will adopt
  readr-style column type specification.
- [`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
  requires more detailed column type specification, because it cannot
  access unformatted cell data and the actual cell type, as
  [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  can.
- [`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
  can’t access full cell data, e.g., formatting.
- [`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
  can’t work with named ranges.
