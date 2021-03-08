message <- function(...) {
  gs4_abort("
    Internal error: use googlesheets4's UI functions, not {bt('message()')}")
}

fr <- function(x) format(x, justify = 'right')
fl <- function(x) format(x, justify = 'left')

gs4_quiet <- function() {
  as.logical(Sys.getenv("GOOGLESHEETS4_QUIET", unset = NA))
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
  withr::local_envvar(c(GOOGLESHEETS4_QUIET = "true"), .local_envir = env)
}

local_gs4_loud <- function(env = parent.frame()) {
  withr::local_envvar(c(GOOGLESHEETS4_QUIET = "false"), .local_envir = env)
}

#' @export
#' @rdname googlesheets4-configuration
#' @param code Code to execute quietly
with_gs4_quiet <- function(code) {
  withr::with_envvar(c(GOOGLESHEETS4_QUIET = "true"), code = code)
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
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

gs4_success <- function(text, .envir = parent.frame()) {
  gs4_alert(text, type = "success", .envir = .envir)
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
