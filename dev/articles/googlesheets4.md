# Get started with googlesheets4

``` r
library(googlesheets4)
```

This article takes a quick tour of the main features of googlesheets4.
Remember to see [the
articles](https://googlesheets4.tidyverse.org/articles/index.html) for
more detailed treatment of all these topics and more.

## `read_sheet()`, a.k.a. `range_read()`

[`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
is the main “read” function and should evoke
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)
and
[`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).
It’s an alias for
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md),
which is the correct name for this function according to the scheme for
naming googlesheets4 functions. You can use them interchangeably.
googlesheets4 is pipe-friendly (and reexports `%>%`), but works just
fine without the pipe.

[`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
is designed to “just work”, for most purposes, most of the time. It can
read straight from a Sheets browser URL:

``` r
read_sheet("https://docs.google.com/spreadsheets/d/1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY/edit#gid=780868077")
#> ✔ Reading from gapminder.
#> ✔ Range Africa.
#> # A tibble: 624 × 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> 5 Algeria Africa     1972    54.5 14760787     4183.
#> # ℹ 619 more rows
```

However, these URLs are not pleasant to work with. More often, you will
want to identify a Sheet by its ID:

``` r
read_sheet("1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY")
#> ✔ Reading from gapminder.
#> ✔ Range Africa.
#> # A tibble: 624 × 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> 5 Algeria Africa     1972    54.5 14760787     4183.
#> # ℹ 619 more rows
```

or by its name, which requires an assist from the googledrive package
([googledrive.tidyverse.org](https://googledrive.tidyverse.org)):

``` r
library(googledrive)

drive_get("gapminder") %>% 
  read_sheet()
#> ✔ Reading from gapminder.
#> # A tibble: 624 × 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> 5 Algeria Africa     1972    54.5 14760787     4183.
#> # ℹ 619 more rows
```

Note that the name-based approach above will only work if **you** have
access to a Sheet named “gapminder”. Sheet names cannot be used as
absolute identifiers; only a Sheet ID can play that role.

For more Sheet identification concepts and strategies, see the article
[Find and Identify
Sheets](https://googlesheets4.tidyverse.org/articles/articles/find-identify-sheets.html).
See the article [Read
Sheets](https://googlesheets4.tidyverse.org/articles/articles/read-sheets.html)
for more about reading from a specific (work)sheet or ranges, setting
column type, and getting low-level cell data.

## Example Sheets and `gs4_browse()`

We’ve made a few Sheets available to “anyone with a link”, for use in
examples and docs. Two helper functions make it easy to get your hands
on these file IDs.

- [`gs4_examples()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md)
  lists all the example Sheets and it can also filter by matching names
  to a regular expression.
- [`gs4_example()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md)
  requires a regular expression and returns exactly 1 Sheet ID (or
  throws an error).

``` r
gs4_example("chicken-sheet") %>% 
  read_sheet()
#> ✔ Reading from chicken-sheet.
#> ✔ Range chicken.csv.
#> # A tibble: 5 × 4
#>   chicken                 breed            sex     motto               
#>   <chr>                   <chr>            <chr>   <chr>               
#> 1 Foghorn Leghorn         Leghorn          rooster That's a joke, ah s…
#> 2 Chicken Little          unknown          hen     The sky is falling! 
#> 3 Ginger                  Rhode Island Red hen     Listen. We'll eithe…
#> 4 Camilla the Chicken     Chantecler       hen     Bawk, buck, ba-gawk.
#> 5 Ernie The Giant Chicken Brahma           rooster Put Captain Solo in…
```

If you’d like to see a Sheet in the browser, including our example
Sheets, use
[`gs4_browse()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_browse.md):

``` r
gs4_example("deaths") %>%
  gs4_browse()
```

## Sheet metadata

