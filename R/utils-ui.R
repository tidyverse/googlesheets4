message <- function(...) {
  gs4_abort("
    Internal error: use googlesheets4's UI functions, not {bt('message()')}")
}

fr <- function(x) format(x, justify = 'right')
fl <- function(x) format(x, justify = 'left')

gs4_quiet <- function() {
  getOption("googlesheets4_quiet", default = NA)
}

#' @export
#' @rdname googlesheets4-configuration
#' @param env The environment to use for scoping
#' @examples
#' if (gs4_has_token()) {
#'   # message: "Creating new Sheet ..."
#'   (ss <- gs4_create("gs4-quiet-demo", sheets = "alpha"))
#'
#'   # message: "Editing ..., Writing ..."
#'   range_write(ss, data = data.frame(x = 1, y = "a"))
#'
#'   # suppress messages for a small amount of code
#'   with_gs4_quiet(
#'     ss %>% sheet_append(data.frame(x = 2, y = "b"))
#'   )
#'
#'   # message: "Writing ..., Appending ..."
#'   ss %>% sheet_append(data.frame(x = 3, y = "c"))
#'
#'   # suppress messages until end of current scope
#'   local_gs4_quiet()
#'   ss %>% sheet_append(data.frame(x = 4, y = "d"))
#'
#'   # see that all the data was, in fact, written
#'   read_sheet(ss)
#'
#'   # clean up
#'   gs4_find("gs4-quiet-demo") %>%
#'     googledrive::drive_trash()
#' }
local_gs4_quiet <- function(env = parent.frame()) {
  withr::local_options(list(googlesheets4_quiet = TRUE), .local_envir = env)
}

local_gs4_loud <- function(env = parent.frame()) {
  withr::local_options(list(googlesheets4_quiet = FALSE), .local_envir = env)
}

#' @export
#' @rdname googlesheets4-configuration
#' @param code Code to execute quietly
with_gs4_quiet <- function(code) {
  withr::with_options(list(googlesheets4_quiet = TRUE), code = code)
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

gs4_bullets <- function(text, .envir = parent.frame()) {
  quiet <- gs4_quiet() %|% is_testing()
  if (quiet) {
    return(invisible())
  }
  # TODO: I assume I'll eventually go here
  # cli::cli_div(theme = gs4_theme())
  cli::cli_bullets(text = text, .envir = .envir)
}

gs4_alert <- function(text,
                      type = c("success", "info", "warning", "danger"),
                      .envir = parent.frame()) {
  quiet <- gs4_quiet() %|% is_testing()
  if (quiet) {
    return(invisible())
  }
  cli_fun <- switch(
    type,
    success = cli::cli_alert_success,
    info    = cli::cli_alert_info,
    warning = cli::cli_alert_warning,
    danger  = cli::cli_alert_danger,
    cli::cli_alert
  )
  cli_fun(text = text, wrap = TRUE, .envir = .envir)
}

gs4_info <- function(text, .envir = parent.frame()) {
  gs4_alert(text, type = "info", .envir = .envir)
}

gs4_warning <- function(text, .envir = parent.frame()) {
  gs4_alert(text, type = "warning", .envir = .envir)
}

gs4_danger <- function(text, .envir = parent.frame()) {
  gs4_alert(text, type = "danger", .envir = .envir)
}

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
