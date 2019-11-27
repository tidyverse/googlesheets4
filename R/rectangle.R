# hack-y implementation of typed pluck with an NA default
glean_lgl <- function(.x, ..., .default = NA) {
  map_lgl(list(.x), ..., .default = .default)
}

glean_chr <- function(.x, ..., .default = NA) {
  map_chr(list(.x), ..., .default = .default)
}

glean_int <- function(.x, ..., .default = NA) {
  map_int(list(.x), ..., .default = .default)
}
