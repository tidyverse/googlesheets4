#' Error conditions for the googlesheets4 package
#'
#' @param class Use only if you want to subclass beyond `googlesheets4_error`
#'
#' @keywords internal
#' @name gs4-errors
#' @noRd
NULL

gs4_abort <- function(message, ..., class = NULL, .envir = parent.frame()) {
  g <- function(line) glue(line, .envir = .envir)
  msg <- map_chr(message, g)
  abort(msg, class = c(class, "googlesheets4_error"), ...)
}

sq <- function(x) glue::single_quote(x)
dq <- function(x) glue::double_quote(x)
bt <- function(x) glue::backtick(x)

class_collapse <- function(x) {
  glue("<{glue_collapse(class(x), sep = '/')}>")
}

# helpful in the default method of an as_{to} generic
# exists mostly to template the message
abort_unsupported_conversion <- function(from, to) {
  if (is.null(from)) {
    msg_from <- bt("NULL")
  } else {
    msg_from <- glue("something of class {class_collapse(from)}")
  }
  gs4_abort("
    Don't know how to make an instance of {class_collapse(to)} from {msg_from}")
}
