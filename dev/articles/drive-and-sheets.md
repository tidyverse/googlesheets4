# Using googlesheets4 with googledrive

## Why use googlesheets4 and googledrive together?

googlesheets4 wraps the Sheets API v4, which lets you read, write, and
format data in Sheets. The Sheets API is very focused on
spreadsheet-oriented data and metadata, i.e. (work)sheets and cells.

The Sheets API offers practically no support for file-level operations,
other than basic spreadsheet creation. There is no way to delete, copy,
or rename a Sheet or to place it in a folder or to change its sharing
permissions. We must use the Drive API for all of this, which is wrapped
by the googledrive package (<https://googledrive.tidyverse.org>).

Another reason to use the googlesheets4 and googledrive packages
together is for ease of file (Sheet) identification. The googlesheets4
package requires you to specify the target Sheet by its ID, not by its
*name*. That’s because the underlying APIs only accept file IDs. But the
googledrive package offers lots of support for navigating between
human-friendly file names and their associated IDs. This support applies
to all files on Drive and, specifically, to Sheets.

Therefore, it is common to use googledrive and googlesheets4 together in
a script or app.

## Coordinating auth

How does auth work if you’re using googlesheets4 **and** googledrive?
The path of least resistance is to do nothing and just let each package
deal with its own auth. This works fine! But it’s a bit clunky and you
need to make sure you’re using the same Google identity (email) with
each package/API.

It can be nicer to be proactive about auth and use the same token for
your googledrive and googlesheets4 work. Below we show a couple of ways
to do this.

## Auth with googledrive first, then googlesheets4

Outline:

- Make sure auth happens first with googledrive, probably by calling
  [`googledrive::drive_auth()`](https://googledrive.tidyverse.org/reference/drive_auth.html)
  yourself. The default scope is
  `"https://www.googleapis.com/auth/drive"`, which is sufficient for all
  your Drive and Sheets work.
- Tell googlesheets4 to use the same token as googledrive.

First attach both packages.

``` r

library(googledrive)
library(googlesheets4)
```

Do auth first with googledrive. Remember
[`googledrive::drive_auth()`](https://googledrive.tidyverse.org/reference/drive_auth.html)
accepts additional arguments, e.g. to specify a Google identity via
`email =` or to use a service account via `path =`. Then direct
googlesheets4 to use the same token as googledrive.

``` r

drive_auth()
gs4_auth(token = drive_token())
```

Now you can use googledrive functions, like
[`googledrive::drive_find()`](https://googledrive.tidyverse.org/reference/drive_find.html)
or
[`googledrive::drive_get()`](https://googledrive.tidyverse.org/reference/drive_get.html),
to list files or find them by name, path, or other property. Then, once
you’ve identified the target file, use googlesheets4 to do
spreadsheet-specific tasks.

``` r

drive_find("chicken")
#> # A dribble: 1 × 3
#>   name          id       drive_resource   
#>   <chr>         <drv_id> <list>           
#> 1 chicken-sheet 1StV8oq… <named list [38]>

ss <- drive_get("chicken-sheet")
#> ✔ The input `path` resolved to exactly 1 file.

gs4_get(ss)
#> ✖ Request 1 failed [503: UNAVAILABLE].
#> ℹ Will retry in 1.8s.
#> ✔ Request 2 successful!
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: chicken-sheet                               
#>               ID: 1StV8oqHa0SVo58ztLGPH5mDMMHIBsiF6VO5GUJjM7u0
#>           Locale: en_US                                       
#>        Time zone: America/Los_Angeles                         
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>  chicken.csv: 1000 x 26

read_sheet(ss)
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

If you ever want to confirm the currently authenticated user, both
packages provide a `*_user()` function that reveals some info:

``` r

drive_user()
#> Logged in as:
#> • displayName:
#>   googlesheets4-dev-docs@robust-fin-276504.iam.gserviceaccount.com
#> • emailAddress:
#>   googlesheets4-dev-docs@robust-fin-276504.iam.gserviceaccount.com
gs4_user()
#> ℹ Logged in to googlesheets4 as
#>   googlesheets4-dev-docs@robust-fin-276504.iam.gserviceaccount.com.
```

We are using a service account to render this article. But if you’ve
used the default OAuth flow, this should correspond to the email of the
Google account you logged in with.

## Auth with googlesheets4 first, then googledrive

Outline:

- Proactively auth with googlesheets4 and specify the
  `"https://www.googleapis.com/auth/drive"` scope. The default
  googlesheets4 scope is
  `"https://www.googleapis.com/auth/spreadsheets"`, which is
  insufficient for general work with the Drive API.
- Tell googledrive to use the same token as googlesheets4.

First attach both packages.

``` r

library(googlesheets4)
library(googledrive)
```

Do auth first with googlesheets4, specifying a Drive scope. Remember
[`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md)
accepts additional arguments, e.g. to specify a Google identity via
`email =` or to use a service account via `path =`. Then direct
googledrive to use the same token as googlesheets4.

``` r

gs4_auth(scope = "https://www.googleapis.com/auth/drive")
drive_auth(token = gs4_token())
```

Now you can use googledrive functions to list files or find them by
name, path, or other property. Then, once you’ve identified the target
file, use googlesheets4 to do spreadsheet-specific tasks.

``` r

drive_find("chicken")
#> # A dribble: 1 × 3
#>   name          id       drive_resource   
#>   <chr>         <drv_id> <list>           
#> 1 chicken-sheet 1StV8oq… <named list [38]>

ss <- drive_get("chicken-sheet")
#> ✔ The input `path` resolved to exactly 1 file.

gs4_get(ss)
#> 
#> ── <googlesheets4_spreadsheet> ────────────────────────────────────────
#> Spreadsheet name: chicken-sheet                               
#>               ID: 1StV8oqHa0SVo58ztLGPH5mDMMHIBsiF6VO5GUJjM7u0
#>           Locale: en_US                                       
#>        Time zone: America/Los_Angeles                         
#>      # of sheets: 1                                           
#> 
#> ── <sheets> ───────────────────────────────────────────────────────────
#> (Sheet name): (Nominal extent in rows x columns)
#>  chicken.csv: 1000 x 26

read_sheet(ss)
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

## Scope savvy

If you only need “read” access to Drive or Sheets, the conservative
thing to do is to specify a read-only scope. This is a great way to
limit the damage anyone can do with the token – you or someone else –
through carelessness or malice. If you are storing a token on a remote
or shared location, it is wise to use the most conservative scope that
still gets the job done.

Here are various scopes relevant to googledrive and googlesheets4 and
what they would allow.

`drive` scope allows reading and writing with Drive and Sheets APIs.
This scope is the most powerful and, therefore, the most dangerous.

``` r

PACKAGE_auth(
  ...,
  scopes = "https://www.googleapis.com/auth/drive",
  ...
)
```

`drive.readonly` still allows file identification via Drive and can be
combined with `spreadsheets` if you plan to edit, create, or delete
Sheets.

``` r

PACKAGE_auth(
  ...,
  scopes = c(
    "https://www.googleapis.com/auth/drive.readonly",
    "https://www.googleapis.com/auth/spreadsheets"
  ),
  ...
)
```

If you are just using Drive to identify Sheets and are only reading from
those Sheets, the `drive.readonly` scope is sufficient and means you
can’t modify anything by accident.

``` r

PACKAGE_auth(
  ...,
  scopes = "https://www.googleapis.com/auth/drive.readonly",
  ...
)
```

If you are not using Drive at all, i.e. you always identify Sheets by
file ID, and you are only reading from those Sheets, you only need
googlesheets4 and `spreadsheets.readonly` is sufficient.

``` r

gs4_auth(
  ...,
  scopes = "https://www.googleapis.com/auth/spreadsheets.readonly",
  ...
)
```
