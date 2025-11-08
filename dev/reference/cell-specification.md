# Specify cells

Many functions in googlesheets4 use a `range` argument to target
specific cells. The Sheets v4 API expects user-specified ranges to be
expressed via [its A1
notation](https://developers.google.com/sheets/api/guides/concepts#a1_notation),
but googlesheets4 accepts and converts a few alternative specifications
provided by the functions in the
[cellranger::cellranger](https://rdrr.io/pkg/cellranger/man/cellranger.html)
package. Of course, you can always provide A1-style ranges directly to
functions like
[`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
or
[`range_read_cells()`](https://googlesheets4.tidyverse.org/dev/reference/range_read_cells.md).
Why would you use the
[cellranger::cellranger](https://rdrr.io/pkg/cellranger/man/cellranger.html)
helpers? Some ranges are practically impossible to express in A1
notation, specifically when you want to describe rectangles with some
bounds that are specified and others determined by the data.

## Examples

``` r
if (FALSE) { # gs4_has_token() && rlang::is_interactive()
ss <- gs4_example("mini-gap")

# Specify only the rows or only the columns
read_sheet(ss, range = cell_rows(1:3))
read_sheet(ss, range = cell_cols("C:D"))
read_sheet(ss, range = cell_cols(1))

# Specify upper or lower bound on row or column
read_sheet(ss, range = cell_rows(c(NA, 4)))
read_sheet(ss, range = cell_cols(c(NA, "D")))
read_sheet(ss, range = cell_rows(c(3, NA)))
read_sheet(ss, range = cell_cols(c(2, NA)))
read_sheet(ss, range = cell_cols(c("C", NA)))

# Specify a partially open rectangle
read_sheet(ss, range = cell_limits(c(2, 3), c(NA, NA)), col_names = FALSE)
read_sheet(ss, range = cell_limits(c(1, 2), c(NA, 4)))
}
```
