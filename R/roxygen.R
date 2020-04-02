# functions to help reduce duplication and increase consistency in the docs

### ss ----
param_ss <- function(..., pname = "ss") {
  template <- glue("
    @param {pname} \\
    Something that identifies a Google Sheet: its file ID, a URL from
    which we can recover the ID, an instance of `googlesheets4_spreadsheet`
    (returned by [sheets_get()], or a [`dribble`][googledrive::dribble], which
    is how googledrive represents Drive files. Processed through
    [as_sheets_id()].
    ")
  dots <- list2(...)
  if (length(dots) > 0) {
    template <- c(template, dots)
  }
  glue_collapse(template, sep = " ")
}

### sheet ----
param_sheet <- function(action, ...) {
  template <- glue("
    @param sheet \\
    Sheet to {action}, in the sense of \"worksheet\" or \"tab\". \\
    You can identify a sheet by name, with a string, or by position, \\
    with a number.
    ")
  dots <- list2(...)
  if (length(dots) > 0) {
    template <- c(template, dots)
  }
  glue_collapse(template, sep = " ")
}
