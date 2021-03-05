sq <- function(x) glue::single_quote(x)
bt <- function(x) glue::backtick(x)
dq <- function(x) encodeString(x, quote = '"')

fr <- function(x) format(x, justify = 'right')
fl <- function(x) format(x, justify = 'left')

stop_glue <- function(..., .sep = "", .envir = parent.frame(),
                      call. = FALSE, .domain = NULL) {
  stop(
    glue(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_glue_data <- function(..., .sep = "", .envir = parent.frame(),
                           call. = FALSE, .domain = NULL) {
  stop(
    glue_data(..., .sep = .sep, .envir = .envir),
    call. = call., domain = .domain
  )
}

stop_collapse <- function(x) stop(glue_collapse(x, sep = "\n"), call. = FALSE)
