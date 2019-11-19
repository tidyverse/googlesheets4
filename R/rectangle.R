# low-tech typed version of tidyr::hoist() that is "list in, vector out"
hoist_lgl <- function(.x, ..., .default = NA) {
  map_lgl(.x, ..., .default = .default)
}

hoist_chr <- function(.x, ..., .default = NA) {
  map_chr(.x, ..., .default = .default)
}

hoist_int <- function(.x, ..., .default = NA) {
  map_int(.x, ..., .default = .default)
}
