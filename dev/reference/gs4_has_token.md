# Is there a token on hand?

Reports whether googlesheets4 has stored a token, ready for use in
downstream requests.

## Usage

``` r
gs4_has_token()
```

## Value

Logical.

## See also

Other low-level API functions:
[`gs4_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_token.md),
[`request_generate()`](https://googlesheets4.tidyverse.org/dev/reference/request_generate.md),
[`request_make()`](https://googlesheets4.tidyverse.org/dev/reference/request_make.md)

## Examples

``` r
gs4_has_token()
#> [1] TRUE
```
