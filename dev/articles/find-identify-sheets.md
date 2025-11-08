# Find and identify Sheets

There are many ways to get your hands on your Sheets, in order to work
with them via googlesheets4. They basically range from “ugly, but low
effort” to “more humane, but more effort”.

## Attach googlesheets4

``` r
library(googlesheets4)
```

## Auth

As a regular, interactive user, you can just let googlesheets4 prompt
you for anything it needs re: auth.

Since this article is compiled noninteractively on a server, we have
arranged for googlesheets4 to use a service account token (not shown).

## Use a URL

When you visit a Sheet in the browser, you can copy that URL to your
clipboard. Such URLs look something like this:

    https://docs.google.com/spreadsheets/d/1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY/edit#gid=780868077

which breaks down like this:

    https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/edit#gid=SHEET_ID

Notice that this URL contains a (spread)Sheet ID and a (work)sheet ID.
This URL happens to link to [the official example Sheet that holds
Gapminder
data](https://docs.google.com/spreadsheets/d/1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY/edit#gid=780868077).

googlesheets4 accepts such a URL as the `ss` argument (think
“spreadsheet”) of many functions:

``` r
ugly_url <- "https://docs.google.com/spreadsheets/d/1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY/edit#gid=780868077"
read_sheet(ugly_url)
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

At this time, although the URL may contain both a (spread)Sheet and a
(work)sheet, we only extract the (spread)Sheet ID. If the function
targets a specific (work)sheet, that is typically specified via
arguments like `range` or `sheet` or a default of “first (visible)
sheet”.

These URLs are not particularly nice to look at in your code, though.

## Use a Sheet ID

You can extract the Sheet ID from a URL with
[`as_sheets_id()`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)
(which is what we are doing internally to make the URL work in the first
place):

``` r
ssid <- as_sheets_id(ugly_url)
class(ssid)
#> [1] "sheets_id"  "drive_id"   "vctrs_vctr" "character"
unclass(ssid)
#> [1] "1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY"
```

[`as_sheets_id()`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)
is a generic function, which means it knows what to do with a few
different types of input. For character string input,
[`as_sheets_id()`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)
passes a string through, unless it looks like a URL. If it looks like a
URL, we use a regular expression to extract the Sheet ID. The returned
string bears the classes `sheets_id` and `drive_id` (for playing nicely
with googledrive).

Why did we call `unclass(ssid)` above to see the naked Sheet ID?
Because, by default, when you print an instance of `sheets_id`, we
attempt to show you some current metadata about the Sheet.

``` r
ssid
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#>  Spreadsheet name: gapminder                                   
#>                ID: 1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY
#>            Locale: en_US                                       
#>         Time zone: America/Los_Angeles                         
#>       # of sheets: 5                                           
#> # of named ranges: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       Africa: 625 x 6
#>     Americas: 301 x 6
#>         Asia: 397 x 6
#>       Europe: 361 x 6
#>      Oceania: 25 x 6
#> 
#> ── <named ranges> ─────────────────────────────────────────────────────
#> (Named range): (A1 range)        
#>        canada: 'Americas'!A38:F49
```

This is the same metadata you’ll see when you call
[`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
(but you must call
[`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
explicitly if you want to *store* the returned metadata).

googlesheets4 also accepts a Sheet ID as the `ss` argument of many
functions:

``` r
read_sheet(ssid)
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

I think in a script or app that will endure for a while it is better to
refer to a Sheet by its ID than by its URL. The Sheet ID is nicer to
look at, it is complete, it is minimal.

``` r
ssid <- "1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY"
read_sheet(ssid)
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

Note this demonstration that a Sheet ID also works when provided as a
plain, old string, i.e. it does not **have** to have the `sheets_id`
class. In some contexts, you might even prefer to store it as a string,
in order to bypass the special printing behaviour for `sheets_id`.

When the Sheet is specified via a character string, googlesheets4
assumes it is a Sheet ID (or an ID-containing URL). This is NOT the case
for googledrive, which assumes a character string is a file name or
path. Therefore, for maximum happiness, in a mixed googlesheets4 /
googledrive workflow, it’s a good idea to be explicit and declare a
string to be a Sheet ID, when that is the case.

``` r
ssid <- as_sheets_id("1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY")
read_sheet(ssid)
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

If your script or app targets a specific Sheet, the most efficient and
robust way to address it is by its ID.

## Use the Sheet’s name (uses googledrive)

A big feature of the googledrive package is the ability to navigate
between human-friendly file names and machine-friendly file IDs. Both
the Drive and Sheets APIs require the use of IDs, so the illusion that
you can identify a Drive file by name is provided by the googledrive
package. (A Google Sheet is just a special case of a Drive file … a file
that happens to be a spreadsheet.)

If you need to refer to a Sheet by name, i.e. if you need to lookup its
file ID based on its name, you must use the googledrive package for
that. There are other reasons for using these two packages together: the
Sheets API has an intentionally narrow focus on spreadsheet operations
involving worksheets and cells. General whole-file operations, like copy
/ rename / move / share, must be done via the Drive API and, within R,
via googledrive. See the article [Using googlesheets4 with
googledrive](https://googlesheets4.tidyverse.org/articles/articles/drive-and-sheets.html)
for more.

It’s time to attach googledrive (in addition to the already-attached
googlesheets4):

``` r
library(googledrive)
```

(In our hidden auth chunk, we actually put a shared token into force for
both googlesheets4 and googledrive, anticipating this moment.)

The Sheet we’ve been working with is named “gapminder” and is owned by
the account we’ve logged in as here. We can use
[`googledrive::drive_get()`](https://googledrive.tidyverse.org/reference/drive_get.html)
to identify a file by name:

``` r
(gap_dribble <- drive_get("gapminder"))
#> ✔ The input `path` resolved to exactly 1 file.
#> # A dribble: 1 × 4
#>   name      path      id       drive_resource   
#>   <chr>     <chr>     <drv_id> <list>           
#> 1 gapminder gapminder 1ksUQqF… <named list [35]>
```

[`drive_get()`](https://googledrive.tidyverse.org/reference/drive_get.html)
returns a
[`dribble`](https://googledrive.tidyverse.org/reference/dribble.html), a
“Drive tibble”, where each row holds info on a Drive file.
[`as_sheets_id()`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)
also accepts a one-row `dribble`, so we can get right into our normal
googlesheets4 workflows:

``` r
gap_id <- as_sheets_id(gap_dribble)
unclass(gap_id)
#> [1] "1ksUQqF_K5yKbJr_uWVnFVZhVuxwMyZCvK6MZOEb7Kew"
gap_id
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#>  Spreadsheet name: gapminder                                   
#>                ID: 1ksUQqF_K5yKbJr_uWVnFVZhVuxwMyZCvK6MZOEb7Kew
#>            Locale: en_US                                       
#>         Time zone: America/Los_Angeles                         
#>       # of sheets: 5                                           
#> # of named ranges: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>       Africa: 625 x 6
#>     Americas: 301 x 6
#>         Asia: 397 x 6
#>       Europe: 361 x 6
#>      Oceania: 25 x 6
#> 
#> ── <named ranges> ─────────────────────────────────────────────────────
#> (Named range): (A1 range)        
#>        canada: 'Americas'!A38:F49
```

Since we generally call
[`as_sheets_id()`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)
on whatever the user provides as `ss`, you can even pass `gap_dribble`
straight into googlesheets4 functions.

``` r
sheet_properties(gap_dribble)
#> # A tibble: 5 × 8
#>   name     index         id type  visible grid_rows grid_columns data  
#>   <chr>    <int>      <int> <chr> <lgl>       <int>        <int> <list>
#> 1 Africa       0  780868077 GRID  TRUE          625            6 <NULL>
#> 2 Americas     1   45759261 GRID  TRUE          301            6 <NULL>
#> 3 Asia         2 1984823455 GRID  TRUE          397            6 <NULL>
#> 4 Europe       3 1503562052 GRID  TRUE          361            6 <NULL>
#> 5 Oceania      4 1796776040 GRID  TRUE           25            6 <NULL>
```

Two important things to note:

- googledrive requires auth for functions like
  [`drive_get()`](https://googledrive.tidyverse.org/reference/drive_get.html)
  and
  [`drive_find()`](https://googledrive.tidyverse.org/reference/drive_find.html)
  (see below). At first, you can just react to the interactive auth
  prompts and **make sure you auth as the same user** with googledrive
  and googlesheets4. Once you get tired of doing auth for both packages,
  read the article [Using googlesheets4 with
  googledrive](https://googlesheets4.tidyverse.org/articles/articles/drive-and-sheets.html).
  Coordinated auth should get even easier in the future.
  - In our hidden auth here, we have taken special measures to use a
    shared token for googledrive and googlesheets4.
- Remember to use
  [`drive_get()`](https://googledrive.tidyverse.org/reference/drive_get.html)
  on a Sheet name **that you have**. If you don’t have a Sheet named
  “gapminder”, the code above won’t yield anything. As a rough rule of
  thumb, if you don’t see it at
  [spreadsheets.google.com](http://spreadsheets.google.com), you can’t
  [`drive_get()`](https://googledrive.tidyverse.org/reference/drive_get.html)
  it either.

## List your Sheets (uses googledrive)

What if you want to see all of your Sheets? Or all the Sheets with “gap”
in their name?

[`googledrive::drive_find()`](https://googledrive.tidyverse.org/reference/drive_find.html)
is the workhorse function for these tasks for general Drive files. It
has lots of bells and whistles and we can use one of them to narrow the
search to Google Sheets:

``` r
drive_find(type = "spreadsheet")
#> # A dribble: 9 × 3
#>   name              id       drive_resource   
#>   <chr>             <drv_id> <list>           
#> 1 geological-canary 13fmUp0… <named list [38]>
#> 2 blubbery-lobo     1foTYXQ… <named list [37]>
#> 3 bacciform-booby   15WqCxH… <named list [36]>
#> 4 childsafe-squid   1uGu_BH… <named list [37]>
#> 5 fiery-hart        18KiiL2… <named list [37]>
#> # ℹ 4 more rows
```

This is so handy that we’ve made
[`gs4_find()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_find.md)
in googlesheets4, which is a shortcut for
`drive_find(type = "spreadsheet")`:

``` r
gs4_find()
#> # A dribble: 9 × 3
#>   name              id       drive_resource   
#>   <chr>             <drv_id> <list>           
#> 1 geological-canary 13fmUp0… <named list [38]>
#> 2 blubbery-lobo     1foTYXQ… <named list [37]>
#> 3 bacciform-booby   15WqCxH… <named list [36]>
#> 4 childsafe-squid   1uGu_BH… <named list [37]>
#> 5 fiery-hart        18KiiL2… <named list [37]>
#> # ℹ 4 more rows
```

See the examples for
[`drive_find()`](https://googledrive.tidyverse.org/reference/drive_find.html)
and
[`gs4_find()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_find.md)
for more ideas about how to search Drive effectively for your Sheets.
