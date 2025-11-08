# Read a Sheet into a data frame

This is the main "read" function of the googlesheets4 package. It goes
by two names, because we want it to make sense in two contexts:

- `read_sheet()` evokes other table-reading functions, like
  [`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)
  and
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).
  The `sheet` in this case refers to a Google (spread)Sheet.

- `range_read()` is the right name according to the naming convention
  used throughout the googlesheets4 package.

`read_sheet()` and `range_read()` are synonyms and you can use either
one.

## Usage

``` r
range_read(
  ss,
  sheet = NULL,
  range = NULL,
  col_names = TRUE,
  col_types = NULL,
  na = "",
  trim_ws = TRUE,
  skip = 0,
  n_max = Inf,
  guess_max = min(1000, n_max),
  .name_repair = "unique"
)

read_sheet(
  ss,
  sheet = NULL,
  range = NULL,
  col_names = TRUE,
  col_types = NULL,
  na = "",
  trim_ws = TRUE,
  skip = 0,
  n_max = Inf,
  guess_max = min(1000, n_max),
  .name_repair = "unique"
)
```

## Arguments

- ss:

  Something that identifies a Google Sheet:

  - its file id as a string or
    [`drive_id`](https://googledrive.tidyverse.org/reference/drive_id.html)

  - a URL from which we can recover the id

  - a one-row
    [`dribble`](https://googledrive.tidyverse.org/reference/dribble.html),
    which is how googledrive represents Drive files

  - an instance of `googlesheets4_spreadsheet`, which is what
    [`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
    returns

  Processed through
  [`as_sheets_id()`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md).

- sheet:

  Sheet to read, in the sense of "worksheet" or "tab". You can identify
  a sheet by name, with a string, or by position, with a number. Ignored
  if the sheet is specified via `range`. If neither argument specifies
  the sheet, defaults to the first visible sheet.

- range:

  A cell range to read from. If `NULL`, all non-empty cells are read.
  Otherwise specify `range` as described in [Sheets A1
  notation](https://developers.google.com/sheets/api/guides/concepts#a1_notation)
  or using the helpers documented in
  [cell-specification](https://googlesheets4.tidyverse.org/dev/reference/cell-specification.md).
  Sheets uses fairly standard spreadsheet range notation, although a bit
  different from Excel. Examples of valid ranges: `"Sheet1!A1:B2"`,
  `"Sheet1!A:A"`, `"Sheet1!1:2"`, `"Sheet1!A5:A"`, `"A1:B2"`,
  `"Sheet1"`. Interpreted strictly, even if the range forces the
  inclusion of leading, trailing, or embedded empty rows or columns.
  Takes precedence over `skip`, `n_max` and `sheet`. Note `range` can be
  a named range, like `"sales_data"`, without any cell reference.

- col_names:

  `TRUE` to use the first row as column names, `FALSE` to get default
  names, or a character vector to provide column names directly. If user
  provides `col_types`, `col_names` can have one entry per column or one
  entry per unskipped column.

- col_types:

  Column types. Either `NULL` to guess all from the spreadsheet or a
  string of readr-style shortcodes, with one character or code per
  column. If exactly one `col_type` is specified, it is recycled. See
  Column Specification for more.

- na:

  Character vector of strings to interpret as missing values. By
  default, blank cells are treated as missing data.

- trim_ws:

  Logical. Should leading and trailing whitespace be trimmed from cell
  contents?

- skip:

  Minimum number of rows to skip before reading anything, be it column
  names or data. Leading empty rows are automatically skipped, so this
  is a lower bound. Ignored if `range` is given.

- n_max:

  Maximum number of data rows to parse into the returned tibble.
  Trailing empty rows are automatically skipped, so this is an upper
  bound on the number of rows in the result. Ignored if `range` is
  given. `n_max` is imposed locally, after reading all non-empty cells,
  so, if speed is an issue, it is better to use `range`.

- guess_max:

  Maximum number of data rows to use for guessing column types.

- .name_repair:

  Handling of column names. By default, googlesheets4 ensures column
  names are not empty and are unique. There is full support for
  `.name_repair` as documented in
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html).

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Column Specification

Column types must be specified in a single string of readr-style short
codes, e.g. "cci?l" means "character, character, integer, guess,
logical". This is not where googlesheets4's col spec will end up, but it
gets the ball rolling in a way that is consistent with readr and doesn't
reinvent any wheels.

Shortcodes for column types:

- `_` or `-`: Skip. Data in a skipped column is still requested from the
  API (the high-level functions in this package are rectangle-oriented),
  but is not parsed into the data frame output.

- `?`: Guess. A type is guessed for each cell and then a consensus type
  is selected for the column. If no atomic type is suitable for all
  cells, a list-column is created, in which each cell is converted to an
  R object of "best" type. If no column types are specified, i.e.
  `col_types = NULL`, all types are guessed.

- `l`: Logical.

- `i`: Integer. This type is never guessed from the data, because Sheets
  have no formal cell type for integers.

- `d` or `n`: Numeric, in the sense of "double".

- `D`: Date. This type is never guessed from the data, because date
  cells are just serial datetimes that bear a "date" format.

- `t`: Time of day. This type is never guessed from the data, because
  time cells are just serial datetimes that bear a "time" format. *Not
  implemented yet; returns POSIXct.*

- `T`: Datetime, specifically POSIXct.

- `c`: Character.

- `C`: Cell. This type is unique to googlesheets4. This returns raw cell
  data, as an R list, which consists of everything sent by the Sheets
  API for that cell. Has S3 type of `"CELL_SOMETHING"` and
  `"SHEETS_CELL"`. Mostly useful internally, but exposed for those who
  want direct access to, e.g., formulas and formats.

- `L`: List, as in "list-column". Each cell is a length-1 atomic vector
  of its discovered type.

- *Still to come*: duration (code will be `:`) and factor (code will be
  `f`).

## Examples

``` r
ss <- gs4_example("deaths")
read_sheet(ss, range = "A5:F15")
#> ✔ Reading from deaths.
#> ✔ Range A5:F15.
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
read_sheet(ss, range = "other!A5:F15", col_types = "ccilDD")
#> ✔ Reading from deaths.
#> ✔ Range ''other'!A5:F15'.
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
read_sheet(ss, range = "arts_data", col_types = "ccilDD")
#> ✔ Reading from deaths.
#> ✔ Range arts_data.
#> # A tibble: 10 × 6
#>    Name     Profession   Age `Has kids` `Date of birth` `Date of death`
#>    <chr>    <chr>      <int> <lgl>      <date>          <date>         
#>  1 David B… musician      69 TRUE       1947-01-08      2016-01-10     
#>  2 Carrie … actor         60 TRUE       1956-10-21      2016-12-27     
#>  3 Chuck B… musician      90 TRUE       1926-10-18      2017-03-18     
#>  4 Bill Pa… actor         61 TRUE       1955-05-17      2017-02-25     
#>  5 Prince   musician      57 TRUE       1958-06-07      2016-04-21     
#>  6 Alan Ri… actor         69 FALSE      1946-02-21      2016-01-14     
#>  7 Florenc… actor         82 TRUE       1934-02-14      2016-11-24     
#>  8 Harper … author        89 FALSE      1926-04-28      2016-02-19     
#>  9 Zsa Zsa… actor         99 TRUE       1917-02-06      2016-12-18     
#> 10 George … musician      53 FALSE      1963-06-25      2016-12-25     

read_sheet(gs4_example("mini-gap"))
#> ✔ Reading from mini-gap.
#> ✔ Range Africa.
#> # A tibble: 5 × 6
#>   country      continent  year lifeExp     pop gdpPercap
#>   <chr>        <chr>     <dbl>   <dbl>   <dbl>     <dbl>
#> 1 Algeria      Africa     1952    43.1 9279525     2449.
#> 2 Angola       Africa     1952    30.0 4232095     3521.
#> 3 Benin        Africa     1952    38.2 1738315     1063.
#> 4 Botswana     Africa     1952    47.6  442308      851.
#> 5 Burkina Faso Africa     1952    32.0 4469979      543.
read_sheet(
  gs4_example("mini-gap"),
  sheet = "Europe",
  range = "A:D",
  col_types = "ccid"
)
#> ✔ Reading from mini-gap.
#> ✔ Range ''Europe'!A:D'.
#> # A tibble: 5 × 4
#>   country                continent  year lifeExp
#>   <chr>                  <chr>     <int>   <dbl>
#> 1 Albania                Europe     1952    55.2
#> 2 Austria                Europe     1952    66.8
#> 3 Belgium                Europe     1952    68  
#> 4 Bosnia and Herzegovina Europe     1952    53.8
#> 5 Bulgaria               Europe     1952    59.6
```
