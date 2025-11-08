# Make a Google Sheets API request

Low-level function to execute a Sheets API request. Most users should,
instead, use higher-level wrappers that facilitate common tasks, such as
reading or writing worksheets or cell ranges. The functions here are
intended for internal use and for programming around the Sheets API.

## Usage

``` r
request_make(x, ..., encode = "json")
```

## Arguments

- x:

  List. Holds the components for an HTTP request, presumably created
  with
  [`request_generate()`](https://googlesheets4.tidyverse.org/dev/reference/request_generate.md)
  or
  [`gargle::request_build()`](https://gargle.r-lib.org/reference/request_develop.html).
  Must contain a `method` and `url`. If present, `body` and `token` are
  used.

- ...:

  Optional arguments passed through to the HTTP method.

- encode:

  If the body is a named list, how should it be encoded? This has the
  same meaning as `encode` in all the
  [`httr::VERB()`](https://httr.r-lib.org/reference/VERB.html)s, such as
  [`httr::POST()`](https://httr.r-lib.org/reference/POST.html). Note,
  however, that we default to `encode = "json"`, which is what you want
  most of the time when calling the Sheets API. The httr default is
  `"multipart"`. Other acceptable values are `"form"` and `"raw"`.

## Value

Object of class `response` from
[httr::httr](https://httr.r-lib.org/reference/httr-package.html).

## Details

`make_request()` is a very thin wrapper around
[`gargle::request_retry()`](https://gargle.r-lib.org/reference/request_retry.html),
only adding the googlesheets4 user agent. Typically the input has been
created with
[`request_generate()`](https://googlesheets4.tidyverse.org/dev/reference/request_generate.md)
or
[`gargle::request_build()`](https://gargle.r-lib.org/reference/request_develop.html)
and the output is processed with `process_response()`.

[`gargle::request_retry()`](https://gargle.r-lib.org/reference/request_retry.html)
retries requests that error with `429 RESOURCE_EXHAUSTED`. Its basic
scheme is exponential backoff, with one tweak that is very specific to
the Sheets API, which has documented [usage
limits](https://developers.google.com/sheets/api/limits):

"a limit of 500 requests per 100 seconds per project and 100 requests
per 100 seconds per user"

Note that the "project" here means everyone using googlesheets4 who
hasn't configured their own OAuth client. This is potentially a lot of
users, all acting independently.

If you hit the "100 requests per 100 seconds per **user**" limit (which
really does mean YOU), the first wait time is a bit more than 100
seconds, then we revert to exponential backoff.

If you experience lots of retries, especially with 100 second delays, it
means your use of googlesheets4 is more than casual and **it's time for
you to get your own OAuth client or use a service account token**. This
is explained in the gargle vignette
[`vignette("get-api-credentials", package = "gargle")`](https://gargle.r-lib.org/articles/get-api-credentials.html).

## See also

Other low-level API functions:
[`gs4_has_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_has_token.md),
[`gs4_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_token.md),
[`request_generate()`](https://googlesheets4.tidyverse.org/dev/reference/request_generate.md)
