#' Example Sheets
#'
#' googlesheets4 makes a variety of world-readable example Sheets available for
#' use in documentation and reprexes. These functions help you access the
#' example Sheets. See `vignette("example-sheets", package = "googlesheets4")`
#' for more.
#'
#' @param matches A regular expression that matches the name of the desired
#'   example Sheet(s). `matches` is optional for the plural `gs4_examples()`
#'   and, if provided, it can match multiple Sheets. The singular
#'   `gs4_example()` requires `matches` and it must match exactly one Sheet.
#'
#' @return

#' * `gs4_example()`: a [sheets_id]
#' * `gs4_examples()`: a named vector of all built-in examples, with class
#'   [`drive_id`][googledrive::as_id]

#'
#' @name gs4_examples
#' @examplesIf gs4_has_token()
#' gs4_examples()
#' gs4_examples("gap")
#'
#' gs4_example("gapminder")
#' gs4_example("deaths")
NULL

#' @rdname gs4_examples
#' @export
gs4_examples <- function(matches) {
  many_sheets(
    needle    = matches,
    haystack  = example_and_test_sheets("example"),
    adjective = "example"
  )
}

#' @rdname gs4_examples
#' @export
gs4_example <- function(matches) {
  one_sheet(
    needle    = matches,
    haystack  = example_and_test_sheets("example"),
    adjective = "example"
  )
}

many_sheets <- function(needle, haystack, adjective, call = caller_env()) {
  out <- haystack

  if (!missing(needle)) {
    check_string(needle, call = call)
    sel <- grepl(needle, names(out), ignore.case = TRUE)
    if (!any(sel)) {
      gs4_abort(
        "Can't find {adjective} Sheet that matches {.q {needle}}.",
        call = call)
    }
    out <- as_id(out[sel])
  }

  out
}

one_sheet <- function(needle, haystack, adjective, call = caller_env()) {
  check_string(needle, call = call)
  out <- many_sheets(
    needle = needle,
    haystack = haystack,
    adjective = adjective,
    call = call
  )
  if (length(out) > 1) {
    gs4_abort(
      c(
        "Found multiple matching {adjective} Sheets:",
        bulletize(gargle_map_cli(names(out), template = "{.s_sheet <<x>>}")),
        i = "Make the {.arg matches} regular expression more specific."
      ),
      call = call
    )
  }
  as_sheets_id(out)
}

example_and_test_sheets <- function(purpose = NULL) {
  # inlining env_cache() logic, so I don't need bleeding edge rlang
  if (!env_has(.googlesheets4, "example_and_test_sheets")) {
    inventory_id <- "1dSIZ2NkEPDWiEbsg9G80Hr9Xe7HZglEAPwGhVa-OSyA"
    local_gs4_quiet()
    if (!gs4_has_token()) { # don't trigger auth just for this
      local_deauth()
    }
    dat <- read_sheet(as_sheets_id(inventory_id))
    env_poke(.googlesheets4, "example_and_test_sheets", dat)
  }
  dat <- env_get(.googlesheets4, "example_and_test_sheets")
  if (!is.null(purpose)) {
    dat <- dat[dat$purpose == purpose, ]
  }
  out <- dat$id
  names(out) <- dat$name
  as_id(out)
}

# test sheet management ----
test_sheets <- function(matches) {
  many_sheets(
    needle    = matches,
    haystack  = example_and_test_sheets("test"),
    adjective = "test"
  )
}

test_sheet <- function(matches = "googlesheets4-cell-tests") {
  one_sheet(
    needle    = matches,
    haystack  = example_and_test_sheets("test"),
    adjective = "test"
  )
}

test_sheet_create <- function(name = "googlesheets4-cell-tests") {
  stopifnot(is_string(name))

  user <- gs4_user()
  if (!grepl("^googlesheets4-sheet-keeper", user)) {
    user <- sub("@.+$", "", user)
    gs4_abort("
      Must be auth'd as {.email googlesheets4-sheet-keeper}, \\
      not {.email {user}}.")
  }

  existing <- gs4_find()
  m <- match(name, existing$name)
  if (is.na(m)) {
    gs4_bullets(c(v = "Creating {.s_sheet {name}}."))
    ss <- gs4_create(name)
  } else {
    gs4_bullets(c(
      v = "Testing sheet named {.s_sheet {name}} already exists ... using that."
    ))
    ss <- existing$id[[m]]
  }
  ssid <- as_sheets_id(ss)

  # it's fiddly to check current sharing status, so just re-share
  gs4_bullets(c(v = 'Making sure "anyone with a link" can read {.s_sheet {name}}.'))
  gs4_share(ssid)
  ssid
}
