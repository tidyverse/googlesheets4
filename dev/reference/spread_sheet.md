# Spread a data frame of cells into spreadsheet shape

Reshapes a data frame of cells (presumably the output of
[`range_read_cells()`](https://googlesheets4.tidyverse.org/dev/reference/range_read_cells.md))
into another data frame, i.e., puts it back into the shape of the source
spreadsheet. This function exists primarily for internal use and for
testing. The flagship function
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md),
a.k.a.
[`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md),
is what most users are looking for. It is basically
[`range_read_cells()`](https://googlesheets4.tidyverse.org/dev/reference/range_read_cells.md) +
`spread_sheet()`.

## Usage

``` r
spread_sheet(
  df,
  col_names = TRUE,
  col_types = NULL,
  na = "",
  trim_ws = TRUE,
  guess_max = min(1000, max(df$row)),
  .name_repair = "unique"
)
```

## Arguments

- df:

  A data frame with one row per (nonempty) cell, integer variables `row`
  and `column` (probably referring to location within the spreadsheet),
  and a list-column `cell` of `SHEET_CELL` objects.

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

- guess_max:

  Maximum number of data rows to use for guessing column types.

- .name_repair:

  Handling of column names. By default, googlesheets4 ensures column
  names are not empty and are unique. There is full support for
  `.name_repair` as documented in
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html).

## Value

A tibble in the shape of the original spreadsheet, but enforcing user's
wishes regarding column names, column types, `NA` strings, and
whitespace trimming.

## Examples

``` r
df <- gs4_example("mini-gap") %>%
  range_read_cells()
#> ✖ Request 1 failed [429: RESOURCE_EXHAUSTED, per user quota].
#> ℹ Will retry in 61s.
#> ⠙ Retry happens in  1m
#> ⠹ Retry happens in  1m
#> ⠸ Retry happens in  1m
#> ⠼ Retry happens in  1m
#> ⠴ Retry happens in 49s
#> ⠦ Retry happens in 46s
#> ⠧ Retry happens in 43s
#> ⠇ Retry happens in 40s
#> ⠏ Retry happens in 37s
#> ⠋ Retry happens in 34s
#> ⠙ Retry happens in 31s
#> ⠹ Retry happens in 28s
#> ⠸ Retry happens in 25s
#> ⠼ Retry happens in 22s
#> ⠴ Retry happens in 19s
#> ⠦ Retry happens in 16s
#> ⠧ Retry happens in 13s
#> ⠇ Retry happens in 10s
#> ⠏ Retry happens in  7s
#> ⠋ Retry happens in  4s
#> ⠙ Retry happens in  1s
#> ✔ Request 2 successful!
#> ⠙ Retry happens in  1s
#> ⠙ Retry happens in  0s
#> ✔ Reading from mini-gap.
#> ✔ Range Africa.
spread_sheet(df)
#> # A tibble: 5 × 6
#>   country      continent  year lifeExp     pop gdpPercap
#>   <chr>        <chr>     <dbl>   <dbl>   <dbl>     <dbl>
#> 1 Algeria      Africa     1952    43.1 9279525     2449.
#> 2 Angola       Africa     1952    30.0 4232095     3521.
#> 3 Benin        Africa     1952    38.2 1738315     1063.
#> 4 Botswana     Africa     1952    47.6  442308      851.
#> 5 Burkina Faso Africa     1952    32.0 4469979      543.

# ^^ gets same result as ...
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
```
