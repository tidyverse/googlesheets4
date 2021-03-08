message <- function(...) {
  gs4_abort("
    Internal error: use googlesheets4's UI functions, not {bt('message()')}")
}

fr <- function(x) format(x, justify = 'right')
fl <- function(x) format(x, justify = 'left')

gs4_quiet <- function() {
  as.logical(Sys.getenv("GOOGLESHEETS4_QUIET", unset = NA))
}

local_gs4_quiet <- function(gs4_quiet = "TRUE", env = parent.frame()) {
  withr::local_envvar(c(GOOGLESHEETS4_QUIET = gs4_quiet), .local_envir = env)
}

local_gs4_loud <- function(env = parent.frame()) {
  local_gs4_quiet("FALSE", env = env)
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
