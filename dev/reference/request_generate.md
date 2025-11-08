# Generate a Google Sheets API request

Generate a request, using knowledge of the [Sheets
API](https://developers.google.com/sheets/api/) from its Discovery
Document
(`https://www.googleapis.com/discovery/v1/apis/sheets/v4/rest`). Use
[`request_make()`](https://googlesheets4.tidyverse.org/dev/reference/request_make.md)
to execute the request. Most users should, instead, use higher-level
wrappers that facilitate common tasks, such as reading or writing
worksheets or cell ranges. The functions here are intended for internal
use and for programming around the Sheets API.

`request_generate()` lets you provide the bare minimum of input. It
takes a nickname for an endpoint and:

- Uses the API spec to look up the `method`, `path`, and `base_url`.

- Checks `params` for validity and completeness with respect to the
  endpoint. Uses `params` for URL endpoint substitution and separates
  remaining parameters into those destined for the body versus the
  query.

- Adds an API key to the query if and only if `token = NULL`.

## Usage

``` r
request_generate(
  endpoint = character(),
  params = list(),
  key = NULL,
  token = gs4_token()
)
```

## Arguments

- endpoint:

  Character. Nickname for one of the selected Sheets API v4 endpoints
  built into googlesheets4. Learn more in
  [`gs4_endpoints()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_endpoints.md).

- params:

  Named list. Parameters destined for endpoint URL substitution, the
  query, or the body.

- key:

  API key. Needed for requests that don't contain a token. The need for
  an API key in the absence of a token is explained in Google's document
  "Credentials, access, security, and identity"
  (`https://support.google.com/googleapi/answer/6158857?hl=en&ref_topic=7013279`).
  In order of precedence, these sources are consulted: the formal `key`
  argument, a `key` parameter in `params`, a user-configured API key set
  up with
  [`gs4_auth_configure()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md)
  and retrieved with
  [`gs4_api_key()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md).

- token:

  Set this to `NULL` to suppress the inclusion of a token. Note that, if
  auth has been de-activated via
  [`gs4_deauth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_deauth.md),
  [`gs4_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_token.md)
  will actually return `NULL`.

## Value

[`list()`](https://rdrr.io/r/base/list.html)  
Components are `method`, `url`, `body`, and `token`, suitable as input
for
[`request_make()`](https://googlesheets4.tidyverse.org/dev/reference/request_make.md).

## See also

[`gargle::request_develop()`](https://gargle.r-lib.org/reference/request_develop.html),
[`gargle::request_build()`](https://gargle.r-lib.org/reference/request_develop.html),
[`gargle::request_make()`](https://gargle.r-lib.org/reference/request_make.html)

Other low-level API functions:
[`gs4_has_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_has_token.md),
[`gs4_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_token.md),
[`request_make()`](https://googlesheets4.tidyverse.org/dev/reference/request_make.md)

## Examples

``` r
req <- request_generate(
  "sheets.spreadsheets.get",
  list(spreadsheetId = gs4_example("deaths")),
  key = "PRETEND_I_AM_AN_API_KEY",
  token = NULL
)
req
#> $method
#> [1] "GET"
#> 
#> $url
#> [1] "https://sheets.googleapis.com/v4/spreadsheets/1VTJjWoP1nshbyxmL9JqXgdVsimaYty21LGxxs018H2Y?key=PRETEND_I_AM_AN_API_KEY"
#> 
#> $body
#> named list()
#> 
#> $token
#> NULL
#> 
```
