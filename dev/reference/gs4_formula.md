# Class for Google Sheets formulas

In order to write a formula into Google Sheets, you need to store it as
an object of class `googlesheets4_formula`. This is how we distinguish a
"regular" character string from a string that should be interpreted as a
formula. `googlesheets4_formula` is an S3 class implemented using the
[vctrs package](https://vctrs.r-lib.org/articles/s3-vector.html).

## Usage

``` r
gs4_formula(x = character())
```

## Arguments

- x:

  Character.

## Value

An S3 vector of class `googlesheets4_formula`.

## See also

Other write functions:
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md),
[`range_delete()`](https://googlesheets4.tidyverse.org/dev/reference/range_delete.md),
[`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md),
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

## Examples

``` r
dat <- data.frame(x = c(1, 5, 3, 2, 4, 6))

ss <- gs4_create("gs4-formula-demo", sheets = dat)
#> ✔ Creating new Sheet: gs4-formula-demo.
ss
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: gs4-formula-demo                            
#>               ID: 10NMAW4Ea0lLwWiJVyOcrvBBaBZKvnA7N27ta93pwsbk
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>          dat: 7 x 1

summaries <- tibble::tribble(
  ~desc, ~summaries,
  "max", "=max(A:A)",
  "sum", "=sum(A:A)",
  "min", "=min(A:A)",
  "sparkline", "=SPARKLINE(A:A, {\"color\", \"blue\"})"
)

# explicitly declare a column as `googlesheets4_formula`
summaries$summaries <- gs4_formula(summaries$summaries)
summaries
#> # A tibble: 4 × 2
#>   desc      summaries                         
#>   <chr>     <fmla>                            
#> 1 max       =max(A:A)                         
#> 2 sum       =sum(A:A)                         
#> 3 min       =min(A:A)                         
#> 4 sparkline =SPARKLINE(A:A, {"color", "blue"})

range_write(ss, data = summaries, range = "C1", reformat = FALSE)
#> ✔ Editing gs4-formula-demo.
#> ✔ Writing to sheet dat.
#> ✔ Changing dims: (7 x 1) --> (7 x 4).

miscellany <- tibble::tribble(
  ~desc, ~example,
  "hyperlink", "=HYPERLINK(\"http://www.google.com/\",\"Google\")",
  "image", "=IMAGE(\"https://www.google.com/images/srpr/logo3w.png\")"
)
miscellany$example <- gs4_formula(miscellany$example)
miscellany
#> # A tibble: 2 × 2
#>   desc      example                                                
#>   <chr>     <fmla>                                                 
#> 1 hyperlink =HYPERLINK("http://www.google.com/","Google")          
#> 2 image     =IMAGE("https://www.google.com/images/srpr/logo3w.png")

sheet_write(miscellany, ss = ss)
#> ✔ Writing to gs4-formula-demo.
#> ✔ Writing to sheet miscellany.

# clean up
gs4_find("gs4-formula-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • gs4-formula-demo <id: 10NMAW4Ea0lLwWiJVyOcrvBBaBZKvnA7N27ta93pwsbk>
```
