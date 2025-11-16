# Append rows to a sheet

Adds one or more new rows after the last row with data in a (work)sheet,
increasing the row dimension of the sheet if necessary.

## Usage

``` r
sheet_append(ss, data, sheet = 1)
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

- data:

  A data frame.

- sheet:

  Sheet to append to, in the sense of "worksheet" or "tab". You can
  identify a sheet by name, with a string, or by position, with a
  number.

## Value

The input `ss`, as an instance of
[`sheets_id`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

## See also

Makes an `AppendCellsRequest`:

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#AppendCellsRequest>

Other write functions:
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md),
[`gs4_formula()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_formula.md),
[`range_delete()`](https://googlesheets4.tidyverse.org/dev/reference/range_delete.md),
[`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md),
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

Other worksheet functions:
[`sheet_add()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_add.md),
[`sheet_copy()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_copy.md),
[`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md),
[`sheet_properties()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md),
[`sheet_relocate()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_relocate.md),
[`sheet_rename()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_rename.md),
[`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

## Examples

``` r
# we will recreate the table of "other" deaths from this example Sheet
(deaths <- gs4_example("deaths") %>%
  range_read(range = "other_data", col_types = "????DD"))
#> ✔ Reading from deaths.
#> ✔ Range other_data.
#> # A tibble: 10 × 6
#>    Name     Profession   Age `Has kids` `Date of birth` `Date of death`
#>    <chr>    <chr>      <dbl> <lgl>      <date>          <date>         
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

# split the data into 3 pieces, which we will send separately
deaths_one <- deaths[1:5, ]
deaths_two <- deaths[6, ]
deaths_three <- deaths[7:10, ]

# create a Sheet and send the first chunk of data
ss <- gs4_create("sheet-append-demo", sheets = list(deaths = deaths_one))
#> ✔ Creating new Sheet: sheet-append-demo.

# append a single row
ss %>% sheet_append(deaths_two)
#> ✔ Writing to sheet-append-demo.
#> ✔ Appending 1 row to deaths.

# append remaining rows
ss %>% sheet_append(deaths_three)
#> ✔ Writing to sheet-append-demo.
#> ✔ Appending 4 rows to deaths.

# read and check against the original
deaths_replica <- range_read(ss, col_types = "????DD")
#> ✔ Reading from sheet-append-demo.
#> ✔ Range deaths.
identical(deaths, deaths_replica)
#> [1] TRUE

# clean up
gs4_find("sheet-append-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • sheet-append-demo <id: 16MrIzKT_966FHwYhgv2P0Gt8CBp3BGaOat6TmqWMSrA>
```
