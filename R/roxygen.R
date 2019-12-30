# functions to help reduce duplication and increase consistency in the docs

### sheet ----
param_sheet <- function(action, ...) {
  template <- glue("
    @param sheet \\
    Sheet to {action}, in the sense of \"worksheet\" or \"tab\". \\
    You can identify a sheet by name, with a string, or by position, \\
    with a number.
    ")
  dots <- rlang::list2(...)
  if (length(dots) > 0) {
    template <- c(template, dots)
  }
  glue_collapse(template, sep = " ")
}
