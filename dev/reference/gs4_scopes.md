# Produce scopes specific to the Sheets API

When called with no arguments, `gs4_scopes()` returns a named character
vector of scopes associated with the Sheets API. If
`gs4_scopes(scopes =)` is given, an abbreviated entry such as
`"sheets.readonly"` is expanded to a full scope
(`"https://www.googleapis.com/auth/sheets.readonly"` in this case).
Unrecognized scopes are passed through unchanged.

## Usage

``` r
gs4_scopes(scopes = NULL)
```

## Arguments

- scopes:

  One or more API scopes. Each scope can be specified in full or, for
  Sheets API-specific scopes, in an abbreviated form that is recognized
  by `gs4_scopes()`:

  - "spreadsheets" = "https://www.googleapis.com/auth/spreadsheets" (the
    default)

  - "spreadsheets.readonly" =
    "https://www.googleapis.com/auth/spreadsheets.readonly"

  - "drive" = "https://www.googleapis.com/auth/drive"

  - "drive.readonly" = "https://www.googleapis.com/auth/drive.readonly"

  - "drive.file" = "https://www.googleapis.com/auth/drive.file"

  See
  <https://developers.google.com/identity/protocols/oauth2/scopes#sheets>
  for details on the permissions for each scope.

## Value

A character vector of scopes.

## See also

<https://developers.google.com/identity/protocols/oauth2/scopes#sheets>
for details on the permissions for each scope.

Other auth functions:
[`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md),
[`gs4_auth_configure()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md),
[`gs4_deauth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_deauth.md)

## Examples

``` r
gs4_scopes("spreadsheets")
#> [1] "https://www.googleapis.com/auth/spreadsheets"
gs4_scopes("spreadsheets.readonly")
#> [1] "https://www.googleapis.com/auth/spreadsheets.readonly"
gs4_scopes("drive")
#> [1] "https://www.googleapis.com/auth/drive"
gs4_scopes()
#>                                            spreadsheets 
#>          "https://www.googleapis.com/auth/spreadsheets" 
#>                                   spreadsheets.readonly 
#> "https://www.googleapis.com/auth/spreadsheets.readonly" 
#>                                                   drive 
#>                 "https://www.googleapis.com/auth/drive" 
#>                                          drive.readonly 
#>        "https://www.googleapis.com/auth/drive.readonly" 
#>                                              drive.file 
#>            "https://www.googleapis.com/auth/drive.file" 
```
