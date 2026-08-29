# Write Sheets

``` r

library(googlesheets4)
```

Basic Sheet writing is shown in the [Get
started](https://googlesheets4.tidyverse.org/articles/googlesheets4.html)
article. Here we explore the different uses for the writing functions:

- [`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
  emphasizes the creation of a new (spread)Sheet.
  - But it can create (work)sheets and write data.
- [`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
  emphasizes writing a data frame into a (work)sheet.
  - But it can create a new (spread)Sheet or a new (work)sheet.
- [`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)
  is about adding rows to an existing data table.
- [`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md),
  [`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md),
  and
  [`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)
  implement holistic operations for representing a single R data frame
  as a table in a (work)sheet within a Google Sheet.
  - [`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
    and
    [`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
    both impose this mentality via specific formatting, such as special
    treatment of the column header row.
  - All 3 functions aim to shrink-wrap the data.
- [`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
  is the one function that helps you write arbitrary data into an
  arbitrary range, although it is still oriented around a data frame.
- [`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md)
  writes common content into all of the cells in a range.
  - An important special case is *clearing* a range of cells of their
    existing values and, optionally, formatting.
- [`range_delete()`](https://googlesheets4.tidyverse.org/dev/reference/range_delete.md)
  deletes a range of cells and shifts other cells into the deleted area.

## Auth

As a regular, interactive user, you can just let googlesheets4 prompt
you for anything it needs re: auth.

Since this article is compiled noninteractively on a server, we have
arranged for googlesheets4 to use a service account token (not shown).

## `gs4_create()`

Create a brand new Sheet with
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md).
You can specify the new Sheet’s `name` (or accept a randomly generated
name).

``` r

ss1 <- gs4_create("sheets-create-demo-1")
#> ✔ Creating new Sheet: sheets-create-demo-1.
ss1
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-create-demo-1                        
#>               ID: 1YB6RTpdK-TKGatlCs7WAdaksJpO4-R_8-wt5Qf-IZhg
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       Sheet1: 1000 x 26
```

Every Sheet *must* have at least one (work)sheet, so Google Sheets
automatically creates an empty “Sheet1”.

You can control the names and content of the initial (work)sheets with
the `sheets` argument.

### Send sheet names

Use a character vector to specify the names of one or more empty sheets.

``` r

ss2 <- gs4_create(
  "sheets-create-demo-2",
  sheets = c("alpha", "beta")
)
#> ✔ Creating new Sheet: sheets-create-demo-2.
ss2
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-create-demo-2                        
#>               ID: 1R1UkVGucrN2dTcqaUvc1wrhLYjDlD1MLlm5gDvVBn28
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 2                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>        alpha: 1000 x 26
#>         beta: 1000 x 26
```

These sheets have no values and get their dimensions from Sheets default
behaviour.

### Send a data frame

If you provide a data frame, it is used to populate the cells of a sheet
and to set sheet dimensions (number of rows and columns). The header row
also gets special treatment. The sheet inherits the name of the data
frame, where possible.

``` r

my_data <- data.frame(x = 1:3, y = letters[1:3])

ss3 <- gs4_create(
  "sheets-create-demo-3",
  sheets = my_data
)
#> ✔ Creating new Sheet: sheets-create-demo-3.
ss3
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-create-demo-3                        
#>               ID: 1SCYcfZGT9PjKpwAVSBYP7oiFJJXPAv7FPlqBs_5bc-c
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>      my_data: 4 x 2
```

### Send multiple data frames

If you provide a list of data frames, each is used to populate the cells
of one sheet and to set sheet dimensions (number of rows and columns).
The header row also gets special treatment. The sheets inherit the names
from the list, if it has names.

``` r

my_data_frames <- list(iris = head(iris), chickwts = head(chickwts))

ss4 <- gs4_create(
  "sheets-create-demo-4",
  sheets = my_data_frames
)
#> ✔ Creating new Sheet: sheets-create-demo-4.
ss4
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-create-demo-4                        
#>               ID: 1GNbBxirF2IL9z81BsIi5LSvfEVUvd--fcNZVaL6ipss
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 2                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>         iris: 7 x 5
#>     chickwts: 7 x 2
```

### Write metadata

Most users won’t need to do this, but
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
can set additional Sheet-level metadata, such as locale or time zone. To
really make use of this feature, you need to read up on the
[`spreadsheets.create`
endpoint](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create).

Notice how the default empty Sheet here is named “Feuille 1”, since we
request a French locale.

``` r

ss5 <- gs4_create(
  "sheets-create-demo-5",
  locale = "fr_FR",
  timeZone = "Europe/Paris"
)
#> ✔ Creating new Sheet: sheets-create-demo-5.
ss5
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-create-demo-5                        
#>               ID: 1KAlTZXZfPjc9xOenSoNLUStTfEyVrbVbC8_flwnX1hM
#>           Locale: fr_FR                                       
#>        Time zone: Europe/Paris                                
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>    Feuille 1: 1000 x 26
```

I would only do this if you have specific evidence that the default
behaviour with respect to locale and time zone is problematic for your
use case.

### Clean up

Trash all the Sheets created above. This actually requires googledrive,
since it is not possible to trash or delete Sheets through the Sheets
API. In our hidden auth process, described earlier, we put a shared
token into force for both Sheets and Drive. You can read how to do that
in your own work in the article [Using googlesheets4 with
googledrive](https://googlesheets4.tidyverse.org/articles/articles/drive-and-sheets.html).

``` r

gs4_find("sheets-create-demo") %>%
  googledrive::drive_trash()
#> Files trashed:
#> • sheets-create-demo-5
#>   <id: 1KAlTZXZfPjc9xOenSoNLUStTfEyVrbVbC8_flwnX1hM>
#> • sheets-create-demo-4
#>   <id: 1GNbBxirF2IL9z81BsIi5LSvfEVUvd--fcNZVaL6ipss>
#> • sheets-create-demo-3
#>   <id: 1SCYcfZGT9PjKpwAVSBYP7oiFJJXPAv7FPlqBs_5bc-c>
#> • sheets-create-demo-2
#>   <id: 1R1UkVGucrN2dTcqaUvc1wrhLYjDlD1MLlm5gDvVBn28>
#> • sheets-create-demo-1
#>   <id: 1YB6RTpdK-TKGatlCs7WAdaksJpO4-R_8-wt5Qf-IZhg>
```

## `write_sheet()`, a.k.a. `sheet_write()`

[`write_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
is aliased to
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
and is meant to evoke
[`readr::write_csv()`](https://readr.tidyverse.org/reference/write_delim.html)
or `writexl::write_xlsx()`. Whereas
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
emphasizes the *target Sheet*,
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
emphasizes the *data you want to write*.

The only required argument for
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
is the data.

``` r

df <- data.frame(x = 1:3, y = letters[1:3])

random_ss <- sheet_write(df)
#> ✔ Creating new Sheet: unfearing-guineafowl.
random_ss
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: unfearing-guineafowl                        
#>               ID: 1b42E24t2TjfkIe18r642AVOvZc0dN3WiKJVydEk0M8s
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>           df: 4 x 2
```

This creates a new (work)sheet inside a new (spread)Sheet and returns
its ID. You’ll notice the new Sheet has a randomly generated name. If
that is a problem, use
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
instead, which affords more control over various aspects of the new
Sheet.

Let’s start over: we delete that Sheet and call
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md),
so we can specify the new Sheet’s name. Then we’ll modify it with
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md).
We send one sheet name, “chickwts”, to prevent the creation of “Sheet1”,
but we send no data.

``` r

googledrive::drive_trash(random_ss)
#> File trashed:
#> • unfearing-guineafowl
#>   <id: 1b42E24t2TjfkIe18r642AVOvZc0dN3WiKJVydEk0M8s>

ss1 <- gs4_create(
  "write-sheets-demo-1",
  sheets = "chickwts"
)
#> ✔ Creating new Sheet: write-sheets-demo-1.
ss1
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: write-sheets-demo-1                         
#>               ID: 1E-ntSQn9KGPi64IxGMiNmRNX-he2uczhLz2BlDDnq8w
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>     chickwts: 1000 x 26
```

[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
allows us to write the actual `chickwts` data into the sheet by that
name.

``` r

sheet_write(chickwts, ss = ss1, sheet = "chickwts")
#> ✔ Writing to write-sheets-demo-1.
#> ✔ Writing to sheet chickwts.
ss1
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: write-sheets-demo-1                         
#>               ID: 1E-ntSQn9KGPi64IxGMiNmRNX-he2uczhLz2BlDDnq8w
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>     chickwts: 72 x 2
```

[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
can also write data into a new sheet, if `sheet` implicitly or
explicitly targets a non-existent sheet.

``` r

# explicitly make a new sheet named "iris"
sheet_write(iris, ss = ss1, sheet = "iris")
#> ✔ Writing to write-sheets-demo-1.
#> ✔ Writing to sheet iris.

# implicitly make a new sheet named "mtcars"
sheet_write(mtcars, ss = ss1)
#> ✔ Writing to write-sheets-demo-1.
#> ✔ Writing to sheet mtcars.
```

If no sheet name is given and it can’t be determined from `data`, a name
of the form “SheetN” is automatically generated by Sheets.

``` r

sheet_write(data.frame(x = 1:2, y = 3:4), ss = ss1)
#> ✔ Writing to write-sheets-demo-1.
#> ✔ Writing to sheet Sheet1.
ss1
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: write-sheets-demo-1                         
#>               ID: 1E-ntSQn9KGPi64IxGMiNmRNX-he2uczhLz2BlDDnq8w
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 4                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>     chickwts: 72 x 2
#>         iris: 151 x 5
#>       mtcars: 33 x 11
#>       Sheet1: 3 x 2
```

### Clean up

``` r

gs4_find("write-sheets-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • write-sheets-demo-1
#>   <id: 1E-ntSQn9KGPi64IxGMiNmRNX-he2uczhLz2BlDDnq8w>
```

## `sheet_append()`

[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)
can add one or more rows of data to an existing (work)sheet.

Let’s recreate the table of “other” deaths from an example Sheet, but
without the annoying text above and below the data. First we bring that
data into a local data frame and chop it into pieces.

``` r

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

deaths_zero  <- deaths[integer(), ] # "scaffolding" data frame with 0 rows
deaths_one   <- deaths[1:5, ] 
deaths_two   <- deaths[6, ]
deaths_three <- deaths[7:10, ]
```

We use
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
to create a new (spread)Sheet and initialize a new (work)sheet with the
“deaths” column headers, but no data. A second empty row is created (it
must be, in order for us to freeze the top row), but it will soon be
filled when we append.

``` r

ss <- gs4_create("sheets-append-demo", sheets = list(deaths = deaths_zero))
#> ✔ Creating new Sheet: sheets-append-demo.
ss
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-append-demo                          
#>               ID: 1pJr_WHwEyYUoxiXn0fCHSPUMjDvv6NmmaF3Sz_AjWbI
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       deaths: 2 x 6
```

If you’re following along, I recommend you open this Sheet in a web
browser with
[`gs4_browse()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_browse.md)
and revisit as we go along, to see how the initial empty row gets
consumed and how additional rows are added to the targetted sheet
automatically.

``` r

gs4_browse(ss)
```

Send the data, one or more rows at a time. Keep inspecting in the
browser if you’re doing this yourself.

``` r

ss
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-append-demo                          
#>               ID: 1pJr_WHwEyYUoxiXn0fCHSPUMjDvv6NmmaF3Sz_AjWbI
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       deaths: 2 x 6

# send several rows
ss %>% sheet_append(deaths_one)
#> ✔ Writing to sheets-append-demo.
#> ✔ Appending 5 rows to deaths.
ss
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-append-demo                          
#>               ID: 1pJr_WHwEyYUoxiXn0fCHSPUMjDvv6NmmaF3Sz_AjWbI
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       deaths: 6 x 6

# send a single row
ss %>% sheet_append(deaths_two)
#> ✔ Writing to sheets-append-demo.
#> ✔ Appending 1 row to deaths.
ss
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-append-demo                          
#>               ID: 1pJr_WHwEyYUoxiXn0fCHSPUMjDvv6NmmaF3Sz_AjWbI
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       deaths: 7 x 6

# send remaining rows
ss %>% sheet_append(deaths_three)
#> ✔ Writing to sheets-append-demo.
#> ✔ Appending 4 rows to deaths.
ss
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-append-demo                          
#>               ID: 1pJr_WHwEyYUoxiXn0fCHSPUMjDvv6NmmaF3Sz_AjWbI
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       deaths: 11 x 6
```

Now the big reveal: have we successfully rebuilt that data through
incremental updates?

``` r

deaths_replica <- range_read(ss, col_types = "????DD")
#> ✔ Reading from sheets-append-demo.
#> ✔ Range deaths.
identical(deaths, deaths_replica)
#> [1] TRUE
```

Gosh I hope that’s still `TRUE` as it was the last time I checked this
article!

### Clean up

``` r

gs4_find("sheets-append-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • sheets-append-demo
#>   <id: 1pJr_WHwEyYUoxiXn0fCHSPUMjDvv6NmmaF3Sz_AjWbI>
```

## `range_write()`

[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
is the least opinionated writing function. It writes data into a range.
It does no explicit formatting, although it can effectively apply
formatting by *clearing* existing formats via `reformat = TRUE` (the
default).

We focus here on the geometry of
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md),
i.e. which cells are edited.

In a hidden chunk, we’ve created a demo Sheet `ss_edit` and we’ve filled
the cells with “-”. We’ve also created `read_this()`, a wrapper around
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
that names columns by letter, like spreadsheets do.

Here’s the initial state of `ss_edit`:

``` r

read_this(ss_edit)
#> ✔ Reading from sheets-edit-demo.
#> ✔ Range Sheet1.
#> # A tibble: 7 × 7
#>   A     B     C     D     E     F     G    
#>   <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 -     -     -     -     -     -     -    
#> 2 -     -     -     -     -     -     -    
#> 3 -     -     -     -     -     -     -    
#> 4 -     -     -     -     -     -     -    
#> 5 -     -     -     -     -     -     -    
#> 6 -     -     -     -     -     -     -    
#> 7 -     -     -     -     -     -     -
```

`df` is a small data frame we’ll send as the `data` argument of
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md):

``` r

(df <- tibble(V1 = head(LETTERS,3), V2 = tail(LETTERS, 3)))
#> # A tibble: 3 × 2
#>   V1    V2   
#>   <chr> <chr>
#> 1 A     X    
#> 2 B     Y    
#> 3 C     Z
```

If we do not specify the range, `df` is written into the upper left
corner and only affects cells spanned by `df`. To see where we’ve
written, focus on the cells are NOT “-”.

``` r

range_write(ss_edit, data = df) %>% read_this()
#> ✔ Editing sheets-edit-demo.
#> ✔ Writing to sheet Sheet1.
#> ✔ Reading from sheets-edit-demo.
#> ✔ Range Sheet1.
#> # A tibble: 7 × 7
#>   A     B     C     D     E     F     G    
#>   <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 V1    V2    -     -     -     -     -    
#> 2 A     X     -     -     -     -     -    
#> 3 B     Y     -     -     -     -     -    
#> 4 C     Z     -     -     -     -     -    
#> 5 -     -     -     -     -     -     -    
#> 6 -     -     -     -     -     -     -    
#> 7 -     -     -     -     -     -     -
```

(Here, and between all subsequent chunks, we reset `ss_edit` to its
initial state.)

If we target a **single cell** with `range`, it specifies the upper left
corner of the target area. The cells written are determined by the
extent of the data.

``` r

range_write(ss_edit, data = df, range = "C2") %>% read_this()
#> ✔ Editing sheets-edit-demo.
#> ✔ Writing to sheet Sheet1.
#> ✔ Reading from sheets-edit-demo.
#> ✔ Range Sheet1.
#> # A tibble: 7 × 7
#>   A     B     C     D     E     F     G    
#>   <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 -     -     -     -     -     -     -    
#> 2 -     -     V1    V2    -     -     -    
#> 3 -     -     A     X     -     -     -    
#> 4 -     -     B     Y     -     -     -    
#> 5 -     -     C     Z     -     -     -    
#> 6 -     -     -     -     -     -     -    
#> 7 -     -     -     -     -     -     -
```

If `range` specifies multiple cells (it can even be unbounded on some
sides), it is taken literally and all covered cells are written. If
`range` is larger than the data, this results in some cells being
*cleared* of their values. In this example, the `range` is “too big” for
the data, so the remaining cells are cleared of their existing “-”
value.

``` r

range_write(ss_edit, data = df, range = "D4:G7") %>% read_this()
#> ✔ Editing sheets-edit-demo.
#> ✔ Writing to sheet Sheet1.
#> ✔ Reading from sheets-edit-demo.
#> ✔ Range Sheet1.
#> # A tibble: 7 × 7
#>   A     B     C     D     E     F     G    
#>   <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 -     -     -     -     -     -     -    
#> 2 -     -     -     -     -     -     -    
#> 3 -     -     -     -     -     -     -    
#> 4 -     -     -     V1    V2    NA    NA   
#> 5 -     -     -     A     X     NA    NA   
#> 6 -     -     -     B     Y     NA    NA   
#> 7 -     -     -     C     Z     NA    NA
```

Here’s another case where the `range` is bigger than it needs to be and
it’s unbounded on the bottom and top:

``` r

range_write(ss_edit, data = df, range = "B:E") %>% read_this()
#> ✔ Editing sheets-edit-demo.
#> ✔ Writing to sheet Sheet1.
#> ✔ Reading from sheets-edit-demo.
#> ✔ Range Sheet1.
#> # A tibble: 7 × 7
#>   A     B     C     D     E     F     G    
#>   <chr> <chr> <chr> <lgl> <lgl> <chr> <chr>
#> 1 -     V1    V2    NA    NA    -     -    
#> 2 -     A     X     NA    NA    -     -    
#> 3 -     B     Y     NA    NA    -     -    
#> 4 -     C     Z     NA    NA    -     -    
#> 5 -     NA    NA    NA    NA    -     -    
#> 6 -     NA    NA    NA    NA    -     -    
#> 7 -     NA    NA    NA    NA    -     -
```

Here’s another `range` that’s unbounded on the left and “too big”:

``` r

range_write(ss_edit, data = df, range = "B2:6") %>% read_this()
#> ✔ Editing sheets-edit-demo.
#> ✔ Writing to sheet Sheet1.
#> ✔ Reading from sheets-edit-demo.
#> ✔ Range Sheet1.
#> # A tibble: 7 × 7
#>   A     B     C     D     E     F     G    
#>   <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 -     -     -     -     -     -     -    
#> 2 -     V1    V2    NA    NA    NA    NA   
#> 3 -     A     X     NA    NA    NA    NA   
#> 4 -     B     Y     NA    NA    NA    NA   
#> 5 -     C     Z     NA    NA    NA    NA   
#> 6 -     NA    NA    NA    NA    NA    NA   
#> 7 -     -     -     -     -     -     -
```

The target sheet will be expanded, if necessary, if and only if `range`
is a single cell (i.e. it gives the upper left corner).

``` r

range_write(ss_edit, data = df, range = "G6") %>% read_this()
#> ✔ Editing sheets-edit-demo.
#> ✔ Writing to sheet Sheet1.
#> ✔ Changing dims: (7 x 7) --> (9 x 8).
#> ✔ Reading from sheets-edit-demo.
#> ✔ Range Sheet1.
#> # A tibble: 9 × 8
#>   A     B     C     D     E     F     G     H    
#>   <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 -     -     -     -     -     -     -     NA   
#> 2 -     -     -     -     -     -     -     NA   
#> 3 -     -     -     -     -     -     -     NA   
#> 4 -     -     -     -     -     -     -     NA   
#> 5 -     -     -     -     -     -     -     NA   
#> 6 -     -     -     -     -     -     V1    V2   
#> 7 -     -     -     -     -     -     A     X    
#> 8 NA    NA    NA    NA    NA    NA    B     Y    
#> 9 NA    NA    NA    NA    NA    NA    C     Z
```

Although the `data` argument of
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
must be a data frame, note that this does not actually limit what you
can write:

- Use `col_names = FALSE` to suppress sending the column names.
- By definition, each variable of a data frame can be of different type.
- By using a list-column, each row of a data frame column can be of
  different type.

The examples for
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
show writing data of disparate type to a 1-row or a 1-column region.

### Clean up

``` r

gs4_find("sheets-edit-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • sheets-edit-demo <id: 1MYYz1jZh3F-lbwXPoEPDuLqydCyJw1F2V3Kmzqght8c>
```

## Write formulas

All the writing functions can write *formulas* into cells, if you
indicate this in the R object you are writing, i.e. in the data frame.
The
[`gs4_formula()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_formula.md)
function marks a character vector as containing Sheets formulas, as
opposed to regular character strings.

Here’s a demo that also shows off using the Google Translate API inside
a Sheet.

``` r

lang_dat <- tibble::tribble(
       ~ english, ~ to,
           "dog", "es",
   "hello world", "ko",
  "baby turtles", "th" 
)
lang_dat$translated <- gs4_formula(
  '=GoogleTranslate(INDIRECT("R[0]C[-2]", FALSE), "en", INDIRECT("R[0]C[-1]", FALSE))'
)

(ss <- gs4_create("sheets-formula-demo", sheets = lang_dat))
#> ✔ Creating new Sheet: sheets-formula-demo.
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-formula-demo                         
#>               ID: 1TidoaVz1XdcdoGiJV-AxdXI6CX-uYrOZvFH_ouvvbn8
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>     lang_dat: 4 x 3
```

Now we can read the data back out, complete with translations!

``` r

range_read(ss)
#> ✔ Reading from sheets-formula-demo.
#> ✔ Range lang_dat.
#> # A tibble: 3 × 3
#>   english      to    translated     
#>   <chr>        <chr> <chr>          
#> 1 dog          es    perro          
#> 2 hello world  ko    안녕하세요 세상
#> 3 baby turtles th    ลูกเต่า
```

### Clean up

``` r

gs4_find("sheets-formula-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • sheets-formula-demo
#>   <id: 1TidoaVz1XdcdoGiJV-AxdXI6CX-uYrOZvFH_ouvvbn8>
```

## `range_flood()`

[`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md)
“floods” all cells in a range with common content. By default, it floods
them with no content, i.e. it clears cells of their existing value and
format. Note that
[`range_clear()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md)
is a convenience wrapper for this special case.

First, we create a data frame and initialize a new Sheet with that data.

``` r

df <- gs4_fodder(10)
(ss <- gs4_create("range-flood-demo", sheets = list(df)))
#> ✔ Creating new Sheet: range-flood-demo.
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: range-flood-demo                            
#>               ID: 1ty-EaKmkEn-Tg_ovCKhCW2MOeQ54lsc9_Hdc5eNP8eQ
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       Sheet1: 11 x 10
```

To begin, each cell holds its A1-coordinates as its value. If you viewed
this in the browser, you’d see the header row has some special
formatting, including a gray background.

``` r

range_read(ss)
#> ✔ Reading from range-flood-demo.
#> ✔ Range Sheet1.
#> # A tibble: 10 × 10
#>    A     B     C     D     E     F     G     H     I     J    
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 A2    B2    C2    D2    E2    F2    G2    H2    I2    J2   
#>  2 A3    B3    C3    D3    E3    F3    G3    H3    I3    J3   
#>  3 A4    B4    C4    D4    E4    F4    G4    H4    I4    J4   
#>  4 A5    B5    C5    D5    E5    F5    G5    H5    I5    J5   
#>  5 A6    B6    C6    D6    E6    F6    G6    H6    I6    J6   
#>  6 A7    B7    C7    D7    E7    F7    G7    H7    I7    J7   
#>  7 A8    B8    C8    D8    E8    F8    G8    H8    I8    J8   
#>  8 A9    B9    C9    D9    E9    F9    G9    H9    I9    J9   
#>  9 A10   B10   C10   D10   E10   F10   G10   H10   I10   J10  
#> 10 A11   B11   C11   D11   E11   F11   G11   H11   I11   J11
```

By default,
[`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md)
sends an empty cell (and clears existing formatting).

``` r

range_flood(ss, range = "A1:B3")
#> ✔ Editing range-flood-demo.
#> ✔ Editing sheet Sheet1.
range_read(ss)
#> ✔ Reading from range-flood-demo.
#> ✔ Range Sheet1.
#> New names:
#> • `` -> `...1`
#> • `` -> `...2`
#> # A tibble: 10 × 10
#>    ...1  ...2  C     D     E     F     G     H     I     J    
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 NA    NA    C2    D2    E2    F2    G2    H2    I2    J2   
#>  2 NA    NA    C3    D3    E3    F3    G3    H3    I3    J3   
#>  3 A4    B4    C4    D4    E4    F4    G4    H4    I4    J4   
#>  4 A5    B5    C5    D5    E5    F5    G5    H5    I5    J5   
#>  5 A6    B6    C6    D6    E6    F6    G6    H6    I6    J6   
#>  6 A7    B7    C7    D7    E7    F7    G7    H7    I7    J7   
#>  7 A8    B8    C8    D8    E8    F8    G8    H8    I8    J8   
#>  8 A9    B9    C9    D9    E9    F9    G9    H9    I9    J9   
#>  9 A10   B10   C10   D10   E10   F10   G10   H10   I10   J10  
#> 10 A11   B11   C11   D11   E11   F11   G11   H11   I11   J11
```

We can’t easily demonstrate this here, but if you are working with a
sheet in the browser, you can experiment with `reformat = TRUE/FALSE` to
clear the existing format (or not).

We can also send a new value into a range of cells.

``` r

range_flood(ss, range = "4:5", cell = ";-)")
#> ✔ Editing range-flood-demo.
#> ✔ Editing sheet Sheet1.
range_read(ss)
#> ✔ Reading from range-flood-demo.
#> ✔ Range Sheet1.
#> New names:
#> • `` -> `...1`
#> • `` -> `...2`
#> # A tibble: 10 × 10
#>    ...1  ...2  C     D     E     F     G     H     I     J    
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 NA    NA    C2    D2    E2    F2    G2    H2    I2    J2   
#>  2 NA    NA    C3    D3    E3    F3    G3    H3    I3    J3   
#>  3 ;-)   ;-)   ;-)   ;-)   ;-)   ;-)   ;-)   ;-)   ;-)   ;-)  
#>  4 ;-)   ;-)   ;-)   ;-)   ;-)   ;-)   ;-)   ;-)   ;-)   ;-)  
#>  5 A6    B6    C6    D6    E6    F6    G6    H6    I6    J6   
#>  6 A7    B7    C7    D7    E7    F7    G7    H7    I7    J7   
#>  7 A8    B8    C8    D8    E8    F8    G8    H8    I8    J8   
#>  8 A9    B9    C9    D9    E9    F9    G9    H9    I9    J9   
#>  9 A10   B10   C10   D10   E10   F10   G10   H10   I10   J10  
#> 10 A11   B11   C11   D11   E11   F11   G11   H11   I11   J11
```

### Clean up

``` r

gs4_find("range-flood-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • range-flood-demo <id: 1ty-EaKmkEn-Tg_ovCKhCW2MOeQ54lsc9_Hdc5eNP8eQ>
```

## `range_delete()`

[`range_delete()`](https://googlesheets4.tidyverse.org/dev/reference/range_delete.md)
deletes a range of cells and shifts other cells into the deleted area.
If you’re trying to delete an entire (work)sheet or change its actual
dimensions or extent, you should, instead, use
[`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md)
or
[`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md).
If you just want to clear values or formats, use
[`range_clear()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md).

First, we create a data frame and initialize a new Sheet with that data.

``` r

df <- gs4_fodder(4)
(ss <- gs4_create("sheets-delete-demo", sheets = list(df)))
#> ✔ Creating new Sheet: sheets-delete-demo.
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: sheets-delete-demo                          
#>               ID: 1wlr86M5Wrj-BQlweGvZFUAZp6r7XIcgtrSKtXDg1ovc
#>           Locale: en_US                                       
#>        Time zone: Etc/GMT                                     
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       Sheet1: 5 x 4
```

To begin, each cell holds its A1-coordinates as its value. If you viewed
this in the browser, you’d see the header row has some special
formatting, including a gray background.

``` r

range_read(ss)
#> ✔ Reading from sheets-delete-demo.
#> ✔ Range Sheet1.
#> # A tibble: 4 × 4
#>   A     B     C     D    
#>   <chr> <chr> <chr> <chr>
#> 1 A2    B2    C2    D2   
#> 2 A3    B3    C3    D3   
#> 3 A4    B4    C4    D4   
#> 4 A5    B5    C5    D5
```

Let’s delete some rows.

``` r

range_delete(ss, range = "2:3")
#> ✔ Editing sheets-delete-demo.
#> ✔ Deleting cells in sheet Sheet1.
range_read(ss)
#> ✔ Reading from sheets-delete-demo.
#> ✔ Range Sheet1.
#> # A tibble: 2 × 4
#>   A     B     C     D    
#>   <chr> <chr> <chr> <chr>
#> 1 A4    B4    C4    D4   
#> 2 A5    B5    C5    D5
```

Let’s delete a column.

``` r

range_delete(ss, range = "C")
#> ✔ Editing sheets-delete-demo.
#> ✔ Deleting cells in sheet Sheet1.
range_read(ss)
#> ✔ Reading from sheets-delete-demo.
#> ✔ Range Sheet1.
#> # A tibble: 2 × 3
#>   A     B     D    
#>   <chr> <chr> <chr>
#> 1 A4    B4    D4   
#> 2 A5    B5    D5
```

Let’s delete a bounded cell range. Since it’s unclear how to fill this
space, we must specify `shift`. We’ll fill the space by shifting
remaining cells to the left. Remember that `range` continues to refer to
actual rows and columns and, due to our deletions, no longer match with
the values which reflect the original locations.

``` r

range_delete(ss, range = "B2:B3", shift = "left")
#> ✔ Editing sheets-delete-demo.
#> ✔ Deleting cells in sheet Sheet1.
range_read(ss)
#> ✔ Reading from sheets-delete-demo.
#> ✔ Range Sheet1.
#> # A tibble: 2 × 3
#>   A     B     D    
#>   <chr> <chr> <lgl>
#> 1 A4    D4    NA   
#> 2 A5    D5    NA
```

### Clean up

``` r

gs4_find("sheets-delete-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • sheets-delete-demo
#>   <id: 1wlr86M5Wrj-BQlweGvZFUAZp6r7XIcgtrSKtXDg1ovc>
```
