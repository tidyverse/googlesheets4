# Produce configured token

For internal use or for those programming around the Sheets API. Returns
a token pre-processed with
[`httr::config()`](https://httr.r-lib.org/reference/config.html). Most
users do not need to handle tokens "by hand" or, even if they need some
control,
[`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md)
is what they need. If there is no current token,
[`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md)
is called to either load from cache or initiate OAuth2.0 flow. If auth
has been deactivated via
[`gs4_deauth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_deauth.md),
`gs4_token()` returns `NULL`.

## Usage

``` r
gs4_token()
```

## Value

A `request` object (an S3 class provided by
[httr](https://httr.r-lib.org/reference/httr-package.html)).

## See also

Other low-level API functions:
[`gs4_has_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_has_token.md),
[`request_generate()`](https://googlesheets4.tidyverse.org/dev/reference/request_generate.md),
[`request_make()`](https://googlesheets4.tidyverse.org/dev/reference/request_make.md)

## Examples

``` r
req <- request_generate(
  "sheets.spreadsheets.get",
  list(spreadsheetId = "abc"),
  token = gs4_token()
)
req
#> $method
#> [1] "GET"
#> 
#> $url
#> [1] "https://sheets.googleapis.com/v4/spreadsheets/abc"
#> 
#> $body
#> named list()
#> 
#> $token
#> <request>
#> Auth token: TokenServiceAccount
#> 
```
