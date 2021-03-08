#' @keywords internal
#' @import rlang
"_PACKAGE"

## usethis namespace: start
#' @importFrom glue glue
#' @importFrom glue glue_collapse
#' @importFrom glue glue_data
#' @importFrom purrr %||%
#' @importFrom purrr compact
#' @importFrom purrr discard
#' @importFrom purrr imap
#' @importFrom purrr keep
#' @importFrom purrr map
#' @importFrom purrr map_chr
#' @importFrom purrr map_dbl
#' @importFrom purrr map_int
#' @importFrom purrr map_lgl
#' @importFrom purrr map2
#' @importFrom purrr modify_if
#' @importFrom purrr pluck
#' @importFrom purrr pmap
#' @importFrom purrr pmap_chr
#' @importFrom purrr set_names
#' @importFrom purrr transpose
#' @importFrom purrr walk
#' @importFrom tibble as_tibble
## usethis namespace: end
NULL

#' Internal vctrs methods
#'
#' @import vctrs
#' @keywords internal
#' @name googlesheets4-vctrs
NULL

#' googlesheets4 configuration
#'
#' @description
#' Some aspects of googlesheets4 behaviour can be controlled via an option or
#' an environment variable.
#'
#' @section Messages:
#'
#' The `GOOGLESHEETS4_QUIET` environment variable can be used to suppress
#' messages from googlesheets4. By default, googlesheets4 always messages, i.e.
#' it is *not* quiet.
#'
#' Set `GOOGLESHEETS4_QUIET` to `"true"` to suppress messages, by one of these
#' means, in order of decreasing scope:
#' * Put `GOOGLESHEETS4_QUIET=true` in a start-up file, such as `.Renviron`
#' * Call `Sys.setenv(GOOGLESHEETS4_QUIET = "true")` in, e.g., your R script
#' * Use `local_gs4_quiet()` to silence googlesheets4 in a specific scope
#' * Use `with_gs4_quiet()` to run a small bit of code silently
#'
#' `local_gs4_quiet()` and `with_gs4_quiet()` follow the conventions of the
#' the withr package (<https://withr.r-lib.org>).
#'
#' @section Auth:
#'
#' Read about googlesheets4's main auth function, [gs4_auth()]. It is powered
#' by the gargle package, which consults several options:
#' * Default Google user or, more precisely, `email`: see
#'   [gargle::gargle_oauth_email()]
#' * Whether or where to cache OAuth tokens: see
#'   [gargle::gargle_oauth_cache()]
#' * Whether to prefer "out-of-band" auth: see
#'   [gargle::gargle_oob_default()]
#' * Application Default Credentials: see [gargle::credentials_app_default()]
#'
#' @name googlesheets4-configuration
NULL
