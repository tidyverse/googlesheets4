# Fun with googledrive and readxl

This article demonstrates how to use googlesheets4, googledrive, and
readxl together. We demonstrate a roundtrip for data that starts and
ends in R, but travels in spreadsheet form, via Google Sheets.

## Attach packages

``` r
library(googlesheets4)
library(googledrive)
#> 
#> Attaching package: 'googledrive'
#> The following objects are masked from 'package:googlesheets4':
#> 
#>     request_generate, request_make
library(readxl)
```

## Auth

As a regular, interactive user, you can just let googlesheets4 prompt
you for anything it needs re: auth.

Since this article is compiled noninteractively on a server, we activate
a service token here, in a hidden chunk. We are also using a shared
token for Sheets and Drive. You can read how to do that in your own work
in the article [Using googlesheets4 with
googledrive](https://googlesheets4.tidyverse.org/articles/articles/drive-and-sheets.html).

## Create a private Sheet from csv with the Drive API

Put the iris data into a csv file.

``` r
(iris_tempfile <- tempfile(pattern = "iris-", fileext = ".csv"))
#> [1] "/tmp/RtmpcGEdwE/iris-279f125abfed.csv"
write.csv(iris, iris_tempfile, row.names = FALSE)
```

Use
[`googledrive::drive_upload()`](https://googledrive.tidyverse.org/reference/drive_upload.html)
to upload the csv and simultaneously convert to a Sheet.

``` r
(iris_ss <- drive_upload(iris_tempfile, type = "spreadsheet"))
#> Local file:
#> • /tmp/RtmpcGEdwE/iris-279f125abfed.csv
#> Uploaded into Drive file:
#> • iris-279f125abfed <id: 1xwkAjxcCI7ykNteqcfqOK1Lh9HnocLtnrD1bUUHGFsw>
#> With MIME type:
#> • application/vnd.google-apps.spreadsheet
#> # A dribble: 1 × 3
#>   name              id       drive_resource   
#>   <chr>             <drv_id> <list>           
#> 1 iris-279f125abfed 1xwkAjx… <named list [37]>

# visit the new Sheet in the browser, in an interactive session!
drive_browse(iris_ss)
```

Read data from the private Sheet into R.

``` r
read_sheet(iris_ss, range = "B1:D6")
#> ✔ Reading from iris-279f125abfed.csv.
#> ✔ Range B1:D6.
#> # A tibble: 5 × 3
#>   Sepal.Width Petal.Length Petal.Width
#>         <dbl>        <dbl>       <dbl>
#> 1         3.5          1.4         0.2
#> 2         3            1.4         0.2
#> 3         3.2          1.3         0.2
#> 4         3.1          1.5         0.2
#> 5         3.6          1.4         0.2
```

## Create a local xlsx from a Sheet with the Drive API

Download the Sheet as an Excel workbook.

``` r
(iris_xlsxfile <- sub("[.]csv", ".xlsx", iris_tempfile))
#> [1] "/tmp/RtmpcGEdwE/iris-279f125abfed.xlsx"
drive_download(iris_ss, path = iris_xlsxfile, overwrite = TRUE)
#> File downloaded:
#> • iris-279f125abfed <id: 1xwkAjxcCI7ykNteqcfqOK1Lh9HnocLtnrD1bUUHGFsw>
#> Saved locally as:
#> • /tmp/RtmpcGEdwE/iris-279f125abfed.xlsx
```

## Read xlsx with readxl

Read the iris data back in via
[`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).

``` r
if (requireNamespace("readxl", quietly = TRUE)) {
  readxl::read_excel(iris_xlsxfile)  
}
#> # A tibble: 150 × 5
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
#> # ℹ 140 more rows
```

## Clean up

``` r
file.remove(iris_tempfile, iris_xlsxfile)
#> [1] TRUE TRUE
drive_trash(iris_ss)
#> File trashed:
#> • iris-279f125abfed <id: 1xwkAjxcCI7ykNteqcfqOK1Lh9HnocLtnrD1bUUHGFsw>
```
