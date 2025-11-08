# Suspend authorization

Put googlesheets4 into a de-authorized state. Instead of sending a
token, googlesheets4 will send an API key. This can be used to access
public resources for which no Google sign-in is required. This is handy
for using googlesheets4 in a non-interactive setting to make requests
that do not require a token. It will prevent the attempt to obtain a
token interactively in the browser. The user can configure their own API
key via
[`gs4_auth_configure()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md)
and retrieve that key via
[`gs4_api_key()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md).
In the absence of a user-configured key, a built-in default key is used.

## Usage

``` r
gs4_deauth()
```

## See also

Other auth functions:
[`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md),
[`gs4_auth_configure()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md),
[`gs4_scopes()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_scopes.md)

## Examples

``` r
if (FALSE) { # rlang::is_interactive()
gs4_deauth()
gs4_user()

# get metadata on the public 'deaths' spreadsheet
gs4_example("deaths") %>%
  gs4_get()
}
```
