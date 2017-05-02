#' googlesheets
#'
#' Google spreadsheets R API
#'
#' See the README on
#' [CRAN](https://cran.r-project.org/web/packages/googlesheets/README.html) or
#' [GitHub](https://github.com/jennybc/googlesheets#readme)
#'
#' @docType package
#' @name googlesheets
#' @importFrom purrr %>%
#' @importFrom purrr %||%
NULL

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if (getRversion() >= "2.15.1")  utils::globalVariables(c("."))
