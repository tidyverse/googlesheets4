# Create useful spreadsheet filler

Creates a data frame that is useful for filling a spreadsheet, when you
just need a sheet to experiment with. The data frame has `n` rows and
`m` columns with these properties:

- Column names match what Sheets displays: "A", "B", "C", and so on.

- Inner cell values reflect the coordinates where each value will land
  in the sheet, in A1-notation. So the first row is "B2", "C2", and so
  on. Note that this `n`-row data frame will occupy `n + 1` rows in the
  sheet, because the column names occupy the first row.

## Usage

``` r
gs4_fodder(n = 10, m = n)
```

## Arguments

- n:

  Number of rows.

- m:

  Number of columns.

## Value

A data frame of character vectors.

## Examples

``` r
gs4_fodder()
#>      A   B   C   D   E   F   G   H   I   J
#> 1   A2  B2  C2  D2  E2  F2  G2  H2  I2  J2
#> 2   A3  B3  C3  D3  E3  F3  G3  H3  I3  J3
#> 3   A4  B4  C4  D4  E4  F4  G4  H4  I4  J4
#> 4   A5  B5  C5  D5  E5  F5  G5  H5  I5  J5
#> 5   A6  B6  C6  D6  E6  F6  G6  H6  I6  J6
#> 6   A7  B7  C7  D7  E7  F7  G7  H7  I7  J7
#> 7   A8  B8  C8  D8  E8  F8  G8  H8  I8  J8
#> 8   A9  B9  C9  D9  E9  F9  G9  H9  I9  J9
#> 9  A10 B10 C10 D10 E10 F10 G10 H10 I10 J10
#> 10 A11 B11 C11 D11 E11 F11 G11 H11 I11 J11
gs4_fodder(5, 3)
#>    A  B  C
#> 1 A2 B2 C2
#> 2 A3 B3 C3
#> 3 A4 B4 C4
#> 4 A5 B5 C5
#> 5 A6 B6 C6
```
