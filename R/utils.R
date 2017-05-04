## good news: these are handy and call. = FALSE is built-in
##  bad news: 'fmt' must be exactly 1 string, i.e. you've got to paste, iff
##             you're counting on sprintf() substitution
cpf <- function(...) cat(paste0(sprintf(...), "\n"))
mpf <- function(...) message(sprintf(...))
wpf <- function(...) warning(sprintf(...), call. = FALSE)
spf <- function(...) stop(sprintf(...), call. = FALSE)

## useful in development
str0 <- function(...) utils::str(..., max.level = 0)
str1 <- function(...) utils::str(..., max.level = 1)
str2 <- function(...) utils::str(..., max.level = 2)
