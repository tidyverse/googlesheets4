gs4_theme <- function() {
  list(
    span.field = list(transform = single_quote_if_no_color),
    # This is same as custom `.drivepath` style in googledrive
    span.s_sheet = list(color = "cyan", fmt = double_quote_weird_name),
    span.w_sheet = list(color = "green", fmt = single_quote_weird_name),
    span.range = list(color = "yellow", fmt = single_quote_weird_name),
    # since we're using color so much elsewhere, I think the standard bullet
    # should be "normal" color; matches what I do in googledrive
    ".memo .memo-item-*" = list(
      "text-exdent" = 2,
      before = function(x) paste0(cli::symbol$bullet, " ")
    )
  )
}

single_quote_weird_name <- function(x) {
  utils::getFromNamespace("quote_weird_name", "cli")(x)
}

# this is just the body of cli's quote_weird_name() but with a double quote
double_quote_weird_name <- function(x) {
  x2 <- utils::getFromNamespace("quote_weird_name0", "cli")(x)
  if (x2[[2]] || cli::num_ansi_colors() == 1) {
    x2[[1]] <- paste0('"', x2[[1]], '"')
  }
  x2[[1]]
}

single_quote_if_no_color <- function(x) quote_if_no_color(x, "'")
double_quote_if_no_color <- function(x) quote_if_no_color(x, '"')

quote_if_no_color <- function(x, quote = "'") {
  # TODO: if a better way appears in cli, use it
  # @gabor says: "if you want to have before and after for the no-color case
  # only, we can have a selector for that, such as:
  # span.field::no-color
  # (but, at the time I write this, cli does not support this yet)
  if (cli::num_ansi_colors() > 1) {
    x
  } else {
    paste0(quote, x, quote)
  }
}

# useful to me during development, so I can see how my messages look w/o color
local_no_color <- function(.envir = parent.frame()) {
  withr::local_envvar(c("NO_COLOR" = 1), .local_envir = .envir)
}

with_no_color <- function(code) {
  withr::with_envvar(c("NO_COLOR" = 1), code)
}

message <- function(...) {
  gs4_abort("
    Internal error: use the UI functions in {.pkg googlesheets4} \\
    instead of {.fun message}")
}

fr <- function(x) format(x, justify = "right")
fl <- function(x) format(x, justify = "left")

gs4_quiet <- function() {
  getOption("googlesheets4_quiet", default = NA)
}

#' @export
#' @rdname googlesheets4-configuration
#' @param env The environment to use for scoping
#' @examplesIf gs4_has_token()
#' # message: "Creating new Sheet ..."
#' (ss <- gs4_create("gs4-quiet-demo", sheets = "alpha"))
#'
#' # message: "Editing ..., Writing ..."
#' range_write(ss, data = data.frame(x = 1, y = "a"))
#'
#' # suppress messages for a small amount of code
#' with_gs4_quiet(
#'   ss %>% sheet_append(data.frame(x = 2, y = "b"))
#' )
#'
#' # message: "Writing ..., Appending ..."
#' ss %>% sheet_append(data.frame(x = 3, y = "c"))
#'
#' # suppress messages until end of current scope
#' local_gs4_quiet()
#' ss %>% sheet_append(data.frame(x = 4, y = "d"))
#'
#' # see that all the data was, in fact, written
#' read_sheet(ss)
#'
#' # clean up
#' gs4_find("gs4-quiet-demo") %>%
#'   googledrive::drive_trash()
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
  cli::cli_div(theme = gs4_theme())
  cli::cli_inform(message = text, .envir = .envir)
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
  cli::cli_div(theme = gs4_theme())
  cli::cli_abort(
    message = message,
    ...,
    class = c(class, "googlesheets4_error"),
    .envir = .envir
  )
}

# helpful in the default method of an as_{to} generic
# exists mostly to template the message
abort_unsupported_conversion <- function(from, to) {
  if (is.null(from)) {
    msg_from <- "{.code NULL}"
  } else {
    msg_from <- "something of class {.cls {class(from)}}"
  }
  msg <- glue("
    Don't know how to make an instance of {.cls {to}} from <<msg_from>>.",
    .open = "<<", .close = ">>"
  )
  gs4_abort(msg)
}
