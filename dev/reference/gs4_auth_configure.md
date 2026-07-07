# Edit and view auth configuration

These functions give more control over and visibility into the auth
configuration than
[`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md)
does. `gs4_auth_configure()` lets the user specify their own:

- OAuth client, which is used when obtaining a user token.

- API key. If googlesheets4 is de-authorized via
  [`gs4_deauth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_deauth.md),
  all requests are sent with an API key in lieu of a token.

See the
[`vignette("get-api-credentials", package = "gargle")`](https://gargle.r-lib.org/articles/get-api-credentials.html)
for more. If the user does not configure these settings, internal
defaults are used.

`gs4_oauth_client()` and `gs4_api_key()` retrieve the currently
configured OAuth client and API key, respectively.

## Usage

``` r
gs4_auth_configure(client, path, api_key, app = deprecated())

gs4_api_key()

gs4_oauth_client()
```

## Arguments

- client:

  A Google OAuth client, presumably constructed via
  [`gargle::gargle_oauth_client_from_json()`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.html).
  Note, however, that it is preferred to specify the client with JSON,
  using the `path` argument.

- path:

  JSON downloaded from [Google Cloud
  Console](https://console.cloud.google.com), containing a client id and
  secret, in one of the forms supported for the `txt` argument of
  [`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
  (typically, a file path or JSON string).

- api_key:

  API key.

- app:

  **\[deprecated\]** Replaced by the `client` argument.

## Value

- `gs4_auth_configure()`: An object of R6 class
  [gargle::AuthState](https://gargle.r-lib.org/reference/AuthState-class.html),
  invisibly.

- `gs4_oauth_client()`: the current user-configured OAuth client.

- `gs4_api_key()`: the current user-configured API key.

## See also

Other auth functions:
[`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md),
[`gs4_deauth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_deauth.md),
[`gs4_scopes()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_scopes.md)

## Examples

``` r
# see and store the current user-configured OAuth client (probably `NULL`)
(original_client <- gs4_oauth_client())
#> NULL

# see and store the current user-configured API key (probably `NULL`)
(original_api_key <- gs4_api_key())
#> NULL

# the preferred way to configure your own client is via a JSON file
# downloaded from Google Developers Console
# this example JSON is indicative, but fake
path_to_json <- system.file(
  "extdata", "client_secret_installed.googleusercontent.com.json",
  package = "gargle"
)
gs4_auth_configure(path = path_to_json)

# this is also obviously a fake API key
gs4_auth_configure(api_key = "the_key_I_got_for_a_google_API")

# confirm the changes
gs4_oauth_client()
#> <gargle_oauth_client>
#> name: a_project_59aa1797ab7ac4667a77617c3400999c
#> id: abc.apps.googleusercontent.com
#> secret: <REDACTED>
#> type: installed
#> redirect_uris: http://localhost
gs4_api_key()
#> [1] "the_key_I_got_for_a_google_API"

# restore original auth config
gs4_auth_configure(client = original_client, api_key = original_api_key)
```
