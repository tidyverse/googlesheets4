#' @keywords internal
#' @import rlang
"_PACKAGE"

## usethis namespace: start
#' @importFrom gargle bulletize
#' @importFrom gargle gargle_map_cli
#' @importFrom glue glue
#' @importFrom glue glue_collapse
#' @importFrom glue glue_data
#' @importFrom googledrive as_id
#' @importFrom lifecycle deprecated
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
#' Some aspects of googlesheets4 behaviour can be controlled via an option.
#'
#' @section Messages:
#'
#' The `googlesheets4_quiet` option can be used to suppress messages from
#' googlesheets4. By default, googlesheets4 always messages, i.e. it is *not*
#' quiet.
#'
#' Set `googlesheets4_quiet` to `TRUE` to suppress messages, by one of these
#' means, in order of decreasing scope:
#' * Put `options(googlesheets4_quiet = TRUE)` in a start-up file, such as
#'   `.Rprofile`, or in your R script
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

# used for building functions that construct Sheet names in tests ----
nm_fun <- function(context, user_run = TRUE) {
  user_run <- if (isTRUE(user_run)) nm_user_run() else NULL
  y <- purrr::compact(list(context, user_run))
  function(x = character()) as.character(glue_collapse(c(x, y), sep = "-"))
}

nm_user_run <- function() {
  if (as.logical(Sys.getenv("GITHUB_ACTIONS", unset = "false"))) {
    glue("gha-{Sys.getenv('GITHUB_WORKFLOW')}-{Sys.getenv('GITHUB_RUN_ID')}")
  } else {
    random_id <- ids::proquint(n = 1, n_words = 2)
    glue("{Sys.info()['user']}-{random_id}")
  }
}
