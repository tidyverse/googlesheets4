#' Errors conditions for the googlesheets4 package
#'
#' @param class Use only if you want to subclass beyond `gs4_error`
#'
#' @keywords internal
#' @name gs4-errors
#' @noRd
NULL

gs4_abort <- function(message, ..., class = NULL, env = parent.frame()) {
  msg <- glue(message, .envir = env)
  abort(msg, class = c(class, "gs4_error"), ...)
}

sq <- function(x) glue::single_quote(x)
dq <- function(x) glue::double_quote(x)
bt <- function(x) glue::backtick(x)