[`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
exposes Sheet metadata, such as details on worksheets and named ranges.

``` r
ss <- gs4_example("deaths")

gs4_get(ss)
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#>  Spreadsheet name: deaths                                      
#>                ID: 1VTJjWoP1nshbyxmL9JqXgdVsimaYty21LGxxs018H2Y
#>            Locale: en_US                                       
#>         Time zone: America/Los_Angeles                         
#>       # of sheets: 2                                           
#> # of named ranges: 2                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>         arts: 1000 x 26
#>        other: 1000 x 26
#> 
#> ── <named ranges> ─────────────────────────────────────────────────────
#> (Named range): (A1 range)    
#>     arts_data: 'arts'!A5:F15 
#>    other_data: 'other'!A5:F15

sheet_properties(ss)
#> # A tibble: 2 × 8
#>   name  index         id type  visible grid_rows grid_columns data  
#>   <chr> <int>      <int> <chr> <lgl>       <int>        <int> <list>
#> 1 arts      0 1512440582 GRID  TRUE         1000           26 <NULL>
#> 2 other     1  278837031 GRID  TRUE         1000           26 <NULL>

sheet_names(ss)
#> [1] "arts"  "other"
```

[`sheet_properties()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md)
and
[`sheet_names()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md)
are two members of a larger family of functions for dealing with the
(work)sheets within a (spread)Sheet.

The metadata exposed by
[`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
is also revealed whenever you print an object that is (or can be
converted to) a `sheets_id` (an S3 class we use to mark Sheet IDs).

[`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
is related to
[`googledrive::drive_get()`](https://googledrive.tidyverse.org/reference/drive_get.html).
Both functions return metadata about a file on Google Drive, such as its
ID and name. However,
[`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
reveals additional metadata that is specific to Drive files that happen
to be Sheets, such as info about worksheets and named ranges.

## Writing Sheets

*The writing functions are the most recent additions and may still see
some refinements re: user interface and which function does what. We’re
very interested to hear how these functions feel in terms of
ergonomics.*

[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
writes a data frame into a Sheet. The only required argument is the
data.

``` r
df <- data.frame(x = 1:3, y = letters[1:3])

ss <- sheet_write(df)
#> ✔ Creating new Sheet: unfearing-guineafowl.
ss
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: unfearing-guineafowl                        
#>               ID: 1LgSpXZRI-jpyx0lg1RPyeLixTB1KQL5lrkhqZpyeLoA
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>           df: 4 x 2
```

You’ll notice the new (spread)Sheet has a randomly generated name. If
that is a problem, use
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
instead, which affords more control over various aspects of the new
Sheet.

Let’s start over: we delete that Sheet and call
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md),
so we can specify the new Sheet’s name.

``` r
googledrive::drive_trash(ss)
#> File trashed:
#> • unfearing-guineafowl
#>   <id: 1LgSpXZRI-jpyx0lg1RPyeLixTB1KQL5lrkhqZpyeLoA>

ss <- gs4_create("testy-hedgehog", sheets = df)
#> ✔ Creating new Sheet: testy-hedgehog.
ss
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: testy-hedgehog                              
#>               ID: 1KPNDIS8K6decXRVCMY39VjROYvHscQlTa3NszeGmVmg
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>           df: 4 x 2
```

[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
can write to new or existing (work)sheets in this Sheet. Let’s write the
`chickwts` data to a new sheet in `ss`.

``` r
sheet_write(chickwts, ss)
#> ✔ Writing to testy-hedgehog.
#> ✔ Writing to sheet chickwts.
ss
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: testy-hedgehog                              
#>               ID: 1KPNDIS8K6decXRVCMY39VjROYvHscQlTa3NszeGmVmg
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 2                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>           df: 4 x 2
#>     chickwts: 72 x 2
```

We can also use
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
to replace the data in an existing sheet.

``` r
sheet_write(data.frame(x = 4:10, letters[4:10]), ss, sheet = "df")
#> ✔ Writing to testy-hedgehog.
#> ✔ Writing to sheet df.
read_sheet(ss, sheet = "df")
#> ✔ Reading from testy-hedgehog.
#> ✔ Range ''df''.
#> # A tibble: 7 × 2
#>       x letters.4.10.
#>   <dbl> <chr>        
#> 1     4 d            
#> 2     5 e            
#> 3     6 f            
#> 4     7 g            
#> 5     8 h            
#> # ℹ 2 more rows
```

[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)
adds one or more rows to an existing sheet.

``` r
ss %>% sheet_append(data.frame(x = 11, letters[11]), sheet = "df")
#> ✔ Writing to testy-hedgehog.
#> ✔ Appending 1 row to df.
read_sheet(ss, sheet = "df")
#> ✔ Reading from testy-hedgehog.
#> ✔ Range ''df''.
#> # A tibble: 8 × 2
#>       x letters.4.10.
#>   <dbl> <chr>        
#> 1     4 d            
#> 2     5 e            
#> 3     6 f            
#> 4     7 g            
#> 5     8 h            
#> # ℹ 3 more rows
```

A related function –
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
– writes arbitrary data, into an arbitrary range. It has a very
different “feel” from
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md),
and
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
all of which assume we’re writing or growing a table of data in a
(work)sheet.
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
is much more surgical and limited.
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
makes fewer assumptions about what it’s writing and why.

There is also a family of `sheet_*()` functions that do pure (work)sheet
operations, such as add and delete.

We take one last look at the sheets we created in `ss`, then clean up.

``` r
sheet_properties(ss)
#> # A tibble: 2 × 8
#>   name     index         id type  visible grid_rows grid_columns data  
#>   <chr>    <int>      <int> <chr> <lgl>       <int>        <int> <list>
#> 1 df           0  884881538 GRID  TRUE            9            2 <NULL>
#> 2 chickwts     1 1106282724 GRID  TRUE           72            2 <NULL>

googledrive::drive_trash(ss)
#> File trashed:
#> • testy-hedgehog <id: 1KPNDIS8K6decXRVCMY39VjROYvHscQlTa3NszeGmVmg>
```

The article [Write
Sheets](https://googlesheets4.tidyverse.org/articles/articles/write-sheets.html)
has even more detail.
